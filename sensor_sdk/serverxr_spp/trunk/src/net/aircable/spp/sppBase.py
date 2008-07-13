"""
    Base class for both sppClient and sppServer, rfcomm clients/servers
    wrappers.

    Copyright 2008 Wireless Cables Inc. <www.aircable.net>
    Copyright 2008 Naranjo, Manuel Francisco <manuel@aircable.net>

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
"""

import socket

from re import compile
from errors import *
import logging
import dbus

class sppBase:
	'''
	    Base class for rfcomm wrappers regardless of it\'s master or slave
	    behaviour.
	'''
        socket  = None;
        channel = None;
	service = None;
	device  = None;
	
	__logger  = None;
	bus 	  = dbus.SystemBus();
	__pattern = compile(r'.*\n');
	
	new_bluez_api = False;
	
	def logInfo(self, text):
	    self.__logger.info(text);
	
	def logWarning(self, text):
	    self.__logger.warning(text);
	
	def logError(self, text):
	    self.__logger.error(text);
	    
	def logDebug(self, text):
	    self.__logger.debug(text);
	    
	def __init_logger(self):
	    self.__logger = logging.getLogger('sppAircable');
	    console = logging.StreamHandler()
	    console.setLevel(logging.DEBUG)
	    formatter = logging.Formatter('%(name)-12s: %(levelname)-8s %(message)s')
	    console.setFormatter(formatter)
	    self.__logger.addHandler(console)
	    self.__logger.setLevel(logging.DEBUG)
	    
	def getDefaultDeviceAddress(self):
	    obj     = self.bus.get_object( 'org.bluez', '/org/bluez' )
	    manager = dbus.Interface( obj, 'org.bluez.Manager' )
	    obj     = self.bus.get_object( 'org.bluez', 
						    manager.DefaultAdapter() )
	    adapter = dbus.Interface( obj, 'org.bluez.Adapter' )
	    address = adapter.GetAddress()
	    return address
	    
	def getAdapterObjectPath(self):
            bluez_path   = self.bus.get_object( 'org.bluez', '/org/bluez' )
            manager = dbus.Interface( bluez_path, 'org.bluez.Manager' )

            return self.bus.get_object( 'org.bluez',
                            manager.FindAdapter(self.device)
                        )

	def __init__(self, socket):
	    '''
		    You use this constructor when you all ready have a socket
	        
		arguments:
		    socket descriptor
	    '''
	    self.__socket = socket;
	    self.__init_logger();

	def __init__( self,
			channel = -1, 
			service = 'spp',
			device  = None  ):
	    '''
		More general constructor. You will use this one when you want
		sppClient to make the conneciton.
	    
		arguments:
		    channel: Channel to be used for establishing the connection.
		    service: Service to use when you want sppClient to do service
			     Discovery.
		    device:  Bluetooth Address of the local device you want to 
			     use for making the connection, None for default.
	    '''
	    self.__init_logger();

	    self.channel = int(channel);
	    self.service = service;
	    
	    if not device:
		device = self.getDefaultDeviceAddress()
	    
	    self.device  = device;
	    
	    self.logInfo("sppBase.__init__");
	    self.logInfo("Channel: %s" % channel );
	    self.logInfo("Service: %s" % service );
	    self.logInfo("Device: %s"  % device  );

	def checkConnected(self, message =''):
		if self.socket == None:
		    raise SPPNotConnectedException, message
		    
	def disconnect(self):
	    self.checkConnected("Can't close if it's opened");
	    self.logInfo("Closing socket");
	    self.socket.shutdown(socket.SHUT_RDWR);
	    self.socket.close()

	def send(self, text):
	    '''
		Send something to the port.
	    
		Arguments: what to send
	    '''
	    self.checkConnected('Can\'t send if not connected');
		
	    ret = self.socket.sendall(text, socket.MSG_WAITALL);
	    
	    if ret and int(ret) != text.length():
		raise SPPException, "Failed to send all data"
	
	def sendLine(self, text):
	    """
		Send a line instead of only text, this will add \n
	    """
	    self.send("%s\n" % text)

	def read(self, bytes=10):
	    '''
		Read binary data from the port.
	    
		Arguments:
		    bytes: Amount of bytes to read
	    '''
	    self.checkConnected('Can\'t read if not connected');
		
	    return self.socket.recv(bytes);

	def readLine(self):
	    '''
		Reads until \n is detected
	    '''
	    out = buffer("");
		
	    while ( 1 ):
		out += self.read(1);

		if self.__pattern.match(out):
			return out.replace('\n', '');
