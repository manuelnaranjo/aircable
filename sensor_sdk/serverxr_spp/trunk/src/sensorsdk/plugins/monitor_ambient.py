# -*- coding: utf8 -*-

''' Sample node history manager '''

import time
from re import compile

UNITS="°C"
ID="monitor-ambient"

__CLOCK=compile(r'CLOCK\|(\d+).*')
__READING=compile(r'BATT\|(\d+)\|SECS\|(\d+)\|TAMB\|(\d+)')

def parse_history(Node=None, SiteID=None, history=None):
    '''
    This function gets as arguments a string reading, return value is ignored.
    This function can be used to gather more information about the reading
    other than milli volts from AIO0, AIO1.
    '''
    init = int(time.time())
    out = list()
    
    for line in history.splitlines(False):
	print line
	if __CLOCK.match(line) is not None:
	    init=int(__CLOCK.split(line)[1])
	elif __READING.match(line) is not None:
	    tokens=__READING.split(line)
	    reading = dict()
	    reading['batt'] = int(tokens[1])
	    reading['time'] = init + int(tokens[2])
	    init = reading['time']
	    reading['millis'] = int(tokens[3])
	    out.append(reading)
    return out

def convert_milli_units(reading):
    '''
    This function will get called when ever data in milli volts needs to be
    displayed as <UNITS>
    '''
    print reading
    return None

def convert_units_milli(reading):
    '''
    This function will get called when ever data in <UNITS> needs to be converted
    to milli volts
    '''
    print reading
    return None

def extra_actions(Node):
    '''
    If you want extra actions to be executed once the unit gets connected, but
    after history has been exchanged, then you need to implement this method
    '''
    print Node
    pass
