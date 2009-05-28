"""
    A simple client interface. Take this piece of code as example

    Copyright 2008, 2009 Wireless Cables Inc. <www.aircable.net>
    Copyright 2008, 2009 Naranjo, Manuel Francisco <manuel@aircable.net>

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
'''
    Simple SPP Server Handler. You can use this server to talk to monitor
    nodes from the SensorSDK.
    
    Return codes:
    * 0: OK
    * 1: Arguments Error
    * 2: A non know kind of device tried to connect to us.
    * 3: Device got into Service Mode
'''

import net.aircable.spp.sppServer as sppServer

import string, time, getopt, sys, os
from  socket import error as SocketError
from re import compile
import time, dbus

from log import *
from pluginsystem import pluginsystem

version="1.0alpha1"    
    
def handleDevice(client, plugin):
    history=""
    
    nodeid=client.peer[0]
    siteid=client.device
    
    try:                    
        logInfo("Grabbing History")
        history = client.shellGrabFile("history.txt")
        client.shellDeleteFile('history.txt')
        
	if getattr(plugin, 'extra_actions', None) is not None:
	    plugin.extra_actions(client)
	
        #this might fail, but we don't bother it will be catched by except
        client.shellPushIntoHistory("CLOCK|%s" % time.time())
	time.sleep(2)
        client.disconnect()

    except SocketError:
        logInfo("Disconnected")
    
    history=plugin.parse_history(nodeid, siteid, history)
    
    print history

def main_loop(chan, serv, dev):
	logInfo("Starting server at channel: %s" % chan)

	#start server, even though it's called server, once we got connected
	#we can call it a client.
	server = sppServer(
		channel    =chan,
		service    =serv,
		device    =dev
	);
	
	mode = server.iface.GetProperties()['Discoverable']
	disc_timeout = server.iface.GetProperties()['DiscoverableTimeout']
	name = server.iface.GetProperties()['Name']
	
	logDebug('Currrent mode: %s' % mode)
	logDebug('Current discoverable timeout: %s' % disc_timeout)
	logDebug('Current name: %s' % name)
	
	logInfo('Settings configuration for dongle')
	server.iface.SetProperty('Discoverable', True)
	server.iface.SetProperty('DiscoverableTimeout', dbus.UInt32(0))
	server.iface.SetProperty('Name', 'AIRcable SensorSDK')

	#register sdp, then wait for connection
	#unregister sdp record to tell we're busy
	server.registerSDP()
	server.listenAndWait()
	server.unregisterSDP()
	#server.socket.settimeout(0) # async reads

	if not (server.peer[0].startswith("00:50:C2:") or server.peer[0].startswith("00:25:BF:")):
		#someone is trying to break our security
		server.sendLine("You're not allowed to enter bye bye")
		server.disconnect()
		return

	#get type of device
	line = server.readLine()
	
	for plugin in pluginsystem.get_plugins():
	    if line.lower().find(plugin.ID) > -1:
		logInfo("Found plugin for type: %s" % plugin)
		return handleDevice(server, plugin)

	#ok you're not one of us, let's kick you out
	logError("Not Known device")
	server.sendLine("ERROR, TYPE NOT KNOWN");
	server.disconnect()
	return

def usage():
	print '''
SPP Simple Client %s

Usage %s [ <arguments> ]

Where <arguments> is any of:
    -s,--service=<serv>:     Name of the profile to use.
    -c,--channel=<numb>:     Number of channel to use.
    -d,--device=<hciX>:      Bluetooth adapter to use.
    -l,--logconf=<file>:     File used to configure logger.
    -h,--help:             This message window.
''' % (version , sys.argv[0]);

# gets called when application starts
if __name__ == '__main__':
	global __logger

	try: # parse options
		opts, args = getopt.getopt(sys.argv[1:],
			"s:c:d:l:h",
			["service=", "channel=", "device=", "logconf=", "help"]
		)
	
	except getopt.GetoptError, err: 
		# in case of errors
		print str(err)
		usage()
		sys.exit(1)

	#default options                                                    
	serv = "spp"
	chan = 1
	dev = None
	logconf = "spplog.conf"
	
	#testing options
	test_node = None
	test_history = None
    
	#parse options
	for opt, arg in opts:
		if opt in ("-s", "--service"):
			serv = arg
		elif opt in ("-c", "--channel"):
			chan = int(arg)
		elif opt in ("-d", "--device"):
			dev = arg
		elif opt in ("-l", "--logconf"):
			logconf = arg
		elif opt in ("-h", "--help"):
			usage()
			sys.exit(0)			
        	else: # oops wrong option
			assert False, "unhandled option"
			sys.exit(1)
            
	#initializate global loggin
	initLog(logconf)
	
	pluginsystem.find_plugins()
	
#	while [ 1 ]:
#		try:
	main_loop(chan, serv, dev)
#		except Exception, err:
#			logException("Not handled exception: %s" % err)

#	sys.exit(0)

