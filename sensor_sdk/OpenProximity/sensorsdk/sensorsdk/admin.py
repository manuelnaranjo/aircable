# -*- coding: utf-8 -*-

from django.contrib import admin
from django.shortcuts import render_to_response
from django.db import models
from django import forms
from models import *
from django.http import HttpResponseRedirect
from forms import EmailForm, AlertTemplateForm
from django.utils.functional import update_wrapper
from django.utils.translation import ugettext as _
from django.utils.text import capfirst
from django.utils.safestring import mark_safe
from django.http import HttpResponseRedirect
from django.core.urlresolvers import reverse
from django.conf import settings
from utils import save_email_settings, isAIRcable
import rpyc

class MyModelAdmin(admin.ModelAdmin):
    change_form_template = 'admin/sensorsdk/change_form.html'
    
    def add_view(self, request, from_url='', extra_context=None):
	extra_context=extra_context or {}
	if getattr(self, 'help_text', None):
	    extra_context['help_text'] = mark_safe(self.help_text)
	if getattr(self, 'help_text_title', None):
	    extra_context['help_text_title'] = mark_safe(self.help_text_title)

	return super(MyModelAdmin, self).add_view(request, from_url, extra_context)
	
    def response_add(self, request, obj, post_url_continue='../%s/'):
	#if request.POST.has_key('setup_wizard'):
	    return HttpResponseRedirect('../../../')
	#return super(MyModelAdmin, self).response_add(request, obj, post_url_continue)
	
    def change_view(self, request, object_id, extra_context=None):
	extra_context=extra_context or {}
	if getattr(self, 'help_text', None):
	    extra_context['help_text'] = mark_safe(self.help_text)
	if getattr(self, 'help_text_title', None):
	    extra_context['help_text_title'] = mark_safe(self.help_text_title)
	
	return super(MyModelAdmin, self).change_view(request, object_id, extra_context)

class SensorCampaignAdmin(MyModelAdmin):
    fieldsets = (
        (None, {
            'fields': ('name', 'enabled', 'addr_filter', 'name_filter', 'devclass_filter'),
        }),
        ('Dongles settings',{
            'fields': ('dongle_name',),
        }),
        ('Timing Filters', {
            'classes': ('collapse', ),
            'fields': ('start', 'end')
        }),
    )

    list_display = ( 'name',
                        'start',
                        'end',
                        'name_filter',
                        'addr_filter',
                        'devclass_filter',
                        'enabled'
                )
    list_filter = ( 'start',
                        'end',
                        'name_filter',
                        'addr_filter',
                        'devclass_filter',
                        'enabled'
                )

    ordering = [ 'name', 'start', 'end' , 'addr_filter', 'name_filter']
    
    help_text_title=_("SensorSDK Campaign")
    help_text=_('''A <b>SensorSDK campaign</b> is used to tell to which devices we try to <b>connect</b>.<br>
<br>
You can\'t use <b>SensorSDK</b> without having an <b>enabled</b> campaign first.<br>
Important fields are:<ul>
<li>Enabled.
<li>Address Filter.
<li>Name Filter.</ul>
<br>
<br>Plugin handling per device is handled by each plugin, <b>you don\'t have to worry about it</b>.''')

