"""
    A simple class for connecting to spp servers.

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

__pattern = compile(r'.*\n');

def getDefaultDeviceAddress():
    pass

class sppClient:
	'''
	    Simple wrapper for an spp client, actually it is an rfcomm client, 
	    not only spp.
	'''
        __socket  = None;
	__address  = None;
        __channel = None;
	__service = None;
	__device  = None;
	
	def __init__(self, socket):
	    '''
		    You use this constructor when you all ready have a socket
	        
		arguments:
		    socket descriptor
	    '''
	    self.__socket = socket;

	def __init__( self,
			target  = '', 
			channel = -1, 
			service = 'spp',
			device  = getDefaultDeviceAddress() ):
	    '''
		More general constructor. You will use this one when you want
		sppClient to make the conneciton.
	    
		arguments:
	    	    target:  Bluetooth Address of the device you want to connect to,
		    channel: Channel to be used for establishing the connection.
		    service: Service to use when you want sppClient to do service
			     Discovery.
		    device:  Bluetooth Address of the local device you want to 
			     use for making the connection.
	    '''
	    
	    self.__address = target;
	    self.__channel = int(channel);
	    self.__service = service;
	    self.__device  = device;

	def connect(self):
	    '''
		Starts the connection
	    '''
	    if self.__channel < 1:
		    raise SPPNotImplemented, 'Profiles resolving isn\'t implemented yet'
		    
	    if (self.__socket == None):
		print 'creating socket'    
		self.__socket = socket.socket( socket.AF_BLUETOOTH, 
						socket.SOCK_STREAM, 
						socket.BTPROTO_RFCOMM );
	    #Let BlueZ decide outgoing port
	    print 'binding to %s, %i' % ( self.__device , 0 )
	    self.__socket.bind( (self.__device,0) );
		
	    print 'connecting to %s, %i' % ( self.__address, self.__channel )
	    self.__socket.connect( (self.__address, self.__channel) );

	def __checkConnected(self, message =''):
		if self.__socket == None:
		    raise SPPNotConnectedException, message

	def send(self, text):
	    '''
		Send something to the port.
	    
		Arguments: what to send
	    '''
	    self.__checkConnected('Can\'t send if not connected');
		
	    self.__socket.sendall(text);

	def read(self, bytes=10):
	    '''
		Read binary data from the port.
	    
		Arguments:
		    bytes: Amount of bytes to read
	    '''
	    self.__checkConnected('Can\'t read if not connected');
		
	    return self.__socket.recv(bytes);

	

	def readLine(self):
	    '''
		Reads until \n is detected
	    '''
	    out = buffer("");
		
	    while ( 1 ):
		out += self.read(1);

		if __pattern.match(out):
			return replace(out, '\n', '');

if __name__ == '__main__':
    import sys
    
    if ( len(sys.argv) < 4 ):
	print "Usage %s <target> <channel> <adapter>" % (sys.argv[0])
	sys.exit(1)

    a = sppClient(
	    target	=sys.argv[1],
	    channel	=sys.argv[2],
	    device	=sys.argv[3]
	);
    
    a.connect()
    
    a.readLine();
    
    a.send('1234');
