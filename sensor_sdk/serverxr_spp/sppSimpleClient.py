"""
    A simple client interface. Take this piece of code as example

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
'''
    Simple SPP Server Handler. You can use this server to talk to interactive
    nodes from the SensorSDK.
    
    Return codes:
	* 0: OK
	* 1: Arguments Error
	* 2: A non know kind of device tried to connect to us.
	* 3: Device got into Service Mode
'''


import net.aircable.spp.sppServer as sppServer

import logging, logging.config
import string
import getopt, sys
from  socket import error as SocketError

# global variables
version = "0.0.1"
SERVICE_MODE=False
__logger = None

# define our own logging methods based on python libraries
def log(text, level=logging.INFO):
    global __logger
    
    __logger.log(level, text)
    
def logInfo(text):
    log(text)
    
def logWarning(text):
    log(text,logging.WARNING)

def logError(text):
    log(text,logging.ERROR)
    
def logDebug(text):
    log(text,logging.DEBUG)

#basic functions
def grabFile(client):
    out="";
    
    while [ 1 ]:
	line=client.readLine()
	
	logDebug( "line=%s" % line )
	
	if ( line!=None and line.find("DONE")>-1 ):
	    logDebug("EOF")
	    break;
	out+=line
	out+="\n"
	
	client.sendLine("GO")

    logDebug("Got:\n%s" % out );
    return out

#modes handler
def handleServiceMode(client):
    logInfo("Getting into SERVICE mode")
    client.sendLine("SERVICE")
    
    #now the device is in service mode for 20 seconds, we can do what ever
    #we want to it.
    sys.exit(3)

def handleInteractive(client):
    global SERVICE_MODE
    
    if SERVICE_MODE:
	return handleServiceMode(client)
	
    history=None;
    menu=None;
	
    logInfo("Handling INTERACTIVE mode")

    client.sendLine("GO")
    
    while [ client.checkConnected() ]:
	try:
	    line = client.readLine()
            if line.find("HISTORY") > -1 :
		logInfo("Grabbing History")
    	        history=grabFile(client)
    	    
            elif line.find("MENU") > -1:
		logInfo("Graggin Menu")
    	        menu=grabFile(client)
	except SocketError:
	    logInfo("Disconnected")
	    return


def usage():
    global version

    print '''
SPP Simple Client %s

Usage %s [ <arguments> ]

Where <arguments> is any of:
    -s,--service=<serv>: Name of the profile to use.
    -c,--channel=<numb>: Number of channel to use.
    -d,--device=<hciX>:  Bluetooth adapter to use.
    -l,--logconf=<file>: File used to configure logger.
    -h,--help:		 This message window.
    
    
''' % ( version , sys.argv[0] );

# gets called when application starts
if __name__ == '__main__':
    global __logger

    try: # parse options
    
	opts,args=getopt.getopt( sys.argv[1:], 
		"s:c:d:l:h", 
		["service=","channel=","device=","logconf=","help"]
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
    
    #parse options
    for opt, arg in opts:
        if opt in ("-s", "--service"):
            serv = arg
        elif opt in ("-c", "--channel"):
            channel=int(arg)
        elif opt in ("-d", "--device"):
            dev = arg
        elif opt in ("-l", "--logconf"):
            logconf = arg
        elif opt in ("-h", "--help"):
            usage()
            sys.exit(0)
        else: # wow if we got here then we're screwed
            assert False, "unhandled option"
            sys.exit(1)
            
    #initializate global loggin
    logging.config.fileConfig(logconf)
    

    
    __logger = logging.getLogger("sppSimpleServer")
    
    log("Starting", logging.INFO)
    
    #start server, even though it's called server, once we got connected
    #we can call it a client.
    server = sppServer(
	    channel	=chan,
	    service	=serv,
	    device	=dev
	);
    
    #register sdp, then wait for connection
    #unregister sdp record to tell we're busy
    server.registerSDP()
    server.listenAndWait()
    server.unregisterSDP()
    
    
    
    #get type of device
    line = server.readLine()
    
    # check if it's one of the kind of devices we know
    if line.find("INTERACTIVE") > -1:
	handleInteractive(server)
    #you can add more types of devices here
    else:
	#ok you're not one of us, let's kick you out
	server.sendLine("ERROR, TYPE NOT KNOWN");
	server.disconnect()
	sys.exit(2)
        
    #if we got here, then we got the good way
    server.disconnect()
    sys.exit(0)
