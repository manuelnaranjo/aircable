# -*- coding: utf-8 -*-
#    OpenProximity2.0 is a proximity marketing OpenSource system.
#    Copyright (C) 2009,2008 Naranjo Manuel Francisco <manuel@aircable.net>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation version 2 of the License.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License along
#    with this program; if not, write to the Free Software Foundation, Inc.,
#    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

from django.db import models
from django.utils import simplejson as json
from models import *
from serverxr import SensorManager
from openproximity.models import getMatchingCampaigns
from re import compile
from rpyc import async
import signals
import time

clients = dict()
serving = dict()
handlers = dict()

def handle(signal, services, manager, *args, **kwargs):
    if not signals.isSensorSDKSignal(signal):
	return
    global handlers
    
    print "SDK HANDLE", signal, args, kwargs
    
    if signal in handlers:
	handlers[signal](manager=manager, *args, **kwargs)

def get_dongles(dongles):
    return SensorSDKBluetoothDongle.objects.filter(address__in=dongles, enabled=True).\
	values_list('address', 'max_conn')

class Client:
    def __init__(self, client):
	self.client=client
	self.add_dongle=async(client.add_dongle)
	self.refreshDongles=async(client.refreshDongles)
	self.connect=async(client.connect)

def register(client=None, dongles=None):
    print client.__class__, dongles
    if client.__class__ != SensorManager:
	return False

    client=Client(client)
    
    dongles = get_dongles(list(dongles))
    
    for dongle, max_conn in dongles:
	clients[dongle]=client
	client.add_dongle(dongle, max_conn)
    
    client.refreshDongles()
    return True

TIMEOUT=60

def device_found(record, services):
    dongle = record.dongle.address
    print "sensorsdk device_found", dongle , record.remote.address
    camps = getMatchingCampaigns(record.remote, enabled=True, classes=[SensorCampaign,])
    if len(camps) == 0:
	return False
    if len(camps) > 1:
	raise Exception("There's more than one campaign that matches, check settings")

    print "found campaign"
    camp = camps[0]
    
    latest=SensorSDKRecord.objects.filter(remote=record.remote)
    
    if latest.count() > 0 and time.time() - time.mktime(latest.latest('time').time.timetuple()) < TIMEOUT:
	print "has served in less than %s seconds" % TIMEOUT
	return False

    global clients
    if clients.get(dongle, None) is None:
	return False # there's no registered service I can't do a thing

    print "handling device %s" % record.remote.address
    client = clients[dongle]
    client.connect(record.remote.address)
    return True

CLOCK=compile(r'^CLOCK\|(?P<clock>(\d+)*.?(\d+)*)$')
READING=compile(r'^BATT\|(?P<batt>(\d+))\|SECS\|(?P<secs>(\d+))\|(?P<reading>.*)$')

def parse_history(model=None, history=None, target=None, success=False, 
	    dongle=None, pending=None, *args, **kwargs):
    last_time = time.time()
    readings = list()
    for line in history.splitlines():
	line = line.strip()
	if CLOCK.match(line):
	    last_time = float(CLOCK.match(line).groupdict()['clock'])
	    print "SDK time sync", last_time
	elif READING.match(line):
	    reg = READING.match(line).groupdict()
	    print "SDK reading line", reg
	    last_time+=float(reg['secs'])
	    readings.append( (last_time, reg['batt'], reg['reading']), )
	else:
	    print "SDK wrong line", line
    
    dongle = SensorSDKBluetoothDongle.objects.get(address=dongle)

    handler = SensorSDKRecord.getHandler(model)
    for secs, batt, read in readings:
	handler.parsereading(device=target, seconds=secs, battery=batt, reading=read, dongle=dongle)
    
    pending.remove(target)

handlers[signals.HANDLED_HISTORY]=parse_history

def handle_failed(pending, target, *args, **kwargs):
    print "handle failed", target
    pending.remove(target)

handlers[signals.TOO_BUSY]=handle_failed
handlers[signals.CONNECTION_FAILED]=handle_failed
