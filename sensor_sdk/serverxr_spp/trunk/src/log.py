"""
    Logging functions: In this module you will find some basic logging
    functions wrapper used by AIRcable in Smart project.
    This functions act as wrappers around python loging framework.
    
    Copyright 2008,2009 Wireless Cables Inc. <www.aircable.net>
    Copyright 2008,2009 Naranjo, Manuel Francisco <manuel@aircable.net>
    
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
import logging.config

__all__ = ["logInfo", "logDebug", "logWarning", "logError", "logException", "initLog"]

__logger=None

def __sanitize():
	global __logger
	if __logger is None:
		raise Exception("initLog should  be called first")

def _log(text, level=logging.INFO):
	'''Internal function used as wrapper arround __logger'''
	__sanitize()
	global __logger
	__logger.log(level, text)
    
def logInfo(text):
	'''Log argument in the Info log'''
	_log(text)
    
def logWarning(text):
	'''Log argument in the warning log'''
	_log(text,logging.WARNING)

def logError(text):
	'''Log argument in the error log'''
	_log(text,logging.ERROR)
	    
def logDebug(text):
	'''Log argument in the debug log'''
	_log(text,logging.DEBUG)
    
def logException(text):
	global __logger
	__logger.exception(text)

def initLog(logconf):
	'''Initializite logger, argument is the file with the settings'''
	global __logger
	logging.config.fileConfig(logconf)
	__logger = logging.getLogger("sppSimpleServer")
	logInfo('Logging started')

