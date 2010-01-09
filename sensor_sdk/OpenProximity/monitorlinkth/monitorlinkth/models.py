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

MAXSENSORS = 5

SENSOR_FAMILY = {
    ''  : '18S20 or 18B20',
    '00': 'MS-T',
    '19': 'MS-TH',
    '1A': 'MS-TV',
    '1B': 'MS-TL',
}

SENSOR_EXTRACTION={
    #temp only
    '': lambda x: {'temperature': float(x.split(',')[1])},
    '00': lambda x: {'temperature': float(x.split(',')[1])},

    #temp humidity
    '19': lambda x: {'temperature': float(x.split(',')[1]), 
			'extra': float(x.split(',')[3])},

    #temp voltage
    '1A': lambda x: {'temperature': float(x.split(',')[1]), 
			'extra': float(x.split(',')[3])},
    
    #temp light
    '1B': lambda x: {'temperature': float(x.split(',')[1]), 
			'extra': float(x.split(',')[3])},
}

class LinkTHDevice(models.SensorSDKRemoteDevice):
    @staticmethod
    def getMode():
	'''Let the sensorsdk engine know which node we are handling'''
	return "monitor-linkth"

    @staticmethod
    def getChartVariables():
	fields=list()
	for i in range(MAXSENSORS):
	    fields.append('value%s' % i,)
	    fields.append('value%sa' % i,)
	fields.append('battery',)
	return fields

    @staticmethod
    def getRecordClass():
        return LinkTHRecord

    def findSensorForId(self, dev_id):
	j = 0
	dev_id=dev_id.strip().upper()
	
	for i in range(MAXSENSORS):
	    prev_id = getattr(self, 'sensor%s_id' % i, None)
	    if dev_id==prev_id or prev_id==None:
		break;
	    j+=1
	if j < MAXSENSORS:
	    logger.info("LinkTHDevice.findSensorForId %s->%s" % (dev_id, j))
	    return j
	raise Exception("Sensor not found, no more slots available")
	
for i in range(MAXSENSORS):
    LinkTHDevice.add_to_class(
	'sensor%s_id' % i, 
	mod.CharField(max_length=16,
	    help_text=_('sensor %s ID') % i,
	    null=True, blank=True,
	)
    )
    LinkTHDevice.add_to_class(
	'sensor%s_name' %i, 
	mod.CharField(max_length=100,
	    help_text=_('sensor %s friendly name') % i,
	    null=True, blank=True,
	)
    )
    LinkTHDevice.add_to_class(
	'sensor%s_family' %i,
	mod.CharField(max_length=100,
	    help_text=_('sensor %s family based on ID') % i,
	)
    )

LINE=r'OWI\|(?P<id>[A-F0-9]+)\|OWS\|(?P<val>[^|]*)(\|)?(?P<rest>.*)$'
LINE=compile(LINE)
    
class LinkTHRecord(models.SensorSDKRecord):

    @staticmethod
    def getMode():
	'''Let the sensorsdk engine know which node we are handling'''
	return "monitor-linkth"

    @staticmethod
    def parsereading(device=None, seconds=None, battery=None, reading=None, dongle=None):
	'''This method expects to get a valid reading, generating a record out of it'''
	
	logger.info("linkthrecord parsereading: %s" % reading)
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
	record.time=datetime.fromtimestamp(seconds)
	record.battery=int(battery)/1000.0 # asume we get battery * 1000
	
	while len(reading) > 0:
	    m = LINE.match(reading)
	    if not m:
		logger.error("monitorlinkth NO MATCH: %s" % reading)
		break
	    m=m.groupdict()
	    reading = m['rest']
	    val = m['val']
	    typ = val.split(',')[0].strip()
	    m['id']=m['id'].strip()
	    
	    try:
		sen_id = device.findSensorForId(m['id'])
	    except Exception, err:
		# if we got here then we have more than MAXSENSORS
		# registered on this linkth
		logger.exception(err)
		break
	    
	    if not getattr(device, 'sensor%s_id' % sen_id, None):
		setattr(device, 'sensor%s_id' % sen_id, m['id'])
		setattr(device, 'sensor%s_name' % sen_id, _("Auto discovered 1wire sensor"))
		setattr(device, 'sensor%s_family' % sen_id, SENSOR_FAMILY[typ])
		device.save()

	    val = SENSOR_EXTRACTION[typ](val)
	    setattr(record, 'value%s' % sen_id, val['temperature'])
	    
	    if typ in ['19', '1A', '1B']:
		setattr(record, 'value%sa' % send_id, val['extra'])
	logger.info("saving record, work done")
	record.save()

for i in range(MAXSENSORS):
    LinkTHRecord.add_to_class(
	'value%s' % i, 
	mod.FloatField(
	    help_text=_('temperature meassured from sensor number %s in celsius') % i,
	    null=True, blank=True,
	)
    )
    LinkTHRecord.add_to_class(
	'value%sa' %i, 
	mod.FloatField(
	    help_text=_('optional reading from sensor number %s friendly name') % i,
	    null=True, blank=True,
	)
    )

