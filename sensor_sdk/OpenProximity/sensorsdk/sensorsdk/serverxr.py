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

import const, dbus, dbus.service, rpyc, time
import signals
import net.aircable.procworker as procworker
from socket import error as SocketError
from net.aircable.openproximity.signals.uploader import *
from net.aircable.utils import *
from net.aircable.wrappers import Adapter
from threading import Thread, activeCount
from rpyc.utils.lib import ByValWrapper


def handle_device(adapter, target):
    logger.info("handle_device")
    return

class SensorAdapter(Adapter):
    def __init__(self, manager, max_conn = 7, *args, **kwargs):
        Adapter.__init__(self, *args, **kwargs)

	self.max_conn = max_conn
	self.current_connections = 0

	self.manager = manager
	self.connections = list()
	logger.debug("Initializated SensorAdapter")

    def disconnect(self, target, client, signal):
	try:
	    client.disconnect()
	    self.connections.remove(client)
	except:
	    pass
	self.manager.connections.pop(target)
	self.manager.tellListener(signal, dongle=self.bt_address, target=target)


    def connect(self, target, service="spp", channel=-1):
        if len(self.connections)>=self.max_conn:
	    self.manager.connections.pop(target)
	    self.manager.tellListener(signals.TOO_BUSY, dongle=self.bt_address, target=target)
	    return

	from net.aircable.spp.sppClient import sppClient
	client = sppClient(
	    target,
	    service=service,
	    device=self.bt_address,
	    channel=channel
	);

	try:
	    client.connect()
	    logger.info("Connected")
	    self.manager.tellListener(signals.CONNECTED, dongle=self.bt_address, target=target)
	    self.connections.append(client)
	    logger.debug("appended to list of connections")
	except Exception, err:
	    logger.exception(err)
	    self.disconnect(target, client, signals.CONNECTION_FAILED)
	    return

	model=client.readLine()
	history=""
	result=signals.HANDLED_OK
	try:
	    logger.info("Grabbing History")
	    history = client.shellGrabFile("history.txt")
	    logger.debug(history)
	    client.shellDeleteFile('history.txt')
	    if self.manager.sdk:
		self.manager.sdk.extra_action(
		    target=target, 
		    client=client, 
		    history=history, 
		    model=model)
	    client.shellPushIntoHistory("CLOCK|%s" % time.time())
	    time.sleep(2)
	    logger.info("work done %s" % target)
	except SocketError,err:
	    logger.error("lost connection %s" % target)
	    logger.exception(err)
	    result=signals.HANDLED_LOST_CONNECTION

	self.manager.tellListener(signals.HANDLED_HISTORY,
	    target=target, 
	    dongle=self.bt_address,
	    success=result==signals.HANDLED_OK,
	    history=history,
	    model=model)
	self.disconnect(target, client, result)
	del client

class SensorManager:
	__dongles = dict()
	bus = None
	manager = None
	__listener_sync = list()
	__listener_async = list()
	__sequence = list()
	__index = 0
	dongles=dict()
	connections=dict()
	sdk = None

	def __init__(self, bus, rpc=None):
	    logger.info("SensorManager created")
	    self.bus = bus
	    self.manager = dbus.Interface(bus.get_object(const.BLUEZ, const.BLUEZ_PATH), const.BLUEZ_MANAGER)
	    self.rpc = rpc
	    if self.rpc:
	        self.remote_listener=rpyc.async(self.rpc.root.listener)
	
	def set_sdk_admin(self, sdk):
	    self.sdk = sdk

	def exposed_add_dongle(self, dongle, max_conn):
	    logger.info("add_dongle %s, %s" % (dongle, max_conn))
	    self.dongles[dongle]=max_conn

	def exposed_refreshDongles(self):
	    logger.debug("refreshDongles")
	    if self.dongles is None or len(self.dongles)==0:
		self.__dongles=dict()
		self.tellListener(signals.NO_DONGLES)
		return False

	    for i in self.dongles:
		adapter = SensorAdapter(self,
		    max_conn=self.dongles[i],
		    bus=self.bus,
		    path=self.manager.FindAdapter(i))
		self.__dongles[i]=adapter
	    self.tellListener(signals.DONGLES_ADDED)
	    self.__generateSequence()
	    return True

	def __generateSequence(self):
    	    logger.debug('sdk generating sequence')
    	    priority=dict()
	    slots = 0
	    __sequence=list()
	    for dongle in self.__dongles.itervalues():
		__sequence.append(dongle)
	    self.__sequence=__sequence
	    self.__index = 0

	def __rotate_dongle(self):
	    if len(self.__sequence)==1: return

	    self.__index+=1
	    if self.__index>=len(self.__sequence): self.__index=0
	    self.tellListeners(signals.CYCLE_SDK_DONGLE, address=str(self.__sequence[self.__index].bt_address))
	    logger.debug('SDK dongle rotated')

	def tellListener(self, *args,**kwargs):
	    try:
		logger.info("telling listener, %s, %s" % (args, kwargs))
		self.remote_listener(*args,**kwargs)
	    except Exception, err:
		logger.exception(err)

	def exposed_connect(self, target, service="spp", channel=-1):
	    if target in self.connections:
		raise Exception("All ready connected to %s" % target)
	    self.connections[target]=None
	    logger.info("connect to %s" % target)
	    dongle=self.__sequence[self.__index]
	    t = Thread(target=dongle.connect, 
		kwargs={'target':target, 'service':service, 'channel': channel})
	    t.daemon=True
	    t.start()
	    self.connections[target]=t
	    logger.debug("running with %s threads" % activeCount())
