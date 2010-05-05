# -*- coding: utf-8 -*-
#    OpenProximity2.0 is a proximity marketing OpenSource system.
#    Copyright (C) 2009,2008 Naranjo Manuel Francisco <manuel@aircable.net>
#                                                                          
#    This program is free software; you can redistribute it and/or modify  
#    it under the terms of the GNU General Public License as published by  
#    the Free Software Foundation version 2 of the License.                
#                                                                          
#    This program is distributed in the hope that it will be useful,       
#    but WITHOUT ANY WARRANTY; without even the implied warranty of        
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         
#    GNU General Public License for more details.                          
#                                                                          
#    You should have received a copy of the GNU General Public License along
#    with this program; if not, write to the Free Software Foundation, Inc.,
#    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.            

# Speech on event interface
# this simple plugin will make SensorSDK speak out loud when ever a new reading
# is recognized

from net.aircable.utils import logger
from django.db import models
import os
from time import time



try:
    from sensorsdk import sdk
except Exception, err:
    from plugins.sensorsdk import models as sdk

TIMEOUT=6000 # 1 minute timeout
TARGET=""
last = dict()

if os.path.isfile('/etc/asound.conf'):
     for l in file('/etc/asound.conf').readlines():
        if l.find('device') > -1:
            l=l.strip()
            TARGET=l.split()[1]
            logger.debug("Found headset %s" % TARGET)

def speak(instance):
    remote = instance.remote
    if remote.address in last and \
            time()-last[remote.address]<TIMEOUT:
        return
    logger.info("going to speak for %s" % remote.address)

    text = 'got reading from %s %s' % ( remote.sensor, remote.friendly_name )
    if TARGET:
        os.system('''
            if [ -z "$(hcitool con | grep %s)" ]; then
                echo "" | text2wave -scale 3 | aplay -D plug:bluetoothraw -q -c 1 -t raw -f s16 -r 16000 -- 
            fi
        ''' % TARGET)
    os.system("echo "" | text2wave -scale 3 | aplay -D plug:bluetoothraw -q -c 1 -t raw -f s16 -r 16000 --" % text)
    last[remote.address]=time()

def handle_SensorSDKRecord_post_save(sender, instance, created, **kwargs):
    if isinstance(instance, sdk.SensorSDKRecord) and created:
	    speak(instance)
	    
models.signals.post_save.connect(handle_SensorSDKRecord_post_save)


