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
from django.template import RequestContext
from django.shortcuts import render_to_response
from wadofstuff.django.serializers.base import Serializer
import models, inspect

SET = settings.OPENPROXIMITY.getAllSettings()

def get_modes(request):
    return HttpResponse(
	simplejson.dumps(list(models.SensorSDKRemoteDevice.getModes())),
	content_type='application/json')

def get_subclass(object):
    for related in object._meta.get_all_related_objects():
	if type(object) in related.model._meta.get_parent_list():
	    if hasattr(object,related.var_name):
		return get_subclass(getattr(object, related.var_name))
    return object

def props(obj):
    # based on http://stackoverflow.com/questions/61517/python-dictionary-from-an-objects-fields
    pr = {}
    for field in obj._meta.local_fields:
	name = field.name
	if name.endswith('_ptr'):
	    continue
        value = getattr(obj, name)
        if not name.startswith('__') and not inspect.ismethod(value):
            pr[name] = value
    return pr

def last_records():
    qs=models.SensorSDKRemoteDevice.objects.order_by('latest_served')
    
    for dev in qs.all():
	t = {
	    'name': dev.name,
	    'mode': dev.mode,
	    'sensor': dev.sensor,
	    'address': dev.address,
	    'friendly_name': dev.friendly_name,
	    'latest_served': str(dev.latest_served),
	}
	q = models.SensorSDKRecord.objects.filter(remote=dev)
	if q.count() > 0:
	    t['last_record'] = props(get_subclass(q.latest('time')))
	yield t
    
def get_last_records(request):
    return HttpResponse(
	simplejson.dumps(list(last_records())),
	content_type='application/json')

def last_alerts(user):
    qs=models.Alert.objects.all().filter(active=True)
    
    if not user.is_staff:
	qs=qs.filter(alert__users__in=[user,])
    
    for alert in qs.all():
	t = {
	    'alert': {
		'mode': {
		    'id': alert.alert.mode,
		    'text': models.ALERT_INFO[alert.alert.mode]['short'],
		},
		'set': alert.alert.set,
		'clr': alert.alert.clr,
		'timeout': alert.alert.timeout,
		'enabled': alert.alert.enabled,
	    },
	    'settime': str(alert.settime),
	    'clrtime': str(alert.clrtime),
	    'target': {
		'address': alert.target.address,
		'name': alert.target.friendly_name,
	    },
	    'state': alert.display_State(),
	    'active': alert.active,
	    'pk': alert.pk,
	}
	yield t
    
    
def get_last_alerts(request):
    if not request.user.is_authenticated:
	return HttpResponse('{}', content_type='application/json')
    return HttpResponse(
	simplejson.dumps(list(last_alerts(request.user))),
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
		'friendly_name': i.friendly_name,
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
    return render_to_response("sensorsdk/chart.html", {}, 
	context_instance=RequestContext(request))

def index(request):
    return render_to_response("sensorsdk/index.html", {},
	context_instance=RequestContext(request))

def get_help(request, mode):
    def internal_get_help(mode):
	out = {'pk': mode}
	out.update(models.ALERT_INFO[mode].get('help', {}))
	return out
	
    return HttpResponse(
	simplejson.dumps(internal_get_help(int(mode))),
	content_type='application/json')
