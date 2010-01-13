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

from net.aircable.utils import logger
from django.utils.translation import ugettext as _
from django.db import models as mod
from re import compile
from datetime import datetime
import math

class AmbientDevice(models.SensorSDKRemoteDevice):
    Ro = mod.FloatField(help_text=_('thermistor resistance at lab temperature'),
	default=24578.5)
    R = mod.FloatField(help_text=_('resistor used in voltage divider'),
	default=22000)
    alpha = mod.FloatField(help_text=_('scale value taken from exponential aproximation'),
	default=0.0442286)
    Vref = mod.FloatField(help_text=_('Voltage reference'),
	default=1.8)
	
    def getTemperature(self, reading):
	# calculate real temperature
	if (self.Vref/reading-1) < 0:
	    out = -9000 # return back a non real temperature
	out= (-1.0/self.alpha)*math.log((self.Vref/reading -1)*self.R/self.Ro)
	logger.info('getTemperature: %s->%s°C' %(reading, out))
    
    @staticmethod
    def getMode():
	'''Let the sensorsdk engine know which node we are handling'''
	return "monitor-ambient"

    @staticmethod
    def getChartVariables():
	return ['temperature', 'battery']
	
    @staticmethod
    def getRecordClass():
        return AmbientRecord

tamb=compile(r'TAMB\|(?P<temperature>\d+)$')
class AmbientRecord(models.SensorSDKRecord):
    temperature = mod.FloatField(help_text=_('temperature reading, from -9999.99 to 9999.99'))
    
    @staticmethod
    def getMode():
	'''Let the sensorsdk engine know which node we are handling'''
	return "monitor-ambient"
    
    @staticmethod
    def parsereading(device=None, seconds=None, battery=None, reading=None, dongle=None):
	'''This method expects to get a valid reading, generating a record out of it'''
	
	#extract parameters from reading string
	m = tamb.match(reading)
	if not m:
	    logger.error("NO MATCH %s" % reading)
	    return
	temp=m.groupdict()['temperature']
	
	#find ambient device, or create if there's none yet created
	device,created=AmbientDevice.objects.get_or_create( address=device,
	    defaults={
		'friendly_name': _('Auto Discovered Ambient Sensor'),
		'sensor': _('Ambient'),
		'mode': _('Monitor'),
	    })
	temp=device.getTemperature(float(temp))
	
	record = AmbientRecord()
	record.remote=device
	record.dongle=dongle
	record.temperature=temp
	record.time=datetime.fromtimestamp(seconds)
	record.battery=battery
	record.save()
