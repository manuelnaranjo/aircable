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

from django import forms
from django.http import HttpResponse
from django.contrib.auth.decorators import login_required
from django.conf import settings
from django.utils.translation import ugettext as _
from django.utils import simplejson
from django.shortcuts import render_to_response
import models

SET = settings.OPENPROXIMITY.getAllSettings()

def get_modes(request):
    return HttpResponse(
	simplejson.dumps(list(models.SensorSDKRemoteDevice.getModes())),
	content_type='application/json')

def get_sensors(request, mode=None):
    if mode:
	qs = models.SensorSDKRemoteDevice.getHandler(mode).objects.all()
    else:
	qs = models.SensorSDKRemoteDevice.objects.all()

    out = dict()

    for i in qs.all():
	out[i.address]={
		'name': i.name,
		'mode': i.mode,
		'sensor': i.sensor,
		'address': i.address.replace(':','_'),
	}

    return HttpResponse(simplejson.dumps(out),
	content_type='application/json')

def get_chart_fields_for_sensor(request, address):
    address=address.replace('_',':')
    dev = models.SensorSDKRemoteDevice.objects.get(address=address)
    dev = models.get_subclass(dev)
    return HttpResponse(
	simplejson.dumps(dev.getChartVariables()),
	content_type='application/json')

def chart(request):
    return render_to_response("sensorsdk/chart.html",)

def index(request):
    return render_to_response("sensorsdk/index.html")