class AlertDefinitionTemplateAdmin(MyModelAdmin):
    fieldsets = (
	(None, { 'fields': ('mode', )}),
	('Email Settings', {'fields': ('short', 'full',)}),
	('Web Site Settings:', {'fields': ('notice', 'full_html')}),
    )
    list_display = ('mode',)
    
    def formfield_for_dbfield(self, db_field, **kwargs):
	if db_field.attname not in ['short', 'full', 'notice', 'full_html']:
	    return super(AlertDefinitionTemplateAdmin, self).formfield_for_dbfield(db_field, **kwargs)
	    
	attrs = {'cols': 80}
	if db_field.attname == 'short':
	    attrs['rows'] = 4
	elif db_field.attname in ['full', 'notice', 'full_html']:
	    attrs['rows'] = 20
	kwargs['widget'] = forms.Textarea(attrs=attrs)
	return super(AlertDefinitionTemplateAdmin, self).formfield_for_dbfield(db_field, **kwargs)
	
    help_text_title=_("Alert Definition Template")
    help_text=_('''An <b>Alert Definition Template</b> is used to generate email content when an alert is triggered.<br>
<br>
You can only define one template per kind of alert available.<br>
<br>
The Syntaxis is the same used on Django templates, remember to add double brackets to each variable {{ variable }}.<br>
<br>
<h3>Available variables from SensorSDK</h3>
<ul>
    <li><b>value</b>: Value from the reading that triggered the alarm</li>
    <li><b>time</b>: Time when the alarm was triggered</li>
    <li><b>user</b>: User whose getting this email</li>
    <li><b>target</b>: Reference to the device that triggered the alarm. Available subset:
	<ul>
	    <li><b>target.address</b></li>
	    <li><b>target.name</b></li>
	    <li><b>target.mode</b></li>
	    <li><b>target.friendly_name</b></li>
	</ul>
    </li>
    <li><b>definition</b>:  Information related to the alarm definition
	<ul>
	    <li><b>definition.mode</b></li>
	    <li><b>definition.field</b></li>
	    <li><b>definition.set</b></li>
	    <li><b>definition.clr</b></li>
	    <li><b>definition.targets</b></li>
	    <li><b>definition.timeout</b></li>
	    <li><b>definition.users</b></li>
	</ul>
    </li>
</ul>
<br>
<br>
You can get more information on:
<ul>
<li><a href="http://www.opensensors.wikidot.com">OpenSensors Website</a></li>
<li><a href="http://www.openproximity.org">OpenProximity Website</a></li>
<li><a href="http://www.djangoproject.com/">Django Website</a></li>
</ul>
<br><br>
''')


class AlertDefinitionAdmin(MyModelAdmin):
    fieldsets = (
        ('Alert configuration',{
            'fields': ('mode', 'field', 'set', 'clr',),
        }),
        ('Observed Devices', {
            'fields': ('targets',)
        }),
        ('Observer Users', {
	    'fields': ('users',)
        }),
        ('Extra Settings', {
	    'fields': ('enabled', 'timeout',)
        }),
    )

    list_display = ( 'mode',
                        'field',
                        'set',
                        'clr',
                        'enabled'
                )
    list_filter = ( 'mode',
                        'field',
                        'set',
                        'clr',
                        'enabled',
                )

    ordering = [ 'mode', 'field', 'enabled']
    help_text_title=_("Alert Definition")
    help_text=_('''An <b>Alert Definition</b> defines the conditions for alarms to be triggered.<br>
<br>
There are four types of alarms:<ul>
<li><b>Under Range</b></li>
<li><b>Over Range</b></li>
<li><b>In Range</b></li>
<li><b>No data</b></li>
</ul>
<br>
<br>
All this types of alarms except for <b>No data</b> need a <b>set</b> and a <b>clear</b> value. 
This values will define when an alarm condition is met.
<br>
<br>
<b>No Data</b> is an special kind of alarm which is sent when more than <b>set</b> seconds are elapsed
without any data from the monitored devices.
<br>
<br>
For more information check <a href="http://opensensors.wikidot.com">OpenSensors Website</a>
<br><br>
''')

class SensorDongleAdmin(MyModelAdmin):
    help_text_title=_("SensorsDK Dongle Configuration")

    @property
    def help_text(self):
	"""Get the known dongles list and show it as help text"""
	out=_('''
On this page you can setup the dongles you will with SensorSDK.<br>
Don\'t forget to mark your dongles as enabled.<br>

<strong>Note: Right now there\'s no javascript to automatically fill in the address field, you will have to cut and paste the address below</strong>
''')
	try:
	    from rpyc import connect
	    server=connect('localhost', 8010)
	    dongles=server.root.getAllDongles()
	    if len(dongles) == 0:
		out+=_("<b>No dongles available</b>")
	    else:
		out+="<h3 class='aligned'>Known dongles</h3>"
		out+=' '.join(['* <b>%s</b>' % a for a in dongles])
	except Exception, err:
	    out+="<div class='errornote'>%s: %s</div>" % (_("Error while trying to reach list of dongles, reason"), err)
	
	return out

