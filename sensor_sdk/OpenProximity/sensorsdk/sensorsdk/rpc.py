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

from django.db import transaction
from django.utils import simplejson as json
from models import *
from serverxr import SensorManager
from openproximity.models import getMatchingCampaigns
from re import compile
from rpyc import async
from net.aircable.utils import logger
from utils import isAIRcable
from threading import Thread
import signals
import time

import unicodedata, re

all_chars = (unichr(i) for i in xrange(0x110000))
# or equivalently and much more efficiently
control_chars = ''.join(map(unichr, range(0,32) + range(127,160)))

control_char_re = re.compile('[%s]' % re.escape(control_chars))

def remove_control_chars(s):
    return control_char_re.sub('', s)

clients = dict()
serving = dict()
handlers = dict()
service = dict()
''' a dict holding when each device was last time served '''

def handle(signal, services, manager, *args, **kwargs):
    if not signals.isSensorSDKSignal(signal):
	return
    global handlers
    
    logger.info("SDK HANDLE %s %s %s" % (signals.TEXT[signal], args, kwargs) )
    
    if signal in handlers:
	return handlers[signal](manager=manager, *args, **kwargs)

    logger.error("SDK, no handler %s" % signals.TEXT[signal])

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
    logger.info("register  %s %s" % (client, dongles))
    if repr(client).find('sensorsdk.serverxr.SensorManager') == -1:
        logger.debug("no match")
        return False

    client=Client(client)
    dongles = get_dongles(list(dongles))

    for dongle, max_conn in dongles:
        clients[dongle]=client
        client.add_dongle(dongle, max_conn)

    client.refreshDongles()
    return True

TIMEOUT=300

def check_if_service(address):
    clean_service()
    if address in service:
	if time.time()-service[address] < TIMEOUT:
	    logger.info("has served in less than %s seconds" % TIMEOUT)
	    return False
	
    latest=SensorSDKRemoteDevice.objects.filter(
	address=address)
    
    if latest.count() > 0 and time.time() - \
	time.mktime(latest.latest('latest_served').latest_served.timetuple()) < TIMEOUT:
	logger.info("has served in less than %s seconds" % TIMEOUT)
	return False
    return True
    
def clean_service():
    for addr, val in service.copy().iteritems():
	if time.time() - val > TIMEOUT:
	    logger.info("more than %s seconds had happend since last time %s was served" % (TIMEOUT, addr))
	    service.pop(addr)


def found_action(record, services):
    dongle = record.dongle.address
    logger.info("sensorsdk device_found %s: %s[%s]" % (dongle , record.remote.address, record.remote.name))
    camps = getMatchingCampaigns(record.remote, enabled=True, classes=[SensorCampaign,])
    if len(camps) == 0:
	return False
    if len(camps) > 1:
	e = Exception("There's more than one campaign that matches, check settings")
	logger.exception(e)
	raise e

    logger.debug("found campaign")
    camp = camps[0]
    
    global clients
    if clients.get(dongle, None) is None:
	logger.debug("dongle not registered as client")
	logger.debug(clients)
	logger.debug(dongle)
	return False # there's no registered service I can't do a thing

    address = record.remote.address
    if not check_if_service(address):
	logger.debug("check_if_service failed")
	return False

    latest = SensorSDKRemoteDevice.objects.filter(
	address=address)
    if latest.count() > 0:
	for k in latest.all():

	    k.save() # mark elements as served, so timeout can exist
    service[address] = time.time()
    
    logger.info("handling device %s" % address)
    client = clients[dongle]
    channel=-1
    
    if isAIRcable(address):
	channel=1
    client.connect(record.remote.address, channel=channel)
    logger.debug("connecting")
    return client

CLOCK=compile(r'^CLOCK\|(?P<clock>(\d+)*.?(\d+)*)$')
READING=compile(r'^BATT\|(?P<batt>(\d+))\s*\|SECS\|(?P<secs>(\d+))\s*\|(?P<reading>.*)$')
NEXT=compile(r'^NEXT(?P<amount>(\d*))')

def process_pending_history(last_reg, last_time):
    last_reg['reading'] = last_reg['reading'][:-1] # remove the last |
    logger.debug(
        "reading line %s %s %s" % (
        last_time, 
        last_reg['batt'], 
        last_reg['reading']
	)
    )

    return (
	last_time, 
    	last_reg['batt'], 
	last_reg['reading']
    )

@transaction.commit_manually
def parse_readings(handler=None, readings=None, target=None, dongle=None):
    '''
	function used to push history readings into database itself, this function
	is called on a new thread so that rpc process does not get delayed
    '''
    logger.debug('started parse reading thread')
    for secs, batt, read in readings:
	handler.parsereading(device=target, seconds=secs, battery=batt, reading=read, dongle=dongle)
    transaction.commit()
    del handler, readings, target, dongle
    logger.debug('stopping parse reading thread')

def parse_history(model=None, history=None, target=None, success=False, 
	    dongle=None, pending=None, *args, **kwargs):

    readings = list()
    flag = False
    last_reg = None
    count_ = 0

    qs = SensorSDKRecord.objects.filter(remote__address=target)
    if qs.count() > 0:
	last_time = time.mktime(qs.latest('time').time.timetuple())
	logger.debug("using last time from last record")
    else:
	last_time = time.time()
	logger.debug("using now as last time")

    for line in history.splitlines():
	line = remove_control_chars(line.strip())
	if CLOCK.match(line):
	    last_time = float(CLOCK.match(line).groupdict()['clock'])
	    logger.debug("time sync %s" % last_time)
	elif READING.match(line):
	    if flag and len(last_reg['reading'].strip()) > 0:
		# ok we have stuff in our stack we need to push
		readings.append( process_pending_history(last_reg, last_time), )
		flag = False

	    reg = READING.match(line).groupdict()
	    last_time+=float(reg['secs'])
	    if NEXT.match(reg['reading']):
		flag = True
		last_reg = reg
		last_reg['reading']=""
	    else:
		logger.debug("reading line %s" % reg)
		readings.append( (last_time, reg['batt'], reg['reading']), )
	elif flag:
	    last_reg['reading']+= line.strip()
	    last_reg['reading']+="|"
	else:
	    logger.error("wrong line %s" % line)
    
    try:
	dongle = SensorSDKBluetoothDongle.objects.get(address=dongle)
	handler = SensorSDKRecord.getHandler(model)
    
	logger.debug('starting parse reading thread')
	Thread(target=parse_readings, kwargs={
	    'handler':handler, 
	    'readings': readings, 
	    'target': target, 
	    'dongle': dongle,
	}).start()
    except Exception, err:
	logger.exception(err)

    pending.pop(target)

handlers[signals.HANDLED_HISTORY]=parse_history

def handle_failed(pending, target, *args, **kwargs):
    logger.error("handle failed %s" % target)
    pending.pop(target)

handlers[signals.TOO_BUSY]=handle_failed
handlers[signals.CONNECTION_FAILED]=handle_failed
handlers[signals.HANDLED_LOST_CONNECTION]=handle_failed
