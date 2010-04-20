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
from django.contrib.auth.models import User
from datetime import datetime
from django.forms import widgets
from net.aircable.utils import logger
import time

# we depend on django-notification
from notification import models as notification

class SensorSDKBluetoothDongle(BluetoothDongle):
    max_conn = models.IntegerField(
	default=4,
	help_text="maximum allowed sensors to handle at the same time",
	verbose_name=_("connections"))
	
SensorSDKBluetoothDongle._meta.get_field_by_name('enabled')[0].default=True

remote_classes=dict()
class SensorSDKRemoteDevice(RemoteDevice):
    sensor = models.CharField(max_length=32,
	help_text=_("kind of sensor attached"))
    mode = models.CharField(max_length=32,
	verbose_name=_("working mode"))
    friendly_name=models.CharField(max_length=100,
	help_text=_("a name to identify the device, example kitchen sensor"))
    latest_served=models.DateTimeField(auto_now=True, editable=False)

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
	mode = str(mode).strip().lower()
	logger.info("SensorSDKRemoteDevice.getHandler %s" % mode)
	if mode in remote_classes:
	    return remote_classes[mode]
	
	for klass in get_subclasses(SensorSDKRemoteDevice):
	    if mode.__eq__(klass.getMode().lower().strip()):
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
	
    @staticmethod
    def getAllFields():
	'''this method will return a list of all the available fields'''
	for klass in get_subclasses(SensorSDKRecord):
	    for field in klass._meta.local_fields:
		if not getattr(field, 'related', None):
		    yield (field.name, field.name)
	yield ('battery', 'battery')

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
	logger.info("SensorSDKRecord.getHandler %s available: [%s]" % (mode, list(get_subclasses(SensorSDKRecord))))
	if mode in record_classes:
	    return record_classes[mode]
	
	for klass in get_subclasses(SensorSDKRecord):
	    if mode.__eq__(klass.getMode().lower().strip()):
	        record_classes[mode] = klass
	        return klass
	raise Exception("No plugin to handle mode %s" % mode)

class SensorCampaign(Campaign):
    def matches(self, remote, *args, **kwargs):
	if self.name_filter is None or remote.name is None or remote.name.startswith(self.name_filter):
	    if self.addr_filter is None or remote.address.startswith(self.addr_filter):
		return True
	return False

SensorCampaign._meta.get_field('addr_filter').default="00:25:BF"

ALERT_TYPES = ( 
    (-1, _('No data')),
    (0, _('Over Range')),
    (1, _('Under Range')),
    (2, _('In Range')),
)

ALERT_INFO= {
    -1:{ 'name': 'no_report',
	'short': _('No data'),
	'long': _('A sensor hasn\'t reported data for a long time'),
	'set': lambda x: False,
	'clear': lambda x: False,
	'help': {
	    'set': _(
		'When device hasn\'t reported data for more than this amount'
		    ' of seconds then trigger alarm'),
	    'clr': _('ignored'),
	    'field': _('ignored'),
	    'mode': _('This alarm will allow you to monitor'
		' if your devices are reporting back to the server')
	}
    },
    0: {'name': 'alert_over',
	'short': _('Over Range'),
	'long': _('A sensor reading has gone over range'),
	'set': lambda val, set, extra: val > set,
	'clear': lambda val, clear, extra: val < clear,
	'help': {
	    'set': _(
		'set alarm if monitored signal goes over this value.'
	    ),
	    'clr': _(
		'clear alarm if monitored signal goes under this value.'
	    ),
	    'field': _('this is the signal this alarm is going to watch'),
	    'mode': _(
		'This alarm will allow to monitor over range sensitive processes.<br>'
		'For example avoid boiling temperature in a water pipe.'
	    )
	}

    },
    1: {'name': 'alert_under',
	'short': _('Under Range'),
	'long': _('A sensor reading has gone under range'),
	'set': lambda val,set,extra: val < set,
	'clear': lambda val,clear,extra: val > set,
	'help': {
	    'set': _(
		'set alarm if monitored signal goes under this value.'
	    ),
	    'clr': _(
		'clear alarm if monitored signal goes over this value.'
	    ),
	    'field': _('this is the signal this alarm is going to watch'),
	    'mode': _(
		'This alarm will allow to monitor under range sensitive processes.<br>'
		'For example to avoid freezing point in a water pipe.'
	    )
	}


    },
    2: {'name': 'alert_in', 
	'short': _('In Range'), 
	'long': _('A sensor reading has gone into range'),
	'set': lambda val,lim_m,lim_M: lim_m < val and val < lim_M,
	'clear': lambda val,lim_M,lim_m: val < lim_m and lim_M > val,
	'help': {
	    'set': _(
		'set alarm if monitored signal goes over this value.'
	    ),
	    'clr': _(
		'set alarm if monitored signal goes under this value.'
	    ),
	    'field': _('this is the signal this alarm is going to watch'),
	    'mode': _(
		'This alarm will allow to monitor when a signal goes inside a range.<br>'
		'For example some chemical processes need values to not get inside a window.'
	    )
	}
    },

}

