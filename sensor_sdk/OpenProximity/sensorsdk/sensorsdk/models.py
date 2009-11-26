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

from openproximity.models import RemoteDevice, RemoteBluetoothDeviceRecord, Campaign, \
	    BluetoothDongle, SERVICE_TYPES, RemoteBluetoothDeviceFoundRecord
from django.db import models
from django.utils.translation import ugettext as _

#SERVICE_TYPES+=((400, 'spp'))

class SensorSDKBluetoothDongle(BluetoothDongle):
    max_conn = models.IntegerField(
	default=4,
	help_text="maximum allowed sensors to handle at the same time",
	verbose_name=_("connections"))

remote_classes=dict()
class SensorSDKRemoteDevice(RemoteDevice):
    sensor = models.CharField(max_length=32,
	help_text=_("kind of sensor attached"))
    mode = models.CharField(max_length=32,
	verbose_name=_("working mode"))
    friendly_name=models.CharField(max_length=100,
	help_text=_("a name to identify the device, example kitchen sensor"))

    @staticmethod
    def getChartVariables():
	'''Implement this method if you want your class to be discovered for charting'''
	return []

    @staticmethod
    def getMode():
	'''This method needs to be extended and should return a string which 
	   identifies your device type'''
	raise Exception("Not implemented, you need to subclass SensorSDKRecord")

    @staticmethod
    def getHandler(mode):
	'''A static method that allows sensorsdk to tell which class handles which mode'''
	mode = mode.strip().lower()
	if mode in remote_classes:
	    return remote_classes[mode]
	
	for klass in SensorSDKRemoteDevice.__subclasses__():
	    if mode==klass.getMode().lower():
		remote_classes[mode] = klass
		return klass
	raise Exception("No plugin to handle mode %s" % mode)

    @staticmethod
    def getModes():
	'''A static method that allows sensorsdk to tell which modes are available'''
	for klass in SensorSDKRemoteDevice.__subclasses__():
	    yield klass.getMode().lower()
    
    @staticmethod
    def getRecordClass():
	raise Exception("Not implemented, you need to subclass SensorSDKRemodeDevice")

record_classes = dict()
class SensorSDKRecord(RemoteBluetoothDeviceRecord):
    battery = models.FloatField(help_text=_("Battery reading"))

    @staticmethod
    def getMode():
	'''This method needs to be extended and should return a string which 
	   identifies your device type'''
	raise Exception("Not implemented, you need to subclass SensorSDKRecord")
	
    @staticmethod
    def parsereading(device=None, seconds=None, battery=None, reading=None, dongle=None):
	'''This method needs to be extended so history can be parsed and persisted'''
	raise Exception("Not implemented, you need to subclass SensorSDKRecord")
	
    @staticmethod
    def getHandler(mode):
	'''A static method that allows sensorsdk to tell which class handles which mode'''
	mode = mode.strip().lower()
	if mode in record_classes:
	    return record_classes[mode]
	
	for klass in SensorSDKRecord.__subclasses__():
	    if mode==klass.getMode().lower():
		record_classes[mode] = klass
		return klass
	raise Exception("No plugin to handle mode %s" % mode)

class SensorCampaign(Campaign):
    def matches(self, remote):
	if self.name_filter is None or remote.name is None or remote.name.startswith(self.name_filter):
	    if self.addr_filter is None or remote.address.startswith(self.addr_filter):
		return True
	return False

SensorCampaign._meta.get_field('addr_filter').default="00:25:BF"

def get_subclass(object):
    '''get subclass from object'''
    for related in object._meta.get_all_related_objects():
        if type(object) in related.model._meta.get_parent_list():
            if hasattr(object, related.var_name):
                return get_subclass(getattr(object, related.var_name))
    return object
                                            