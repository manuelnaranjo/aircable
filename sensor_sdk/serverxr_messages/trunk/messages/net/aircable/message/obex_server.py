#!/usr/bin/python
""" This file is used for managing obex-server sessions, as every good project
    it uses obex-data-server for the hard part of the work.
 
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

import dbus
import dbus.decorators
import dbus.glib
import gobject
import sys
import re
import inspect
import os
import logging
from signal import *
from dbus.bus import *

from obex_message import ObexMessage

def ods_disposed_cb(*kargs):
    if len(kargs) >= 3:
	if (kargs[0]=='org.openobex' and kargs[2]==''):
	    logging.info( 'ODS has gone down, time to go' )
	    main_loop.quit()
	    sys.exit(0)


class MessageServer:
    """ Main class used for receiving Obex Messages """
    
    __bt_address = '00:00:00:00:00:00'
    __profile = 'opp' # opp = Obex Object Push
    __manager = None
    ReceivedCB = None
    StoppedCB = None
    ErrorCB = None
    
    __sessions = dict()

    def __transfer_started_cb(self, filename, local_path, size, path, *args):
	self.__sessions[path].__local_path = local_path
	logging.info('Session: %s file: %s' % (path , local_path))
	
    def __transfer_completed_cb(self, path, *kargs):
	session = self.__sessions[path]
	logging.debug('Session: %s Transfer completed' % path )

	try:
		f = open( session.__local_path , 'r' )
		__content = f.read()
		logging.debug('Content:\n%s' % __content )
		os.remove(session.__local_path)
		logging.debug('Deleted file: %s' % session.__local_path )
	except:
		logging.warning('Error while reading content') 

	try:
		self.received_cb( __content, session.info )
	except:
		logging.debug('Session: %s has no or a wrong parent asociated'
			% path)
		print sys.exc_info()


    def received_cb ( self, content , session_info ):
	""" Internal call back that's called when a file has been received """
	logging.debug ( 'Received: %s' % content )
	Message = ObexMessage ( content, session_info[ 'BluetoothAddress' ] )
	if self.ReceivedCB != None:
	    self.ReceivedCB ( Message )
    
    def __init__(self, path = '/tmp/message' ):
	""" Main and only constructor by now, quite useless from the outside
	    we do stuff like connecting to dbus, and doing some sanity checks.
	    We don't want to start all the process and then in the last minute
	    find out there's no ods connected to dbus ;)
	"""
	logging.debug ( 'Connecting to DBUS'  )
	bus = dbus.SystemBus()	 
	logging.debug ( 'Connected to DBUS' )
	
	logging.debug ( 'Checking for ODS' )
	manager_obj = bus.get_object('org.openobex', '/org/openobex')	
	logging.debug ( 'ODS is up and ready'  )
	
	self.__manager = dbus.Interface(manager_obj, 'org.openobex.Manager')
	self.__path = path
	
	bus.add_signal_receiver( 
	    ods_disposed_cb, 
	    signal_name = 'NameOwnerChanged'
	)
	
	logging.info ( 'System up and ready, you can start the server now' )
    
    def __del__( self ):
	logging.info( 'Obex Server going down, bye')
	exit()

    def setServerAddress( self,  bt_address = '00:00:00:00:00:00' ):
	""" You should call this function if you want the obex-server to attach 
	    to a specific bluetooth dongle, or wihtout arguments to attach to all
	"""
        logging.debug ( 'Changing target to %s ' % bt_address )
	self.__bt_address=bt_address
    
    def setServerProfile( self, profile = 'opp' ):
	""" By default the server shows OPP (Obex Object Push) but you can also
	    use ftp (FTP over OBEX)
	"""
	logging.debug ( 'Setting profile from %s to %s ' 
	    % (self.__profile, profile) )
	self.__profile = profile
	
    def __started_cb(self):
	""" Call back for the ObexServer, not used from outside """
	logging.debug( "Server Started" );
    	
    def __stopped_cb(self):
	""" Call back for the ObexServer, not used from outside """
	logging.debug( "Server Stopped" );
	if self.StoppedCB != None :
	    self.StoppedCB

    def __closed_cb(self):
	""" Call back for the ObexServer, not used from outside """
	logging.debug( "Server Closed" )

    def error_ocurred_cb(self, error_name, error_message ):
	""" Call back for the ObexServer, not used from outside """
	logging.info( "Error Ocurred: %s: %s" % (error_name, error_message ))
	if self.ErrorCB != None:
	    self.ErrorCB( error_name, error_message )

    def __session_created_cb(self, session_object_path):
	""" Call back for the ObexServer, not used from outside """
	logging.debug( "Session Created: %s" % session_object_path )
	session_info = self.__server.GetServerSessionInfo( 
	    session_object_path )
	logging.info( 'Created Session with: %s' % 
	    session_info['BluetoothAddress'] )
	self.__sessions[session_object_path] = ObexSession( session_info )
	
    def __session_removed_cb(self, session_object_path):
	""" Call back for the ObexServer, not used from outside """
	logging.debug( 'Session Removed: %s' % session_object_path )
	
    def __mighty_helper(self, filename, local_path, size, path, *args):
	print path
	print filename
	print local_path
	print size
	

	
    def startServer( self , path = '/tmp/message' , pairing = False ):
	""" Starts the server it self, prepare for receiving connections
	    Arguments:
		needed:
		    path: Where to store the received messages, this is a
			temporary folder as each message will be deleted ASAP
		optional:
		    pairing: Server will ask for pairing information to all
			it's peers. 
	""" 
	server_path = self.__manager.CreateBluetoothServer( 
	    self.__bt_address,
	    self.__profile,
	    pairing );
	logging.debug ('Server object: %s' % server_path)
	
	#now get the real server Object
	self.bus = dbus.SystemBus()
	server_obj = self.bus.get_object('org.openobex', server_path)
	self.__server = dbus.Interface(server_obj, 'org.openobex.Server')
	
	#Connect to org.openobex.Server signals
	self.__server.connect_to_signal('Started', self.__started_cb)
	self.__server.connect_to_signal('Stoped', self.__stopped_cb)
	self.__server.connect_to_signal('Closed', self.__closed_cb)
	self.__server.connect_to_signal('ErrorOcurred', self.error_ocurred_cb)
	self.__server.connect_to_signal('SessionCreated',
						self.__session_created_cb)
	self.__server.connect_to_signal('SessionRemoved',
						self.__session_removed_cb)
						
	#Connect to org.openobex.ServerSession signals
	self.bus.add_signal_receiver( 
		self.__transfer_started_cb,
		signal_name = 'TransferStarted',
		dbus_interface = 'org.openobex.ServerSession',
		path_keyword = 'path'
	    	#arg0 = 'filename',
	    	#arg1 = 'local_path',
	    	#arg2 = 'size'
	)
	
	self.bus.add_signal_receiver(
		self.__transfer_completed_cb,
		signal_name = 'TransferCompleted',
		dbus_interface = 'org.openobex.ServerSession',
		path_keyword = 'path'
#		sender_keyword = 'sender' ,
#		destination_keyword = 'destination' ,
#		interface_keyword = 'interface' ,
#		member_keyword = 'member' ,
#		message_keyword = 'message'
#		
	)
	
	logging.info('Starting....')
	
	self.__server.Start( path, True, False ) # No auto accept

    def stopServer ( self ):
	""" Stops the server, it will close any connection that's going on
	    according to ODS specs
	"""
	self.__server.Stop()
	
    def setReceivedFileCallBack( self , receivedCB ):
	""" You can define (and actually you need if you want to make any 
	    usefull with this), this function will be called in a new thread
	    when ever a new file has been received, file content will be passed
	    as argument, so make sure your transfers are short.
	"""
	self.ReceivedCB = receivedCB

class ObexSession:
    """ This class is used internally to provide session backend """
    def __init__(self, session_info):
	""" internal builder """
	self.info = session_info
	logging.debug('Session created')
	
if __name__ == '__main__':

    logging.basicConfig(level=logging.DEBUG,
                format='%(asctime)s %(levelname)s %(message)s',
                filename='/tmp/obex-messages.log',
                filemode='w')
    console = logging.StreamHandler()
    console.setLevel(logging.DEBUG)
    
    formatter = logging.Formatter('%(levelname)-8s %(message)s')
    console.setFormatter(formatter)
    
    logging.getLogger('').addHandler(console)
    
    a = MessageServer()
    a.startServer('/tmp/airm')
    
    gobject.threads_init()
    dbus.glib.init_threads()
    
    main_loop = gobject.MainLoop()
    main_loop.run()
    