class AlertAdmin(admin.ModelAdmin):
    fieldsets = (
        (_('Alert configuration'),{
            'fields': ('alert', 'target',),
        }),
        (_('Alert state'),{
	    'fields': ('active', 'reviewed', 'auto_cleared', 'auto_timeout', 'value'),
	}),
        (_('Time'), {
            'fields': ('settime','clrtime',)
        }),
    )

    list_display = ( 'target',
			'alert',
			'value',
                        'active',
                        'reviewed',
                        'auto_cleared',
                        'auto_timeout',
                        'settime',
                        'clrtime',
                )
    list_filter = ( 'target',
		    'active',
                    'alert',
                    'reviewed',
                    'auto_cleared',
                    'auto_timeout',

                )

    ordering = [ 'target', 
	'active', 
	'alert', 
	'settime', 
	'clrtime',
	'auto_cleared',
	'auto_timeout',
	'value']

def get_redirect(tag, klass):
    return HttpResponseRedirect('%s%s/%s/add/' % (
	reverse( tag ),
	klass._meta.app_label,
	klass._meta.module_name
    ))

BOOLEAN_MAPPING={
    True: 'yes',
    False: 'no',
    None: 'no',
}

ALTER_TEXT={
    True: _("Completed"),
    False: _("Pending"),
    None: _("Pending"),
}

def get_icon(state, alternate_text=None):
    alternate_text = alternate_text or ALTER_TEXT[state]
    return mark_safe(u'<img src="%simg/admin/icon-%s.gif" alt="%s" />' % (settings.ADMIN_MEDIA_PREFIX, BOOLEAN_MAPPING[state], alternate_text))