class AlertDefinitionTemplate(models.Model):
    mode = models.IntegerField( choices=ALERT_TYPES,
	help_text=_('Mode this template will handle'),
	unique=True)
    short = models.TextField(max_length=6000, blank=True, null=True,
	help_text=_('Email subject when this notice is triggered'))
    full = models.TextField(max_length=6000, blank=True, null=True,
	help_text=_('Email body when this notice is triggered'))
    notice = models.TextField(max_length=6000, blank=True, null=True,
	help_text=_('This text will be displayed on the web site when the alert is triggered'))
    full_html = models.TextField(max_length=6000, blank=True, null=True,
	help_text=_('Not used yet'))
	
    def __unicode__(self):
	return "Alert Definition Template %s" % ALERT_INFO[self.mode]['short']
	
    @classmethod
    def getTemplates(cls, mode):
	qs = AlertDefinitionTemplate.objects.filter(mode=mode)
	if qs.count() == 0:
	    return None
	qs = qs.get()
	return {
	    'short.txt': qs.short,
	    'full.txt': qs.full,
	    'notice.html': qs.notice,
	    'full.html': qs.full_html
	}
	

ALERT_TEMPLATES={
    -1: {
	'short': _("[SensorSDK - Alerts] {{target.friendly_name}}[{{target.address}}]: is not reporting"),
	'full': _('''This is an automatically generated message, don\'t try replying to it.
{{target.friendly_name}}[{{target.address}}] hasn\'t reported for the last {{ definition.set }} seconds.
Please check what\'s wrong. This alert will be sent again in {{ definition.timeout }} seconds if not cleared first.
Regards,
SensorSDK Automatic alerts
'''),
	'notice':_('''{{target.friendly_name}}[{{target.address}}] not reporting'''),
	'full_html': ''
    },

    0: {
	'short': _("[SensorSDK - Alerts] {{target.friendly_name}}[{{target.address}}]: {{definition.field}} is over {{definition.set}}"),
	'full': _('''This is an automatically generated message, don\'t try replying to it.
{{target.friendly_name}}[{{target.address}}] {{defintion.field}} is over {{definition.set}}.
Please check what\'s wrong. This alert will be automatically cleared once {{definition.field}} gets under {{definition.clr}} again.
Regards,
SensorSDK Automatic alerts
'''),
	'notice':_('''{{target.friendly_name}}[{{target.address}}] {{field}} is over range'''),
	'full_html': ''
    },

    1: {
	'short': _("[SensorSDK - Alerts] {{target.friendly_name}}[{{target.address}}]: {{definition.field}} is under {{definition.set}}"),
	'full': _('''This is an automatically generated message, don\'t try replying to it.
{{target.friendly_name}}[{{target.address}}] {{defintion.field}} is under {{definition.set}}.
Please check what\'s wrong. This alert will be automatically cleared once {{definition.field}} gets over {{definition.clr}} again.
Regards,
SensorSDK Automatic alerts
'''),
	'notice':_('''{{target.friendly_name}}[{{target.address}}] {{field}} is under range'''),
	'full_html': ''
    },

    2: {
	'short': _("[SensorSDK - Alerts] {{target.friendly_name}}[{{target.address}}]: {{definition.field}} is in range {{definition.set}}-{{defintion.clr}}"),
	'full': _('''This is an automatically generated message, don\'t try replying to it.
{{target.friendly_name}}[{{target.address}}] {{defintion.field}} got into {{definition.set}}-{{defintion.clr}}.
Please check what\'s wrong. This alert will be automatically cleared once {{definition.field}} gets out of this range again.
Regards,
SensorSDK Automatic alerts
'''),
	'notice':_('''{{target.friendly_name}}[{{target.address}}] {{field}} in range'''),
	'full_html': ''
    }
}

