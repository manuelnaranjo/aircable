#!/opt/local/bin/python2.5
#
# Copyright 2009 Naranjo Manuel Francisco <manuel@aircable.net> 
# Copyright 2009 Wireless Cables Inc www.aircable.net
#
# Licensed under the Apache License, Version 2.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at 
#
#	http://www.apache.org/licenses/LICENSE-2.0 
# 
# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an "AS IS" BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and 
# limitations under the License. 

from Cheetah.Template import Template
import sys

def __stream(stream):
    stream=stream.lower()
    if stream=='master':
	return 'M'
    elif stream=='slave':
	return 'S'
    elif stream=='uart':
	return 'U'
    raise Exception("Not Known Stream")

def PRINT(stream):
    return 'PRINT%s' % __stream(stream)

def INPUT(stream):
    return 'INPUT%s' % __stream(stream)
    
def TIMEOUT(stream):
    return 'TIMEOUT%s' % __stream(stream)

def GET(stream):
    return 'GET%s' % __stream(stream)
    
def STTY(stream):
    return 'STTY%s' % __stream(stream)
    
def CAPTURE(stream):
    return 'CAPTURE%s' % __stream(stream)

def DISCONNECT(stream):
    stream = stream.lower()
    if stream == 'slave':
	return 'A = disconnect 0'
    elif stream == 'master':
	return 'A = disconnect 1'
	
def DEF(name):
    return globals().get(name, None) is not None

if __name__ == '__main__':
    if len(sys.argv) < 2:
	print "Usage %s <file>" % sys.argv[0]
	sys.exit(1)
    t = Template(file=sys.argv[1])
    t.INPUT=INPUT
    t.PRINT=PRINT
    t.TIMEOUT=TIMEOUT
    t.GET=GET
    t.STTY=STTY
    t.CAPTURE=CAPTURE
    t.DISCONNECT=DISCONNECT
    t.DEF=DEF
#    print t.generatedClassCode()
    print str(t)

