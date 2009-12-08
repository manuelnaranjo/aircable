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

# agent plugin
# defines new clases for db integration
try:
    from sensorsdk import models
except:
    from plugins.sensorsdk import models

from django.utils.translation import ugettext as _
from django.db import models as mod
from re import compile
from datetime import datetime
import math

class LinkTHDevice(models.SensorSDKRemoteDevice):
    
    @staticmethod
    def getMode():
	'''Let the sensorsdk engine know which node we are handling'''
	return "monitor-linkth"

    @staticmethod
    def getChartVariables():
	return ['temperature_c', 'battery']
	
    @staticmethod
    def getRecordClass():
        return LinkTHRecord

owi=compile(r'OWI\|(?P<temp_c>[-+]?[0-9]*\.?[0-9]+).*')
class LinkTHRecord(models.SensorSDKRecord):
    temperature_c = mod.FloatField(help_text=_('readed temperature in celsius'))
    
    @staticmethod
    def getMode():
	'''Let the sensorsdk engine know which node we are handling'''
	return "monitor-linkth"
    
    @staticmethod
    def parsereading(device=None, seconds=None, battery=None, reading=None, dongle=None):
	'''This method expects to get a valid reading, generating a record out of it'''
	
	#extract parameters from reading string
	m = owi.match(reading)
	if not m:
	    print "NO MATCH", reading
	    return
	m=m.groupdict()
	
	#find ambient device, or create if there's none yet created
	device,created=LinkTHDevice.objects.get_or_create( address=device,
	    defaults={
		'friendly_name': _('Auto Discovered LinkTH Sensor'),
		'sensor': _('Linkth'),
		'mode': _('Monitor'),
	    })

	record = LinkTHRecord()
	record.remote=device
	record.dongle=dongle
	record.temperature_c=float(m['temp_c'])
	record.time=datetime.fromtimestamp(seconds)
	record.battery=battery
	record.save()
