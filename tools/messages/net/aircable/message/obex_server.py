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

import logging
from signal import *

from obex_message import ObexMessage

class MessageServer:
    """ Main class used for receiving Obex Messages """
    
    __bt_address = '00:00:00:00:00:00'
    __profile = 'opp' # opp = Obex Object Push
    __bus = None
    __manager = None
    ReceivedCB = None
    StoppedCB = None
    ErrorCB = None
    

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
	self.__bus = dbus.SystemBus()	 
	logging.debug ( 'Connected to DBUS' )
	
	logging.debug ( 'Checking for ODS' )
	manager_obj = self.__bus.get_object('org.openobex', '/org/openobex')	
	logging.debug ( 'ODS is up and ready'  )
	
	self.__manager = dbus.Interface(manager_obj, 'org.openobex.Manager')
	self.__path = path
	
	logging.info ( 'System up and ready, you can start the server now' )

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
	    % (self.profile, profile) )
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
	session_info = self.__server.GetServerSessionInfo( session_object_path )
	logging.info( 'Created Session with: %s' % 
	    session_info['BluetoothAddress'] )
	session = ObexSession( session_object_path, session_info, self )
	
    def __session_removed_cb(self, session_object_path):
	""" Call back for the ObexServer, not used from outside """
	logging.debug( 'Session Removed: %s' % session_object_path )
	
    def startServer( self , path , pairing = False ):
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
	server_obj = self.__bus.get_object('org.openobex', server_path)
	self.__server = dbus.Interface(server_obj, 'org.openobex.Server')
	
	#Connect to signals
	self.__server.connect_to_signal('Started', self.__started_cb)
	self.__server.connect_to_signal('Stoped', self.__stopped_cb)
	self.__server.connect_to_signal('Closed', self.__closed_cb)
	self.__server.connect_to_signal('ErrorOcurred', self.error_ocurred_cb)
	self.__server.connect_to_signal('SessionCreated', self.__session_created_cb)
	self.__server.connect_to_signal('SessionRemoved', self.__session_removed_cb)
	
	self.__server.Start( self.__path, True, True )

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
    
    __parent = None
    
    def __init__(self, session_path, session_info, message_server):
	""" internal builder """
	logging.debug("Initialization ObexSession for path: %s" % session_path)
	self.__path = session_path
	self.__info = session_info
	self.__parent = message_server
	self.bus = dbus.SystemBus()
	
	#Get session object
	session_obj = self.bus.get_object('org.openobex', session_path)
	self.session = dbus.Interface(session_obj, 'org.openobex.ServerSession')
	
	#Connect signals
	self.session.connect_to_signal('Disconnected', self.__disconnect_cb)
	self.session.connect_to_signal('Cancelled', self.__cancelled_cb)
	self.session.connect_to_signal('TransferCompleted', 
		self.__transfer_completed_cb)
	self.session.connect_to_signal('ErrorOcurred', 
		self.__error_ocurred_cb)
	
	self.__local_path = self.session.GetTransferInfo()['LocalPath']
	logging.debug('Session: %s file: %s' % (self.__path , 
	    self.__local_path))
	#self.session.Accept()
	
    def __transfer_completed_cb(self):
	logging.debug('Session: %s Transfer completed' % self.__path )
	
	f = open( self.__local_path , 'r' )
	
	self.__content = f.read()
	logging.debug('Content:\n%s' % self.__content )
	
	try:
	    self.__parent.received_cb( self.__content, self.__info )
	except:
	    logging.debug('Session: %s has no or a wrong parent asociated' % 
		self.__path)
	    print sys.exc_info()

	
    def __disconnect_cb(self):
	logging.debug('Session %s has been disconnected' % self.__path )
	try:
	    self.__parent.error_ocurred_cb( 'disconnected', 
		self.__info['BluetoothAddress'] ) 
	except:
	    logging.debug('Session: %s has no or a wrong parent asociated' %
		self.__path )

	
    def __cancelled_cb(self):
	logging.debug('Session %s has been cancelled' % self.__path)
	try:
	    self.__parent.error_ocurred_cb( 'cancelled', 
		self.__info['BluetoothAddress'] )
	except:
	    logging.debug('Session: %s has no or a wrong parent asociated' %
		self.__path )
	        
    def __error_ocurred_cb(self, error_name, error_message):
	logging.debug('Session %s, error ocurred %s: %s' % 
	    (  self.__path , error_name, error_message ) )

	try:
	    self.__parent.error_ocurred_cb( error_name , 
		    '%s: %s' % (self.__info['BluetoothAddress'] , 
			error_message ) )
	except:
	    logging.debug( 'Session: %s has no or a wrong parent asociated' %
		self.__path )
    
	
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
    