class AlertDefinition(models.Model):
    '''A class used to define automatic alerts'''

    mode = models.IntegerField( default=0, choices=ALERT_TYPES,
	help_text=_('''How should we trigger the alarm:<br>
* Over Range: the alarm is set when it reaches setalert, then it will be reset when it gets under clearalert.<br>
* Under Range: the alarm is set when the value goes under setalert, it will be reset when it goes over clearalert.<br>
* In Range: the alarm is set when ever the value is inbetween setalert and clearalert<br>
* No Data: the alarm will be set when the targets has\'t reported for <set> seconds, <clear> is ignored as long as <field>''')
    )

    set = models.FloatField(verbose_name=_('set alert'),
	help_text=_("the value for the monitored variable that will trigger the alarm"))
    clr = models.FloatField(verbose_name=_('clear alert'), blank=True, null=True,
	help_text=_("the value for the monitored variable that will clear the alarm once reached"))
    targets = models.ManyToManyField(SensorSDKRemoteDevice,
	help_text=_("devices observed by this alarm"))
    timeout = models.IntegerField( default=86400, verbose_name=_("reset time"),
	help_text=_("amount of seconds before automatically resetting the alarm, default 1 day, -1 is not automatic"))
    enabled = models.BooleanField(default=True)
    users = models.ManyToManyField(User,
	help_text=_("users that will get see this alert"))
    
    def sendNotification(self, target=None, value=None):
	if not self.enabled:
	    return
	if Alert.doAlert(self, target, value) is True:
	    logger.info("sending mail")
	    notification.send(
		self.users.all(), 
		ALERT_INFO[self.mode]['name'],
		{
		    'target': target,
		    'value': value,
		    'definition': self,
		    'time': datetime.now(),
		},
		current_site="SensorSDK Notifications",
		templates=AlertDefinitionTemplate.getTemplates(self.mode)
	    )

    @classmethod
    def do_work(cls, record):
	'''
	    This method gets called each time a new record is stored into the database.
	    The method is responsible of checking if there\'s any registered alarm for
	    this instance, and in case there is check if any of the fields has gone
	    outside the spected values.
	'''
	logger.info("do_work on AlertDefinition")
	remote = get_subclass(record.remote)
	record = get_subclass(record)
	for notif in remote.alertdefinition_set.filter(enabled=True).exclude(mode=-1).all():
	    val = getattr(record, notif.field)
	    set = ALERT_INFO[notif.mode]['set'](val, notif.set, notif.clr)
	    clear = ALERT_INFO[notif.mode]['clear'](val, notif.clr, notif.set)

	    logger.debug("checking for alarm %s %s %s %s %s %s" % (
		ALERT_INFO[notif.mode]['name'], 
		val, 
		notif.set, 
		notif.clr, 
		set, 
		clear))
	    if clear is True:
		qs = notif.alert_set.filter(target=remote, active=True)
		if qs.count() > 0:
		    logger.info("clearing alarm")
		qs.update(active=False, auto_cleared=True)
	    elif set is True:
		logger.info("setting alarm")
		notif.sendNotification(target=remote, value=val)
	    # there's another kind of alarm we would like to check
	    # that's no data, but we do that on a scheduled basis

    @classmethod
    def check_nodata(cls):
	'''
	    This method will check if there\'s a device whose no data alert needs to
	    be triggered
	'''
	logger.info("check_nodata on AlertDefinition")
	for notif in AlertDefinition.objects.filter(enabled=True, mode=-1):
	    timeout = datetime.fromtimestamp(time.time() - notif.set)
	    #if last record for this alert was made before timeout then we have an alert
	    for remote in notif.targets.all():
		last_record = SensorSDKRecord.objects.filter(remote=remote).latest('time')
		if timeout > last_record.time:
		    logger.info("%s not sending for over %s seconds" % (remote.address, notif.set))
		    # ok we reached the time trigger
		    notif.sendNotification(target=remote, value=time.mktime(last_record.time.timetuple()))
		else:
		    qs=Alert.objects.filter(alert=notif, active=True, target=remote)
		    if qs.count() > 0:
			logger.info("%s is sending again clearing alarm" % remote)
			qs.update(active=False, auto_cleared=True)
	    Alert.updateActive()

    def display_Mode(self):
	return ALERT_INFO[self.mode]['short']

    def __unicode__(self):
	return '[%s] %s %s %s' % ( self.display_Mode(),
	    self.field, self.set, self.clr
	)
	
    def save(self, force_insert=False, force_update=False):
	if self.mode != -1 and ( self.clr is None or self.field is None):
	    raise Exception("you need to set clear and field on non 'no data' alerts")
	super(AlertDefinition, self).save(force_insert, force_update)
    