class MyAdminSite(admin.AdminSite):
    shown_index = False
    index_template = "admin/sensorsdk/index.html"
    
    def generateSetupStepContentForModel(self, klass, text, extra=None):
	created = klass.objects.count() > 0
	url = mark_safe('%s/%s/add/' % (klass._meta.app_label, klass.__name__.lower()))
	
	return {
	    'url': url, 
	    'state': get_icon(created),
	    'text': text,
	    'extra': extra
	}

    def generateSetupStepContentForEmail(self, text):
	state = False
	
	return {
	    'url': mark_safe('setup_email/'), 
	    'state': None,
	    'text': text,
	    'extra': mark_safe("<a href='setup_email/test' class='myviewsitelink'>%s</a>" % _('Check Email Configuration')),
	}

    def index(self, request, extra_context=None):
        """
    	SensorSDK customization
        """
        
        # first add SensorSDK quick setup steps
	if extra_context is None:
	    extra_context = {}
	
	extra_context['setup_steps'] = [
	    self.generateSetupStepContentForModel(
		SensorCampaign, _('Create a Campaign')),
	    self.generateSetupStepContentForModel(
		SensorSDKBluetoothDongle, _('Assign a Dongle')),
	    self.generateSetupStepContentForEmail(
		_('Setup Email Server')),
	    self.generateSetupStepContentForModel(
		AlertDefinitionTemplate, _('Create Email Templates'),
		extra=mark_safe('%s <a href="alert_template_fill">%s</a>' % (_('or'),_('Automatically Fill Templates')))),
	    {
		'url': None, 
		'state': get_icon(SensorSDKRemoteDevice.objects.count()>0), 
		'text': mark_safe(
		    _('Wait until your SenorSDK devices are discovered, <a href=".">Refresh</a>'))
	    },
	    self.generateSetupStepContentForModel(
		AlertDefinition, _('Create Alert Definitions')),
	]
	
	extra_context['extra_list'] = [
	    {'url': mark_safe('setup_email/'), 'name': _("Setup Email Server")},
	    {'url': mark_safe('alert_template_fill/'), 'name': _("Automatically Fill Alert Templates")},
	]
        return super(MyAdminSite, self).index(request, extra_context)

    def get_urls(self):
	from django.conf.urls.defaults import patterns, url
	urls = patterns('',
	    url(r'^setup_email/$', self.admin_view(self.setup_email), name="sensorsdk-email"),
	    url(r'^setup_email/test$', self.admin_view(self.test_email), name="sensorsdk-email-test"),
	    url(r'^alert_template_fill/$', self.admin_view(self.templates_auto), name="sensorsdk-templates-auto"),
	)
	urls.extend(super(MyAdminSite, self).get_urls())
	return urls
	
    def generic_setup(self, request, Form=None, action=None, 
	    initial=None, template=None, step=None, step_form=None, 
	    help_content=None, next=None):
	next = next or HttpResponseRedirect('/sensorsdk/admin')
	form = None
	if request.method == "POST":
	    form = Form(request.POST)
	    if form.is_valid():
		action(form.cleaned_data, request)
		if '_addanother' not in request.POST:
		    return next
		form = None
	if not form:
	    form = Form(initial)

	return render_to_response(
	    template or 'admin/sensorsdk/base_setup.html', 
	    {
		'form': form,
		'media': form.media,
		'step': step,
		'user': request.user,
		'step_form': step_form,
		'help_content': mark_safe(help_content),
		'show_save': True
	    })

    def test_email(self, request, extra_context=None):
	state = False
	error = None

	from django.core import mail
	from smtplib import SMTP

	try:
	    connection = mail.SMTPConnection()
	    server = SMTP(timeout=10)
	    server.connect(connection.host, connection.port)
	    if connection.use_tls:
		server.starttls()
	    if connection.username:
		server.login(connection.username, connection.password)
	    server.close()
	    state = True
	except Exception, err:
	    error=err
	    state = False
	return render_to_response(
	    'admin/sensorsdk/email_test.html',
	    {
		'state': get_icon(state),
		'exception': error
	    })
	
    def setup_email(self, request, extra_context=None):
	default = dict()
	for i in ['DEFAULT_FROM_EMAIL', 
		'EMAIL_HOST', 
		'EMAIL_HOST_PASSWORD', 
		'EMAIL_HOST_USER', 
		'EMAIL_PORT',
		'EMAIL_USE_TLS']:
	    default[i] = getattr(settings, i, None)
	try:
	    default['EMAIL_PORT']=int(default['EMAIL_PORT'])
	except:
	    default['EMAIL_PORT']=25
	
	return self.generic_setup(request, 
	    Form=EmailForm, 
	    action=save_email_settings,
	    initial=default, 
	    step=_('Email Setup'), 
	    step_form='email_setup', 
	    help_content=_('''On this page you will be able to setup the basic configuration settings so SensorSDK is able to send mails when alerts are triggered.
	    
You can use what ever smtp you have access. Like for example gmail, hotmail, yahoo, etc or even your own maintained server.'''),
	    next=HttpResponseRedirect('test')
	)
	
    def save_template(self, mode, short, full, notice, full_html):
	temp,created = AlertDefinitionTemplate.objects.get_or_create(mode=mode)
	temp.short=short
	temp.full=full
	temp.notice=notice
	temp.full_html=full_html
	temp.save()

    def save_alert_template_settings(self, form, request, *args, **kwargs):
	if not form['ACCEPT']:
	    return
	
	if form['NO_DATA']:
	    self.save_template(-1, **ALERT_TEMPLATES[-1])
	if form['OVER_RANGE']:
	    self.save_template(0, **ALERT_TEMPLATES[0])
	if form['UNDER_RANGE']:
	    self.save_template(1, **ALERT_TEMPLATES[1])
	if form['IN_RANGE']:
	    self.save_template(2, **ALERT_TEMPLATES[2])


    def templates_auto(self, request, extra_context=None):
	return self.generic_setup(request, 
	    Form=AlertTemplateForm, 
	    action=self.save_alert_template_settings,
	    initial={}, 
	    step=_('Alert Templates Wizard'), 
	    help_content=_('''This wizard will automatically fill the available templates from predefined content. Take into account that there\'s no way to revert this step.
	    
Choose only the templates you want to get automatically filled.

Don\'t forget to mark the <b>Save Settings</b> field if you want changes to be persisted''')
	)

myadmin = MyAdminSite()
myadmin.register(SensorSDKBluetoothDongle, SensorDongleAdmin)
myadmin.register(SensorCampaign, SensorCampaignAdmin)
myadmin.register(AlertDefinitionTemplate, AlertDefinitionTemplateAdmin)
myadmin.register(AlertDefinition, AlertDefinitionAdmin)
myadmin.register(Alert, AlertAdmin)


# now it's time to get the rest of the admins
from net.aircable.openproximity.pluginsystem import pluginsystem
for plugin in pluginsystem.get_plugins('sensorsdk'):
    try:
       logger.debug("import admin for plugin %s" % plugin.module_name)
       mod = __import__("%s.sdkadmin" % plugin.module_name, fromlist=['register'])
       if not getattr(mod, 'register', None):
           logger.debug("no admin provided by %s" % plugin.module_name)
           continue
       for k, a in getattr(mod, 'register')():
           myadmin.register(k, a)
       logger.debug("admin loaded for %s" % plugin.module_name)
    except Exception, err:
       logger.error("couldn't load admin for %s" % plugin.module_name)
