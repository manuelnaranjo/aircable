#!/usr/bin/python
""" This class represents an Obex Message received via bluetooth.
    
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

import logging

class ObexMessage:
    """ This class describes an Obex Messages """
    
    __bt_address = '00:00:00:00:00:00'
    __message = None
    __dict = dict()
    
    
                
    def __init__( self , message , source  ):
	""" Main and only constructor by now.
	    Arguments:
		* message: Content from the .vnt file.
		* source: Bluetooth Address that sent this file.
	"""
	self.__message = message
	self.__bt_address = source
	self.__parse()
	
    def __parse( self ):
	for i in self.__message.splitlines():
	    splited = i.split(':', 1)
	    try:
		self.__dict[splited[0]] = splited[1]
	    except:
		print "Message format error at line: %s" % i
		
	logging.debug( self.__dict  )

    def getBody():
	return self.__dict['BODY:']
	
    def getSource():
	return self.__bt_address
    
    def getMessage():
	return self.__message
	