class Alert(models.Model):
    '''A class to encapsulate a given alarm'''
    alert = models.ForeignKey('AlertDefinition',
	help_text=_('alert definition that triggered this alarm'))
    settime = models.DateTimeField(help_text=_('time when this alarm was set'))
    clrtime = models.DateTimeField(help_text=_('time when this alarm will be cleared'), null=True)
    target = models.ForeignKey('SensorSDKRemoteDevice',
	help_text=_('device that triggered this alarm'))
    active = models.BooleanField(
	help_text=_('is active then no mail are received until either the administrator clears the alarm or it timesout')
    )
    auto_cleared = models.BooleanField(default=False,
    	help_text=_("if true then this alarm was cleared by reaching the clear value"))
    auto_timeout = models.BooleanField(default=False,
    	help_text=_("if true then this alarm was cleared by reaching the timeout time"))
    reviewed = models.BooleanField(default=False, verbose_name=_('action taken'),
    	help_text=_("if true then someone has checked the cause for the alarm and fixed it."))
    value = models.FloatField(null=True,
	help_text=_("value that launched this alarm"))

    @classmethod
    def updateActive(cls):
	qs = Alert.objects.filter(clrtime__lte=datetime.now()).filter(active=True)
	qs.update(active=False, auto_timeout=True)

    @classmethod
    def doAlert(cls, alert, target, value):
	Alert.updateActive()
	logger.info("alert %s %s" % (alert.field, target.address))
	qs = Alert.objects.filter(alert=alert, target=target)
	if qs.filter(active=True).count() > 0:
	    logger.debug("Alert all ready set for target")
	    return False

	logger.debug("Alert will be sent")
	a=Alert()
	a.active=True
	a.alert=alert
	a.target=target
	a.setAlarm()
	a.value=value
	a.save()
	return True
	
    def save(self, *args, **kwargs):
	if self.reviewed:
	    self.active = False
	super(Alert, self).save(*args, **kwargs)

    def setAlarm(self, start=None):
	if not start:
	    start=time.time()
	self.settime = datetime.fromtimestamp(start)
	self.clrtime = datetime.fromtimestamp(start+self.alert.timeout)

    def display_Active(self):
	if self.active:
	    return _('Active')
	return _('Inactive')
	
    def __unicode__(self):
	return u"[%s] %s: %s" % (
	    self.display_Active(),
	    unicode(self.alert), 
	    self.target.address)
	    
    def display_State(self):
	if self.active:
	    return _("Needs Action")
	if self.auto_cleared:
	    return _("Values back to normal")
	if self.auto_timeout:
	    return _("Alarm did a timeout")
	if self.reviewed:
	    return _("Action taken")
	return _("Not Valid State")

def get_subclass(object):
    '''get subclass from object'''
    for related in object._meta.get_all_related_objects():
        if type(object) in related.model._meta.get_parent_list():
            if hasattr(object, related.var_name):
                return get_subclass(getattr(object, related.var_name))
    return object

def get_subclasses(base):
    for app in models.get_apps():
	for model in models.get_models(app):
	    if model != base and issubclass(model, base):
		yield model
    for model in base.__subclasses__():
	yield model

def handle_SensorSDKRecord_post_save(sender, instance, created, **kwargs):
    if isinstance(instance, SensorSDKRecord):
	logger.debug("handle_sensorsdk_post_save")
	AlertDefinition.do_work(instance)
models.signals.post_save.connect(handle_SensorSDKRecord_post_save)

def post_init():
    try:
	for i in ALERT_INFO:
	    info=ALERT_INFO[i]
	    notification.create_notice_type(info['name'], info['short'], info['long'])
    except Exception, err:
	logger.exception(err)
    post_plugins_load()

def post_plugins_load():
    try:
	AlertDefinition._meta.get_field_by_name('field')
	return
    except:
	pass
	
    logger.info("Registering AlertDefinition.field")
    field = models.CharField( max_length=100,
        help_text=_("Field used for this alarm"),
        choices=set(SensorSDKRemoteDevice.getAllFields()),
        name='field',
        blank=True, null=True
    )

    AlertDefinition.add_to_class('field', field)
