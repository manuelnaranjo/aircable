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

# defines new clases for db integration
from net.aircable.utils import logger
import sys
models = None

try:
    from sensorsdk import models
except Exception, err:
    from plugins.sensorsdk import models

logger.debug('found sensorsdk.models')

from django.utils.translation import ugettext as _
from django.db import models as mod
from re import compile
from datetime import datetime
import math

class GenericLinearDevice(models.SensorSDKRemoteDevice):
    slope = mod.FloatField(help_text=_("slope value for this sensor, this value is reflected to the device on the next connection cycle"),
	default=10)
    offset = mod.FloatField(help_text=_("offset value for this sensor, this value is reflected to the device on the next connection cycle"),
	default=10)
    units = mod.CharField(help_text=_("displayable unit for this sensor"),
	default="Celcius Degrees", max_length=40)

    def getValue(self, reading):
	out = int(reading) * self.slope + self.offset
	logger.info("%s -> %s [%s]" % ( reading, out, self.units))
	return out

    def getUnits(self, field):
	return self.units
	
    def getUpdateLines(self, slope, offset):
	new_mode = None
	new_slope = None
	new_offset = None
	
	if abs(self.slope) < 1.:
	    slope = 1 / slope
	if abs(slope - self.slope)/abs(self.slope) > 0.01:
	    new_slope = int(1./self.slope) if abs(self.slope) < 1.0 else int(self.slope)
	    new_mode = 'A' if abs(self.slope) < 1.0 else 'B'
	if abs(offset - self.offset)/abs(self.offset) > 0.01:
	    new_offset = int(self.offset)
	out=dict()
	if new_mode:
	    out['500'] = new_mode
	if new_slope:
	    out['501'] = new_slope
	if new_offset:
	    out['502'] = new_offset
	return out
    
    @staticmethod
    def getMode():
	'''Let the sensorsdk engine know which node we are handling'''
	return "monitor-generic-linear"

    @staticmethod
    def getChartVariables():
	return ['reading', 'reading_mv', 'battery']
	
    @staticmethod
    def getRecordClass():
        return GenericLinearRecord

lin=compile(r'LIN\|(?P<value>\d+).*\|(?P<mode>[AB])\|(?P<slope>[+-]?.*)\|(?P<offset>[+-]?.*)$')
class GenericLinearRecord(models.SensorSDKRecord):
    reading = mod.FloatField(help_text=_('reading from sensor in units'))
    reading_mv = mod.IntegerField(help_text=_('reading from sensor in mv'))
    slope = mod.FloatField(help_text=_("slope value for this reading"),	default=10)
    offset = mod.FloatField(help_text=_("offset value for this reading"), default=10)

    @staticmethod
    def getMode():
	'''Let the sensorsdk engine know which node we are handling'''
	return "monitor-generic-linear"
    
    @staticmethod
    def parsereading(device=None, seconds=None, battery=None, reading=None, dongle=None):
	'''This method expects to get a valid reading, generating a record out of it'''
	
	#extract parameters from reading string
	m = lin.match(reading)
	if not m:
	    logger.error("NO MATCH %s" % reading)
	    return
	m = m.groupdict()
	value = int(m['value'])
	mode = m['mode']
	slope = int(m['slope'])
	offset = int(m['offset'])
	
	if mode=='A':
	    slope = 1.0/slope
	
	logger.debug("reading %s, slope %s, offset %s, mode %s" % (value, slope, offset, mode))
	#find ambient device, or create if there's none yet created
	device,created=GenericLinearDevice.objects.get_or_create( 
	    address=device,
	    defaults={
		'friendly_name': _('Auto Discovered Generic Linear Sensor'),
		'sensor': _('Temperature'),
		'mode': _('Monitor'),
		'slope': slope,
		'offset': offset
	    })
	reading = device.getValue(value)
	
	record = GenericLinearRecord()
	record.slope = slope
	record.offset = offset
	record.remote=device
	record.dongle=dongle
	record.reading = reading
	record.reading_mv = value
	record.time=datetime.fromtimestamp(seconds)
	record.battery=battery
	record.save()
