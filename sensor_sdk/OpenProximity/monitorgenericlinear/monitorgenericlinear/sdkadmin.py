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

from net.aircable.utils import logger
from django.contrib import admin
from django.utils.translation import gettext_lazy as _
import models

logger.debug("monitorgenericlinear admin loading")

class GenericLinearDeviceAdmin(admin.ModelAdmin):
    fieldsets = (
	(_('General Settings'), {
	    'fields': ('address', 'friendly_name', 'mode'),
	}),
	(_('Sensor Settings'), {
	    'fields': ('sensor', 'slope', 'offset', 'units'),
	}),
	(_('Other Settings'), {
	    'fields': ('name', 'devclass'),
	})
    )
    list_display=('address','friendly_name', 'sensor', 'name', 'latest_served')

class GenericLinearRecordAdmin(admin.ModelAdmin):
    fieldsets = (
	(_('Reading data'), {
	    'fields': ('reading', 'reading_mv', 'slope', 'offset', 'time'),
	}),
	(_('Sensor'), {
	    'fields': ('battery', 'dongle', 'remote'),
	}),
    )
    list_display=('remote', 'reading', 'reading_mv', 'slope', 'offset', 'time')
    list_filter=('remote', 'dongle', 'slope', 'offset')

def register():
    # defines new clases for admin panel
    yield models.GenericLinearDevice, GenericLinearDeviceAdmin
    yield models.GenericLinearRecord, GenericLinearRecordAdmin

