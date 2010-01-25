# -*- coding: utf-8 -*-

from django.contrib import admin
from django.shortcuts import render_to_response
from django.db import models
from django import forms
from models import *
from forms import EmailForm, AlertTemplateForm
from django.utils.functional import update_wrapper
from django.utils.translation import ugettext as _
from django.utils.text import capfirst
from django.utils.safestring import mark_safe
from django.http import HttpResponseRedirect
from django.core.urlresolvers import reverse
from django.conf import settings
from utils import save_email_settings, isAIRcable
import re 
import rpyc

email_re = re.compile(
    r"(^[-!#$%&'*+/=?^_`{}|~0-9A-Z]+(\.[-!#$%&'*+/=?^_`{}|~0-9A-Z]+)*"  # dot-atom
    r'|^"([\001-\010\013\014\016-\037!#-\[\]-\177]|\\[\001-011\013\014\016-\177])*"' # quoted-string
    r')@(?:[A-Z0-9]+(?:-*[A-Z0-9]+)*\.)+[A-Z]{2,6}$', re.IGNORECASE)  # domain


class SensorCampaignAdmin(admin.ModelAdmin):
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

class AlertDefinitionTemplateAdmin(admin.ModelAdmin):
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

class AlertDefinitionAdmin(admin.ModelAdmin):
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

class AlertAdmin(admin.ModelAdmin):
    fieldsets = (
        ('Alert configuration',{
            'fields': ('alert', 'target', 'active',),
        }),
        ('Time', {
            'fields': ('settime','clrtime',)
        }),
    )

    list_display = ( 'target',
                        'active',
                        'alert',
                        'settime',
                        'clrtime',
                )
    list_filter = ( 'target',
		    'active',
                    'alert',
                )

    ordering = [ 'target', 'active', 'alert', 'settime', 'clrtime']

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
	if getattr(settings, 'EMAIL_HOST', None) != None:
	    state = email_re.match(settings.EMAIL_HOST)
	
	return {
	    'url': mark_safe('setup_email/'), 
	    'state': get_icon(state),
	    'text': text,
	}
    
    def index(self, request, extra_context=None):
	"""
	Display the main admin index page, add extra help information
	"""
	
	if extra_context is None:
	    extra_context = {}
	
	extra_context['setup_steps'] = [
	    self.generateSetupStepContentForModel(
		SensorCampaign, _('Create a SensorSDK campaign')),
	    self.generateSetupStepContentForModel(
		SensorSDKBluetoothDongle, _('Create a SensorSDK Bluetooth Dongle')),
	    self.generateSetupStepContentForEmail(
		_('Setup Email Server')),
	    self.generateSetupStepContentForModel(
		AlertDefinitionTemplate, _('Create a SensorSDK Email Templates'),
		extra=mark_safe('%s <a href="alert_template_fill">%s</a>' % (_('or'),_('Automatically Fill Templates')))),
	    {'url': None, 'state': get_icon(SensorSDKRemoteDevice.objects.count()>0), 'text': _('Wait until your SenorSDK devices are discovered')},
	    self.generateSetupStepContentForModel(
		AlertDefinition, _('Create a SensorSDK Alert Definition')),
	]
	
	extra_context['extra_list'] = [
	    {'url': mark_safe('setup_email/'), 'name': _("Setup Email Server")},
	    {'url': mark_safe('alert_template_fill/'), 'name': _("Automatically Fill Alert Templates")},
	]
	
	return super(MyAdminSite, self).index(request, extra_context=extra_context)
    
    def get_urls(self):
	from django.conf.urls.defaults import patterns, url
	urls = patterns('',
	    url(r'^setup_email/$', self.admin_view(self.setup_email), name="sensorsdk-email"),
	    url(r'^alert_template_fill/$', self.admin_view(self.templates_auto), name="sensorsdk-templates-auto"),
	)
	urls.extend(super(MyAdminSite, self).get_urls())
	return urls
	
    def generic_setup(self, request, Form=None, action=None, 
	    initial=None, template=None, step=None, step_form=None, 
	    help_content=None):
	form = None
	if request.method == "POST":
	    form = Form(request.POST)
	    if form.is_valid():
		action(form.cleaned_data, request)
		if '_addanother' not in request.POST:
		    return HttpResponseRedirect('/sensorsdk/admin')
		form = None
	if not form:
	    form = Form(initial)

	return render_to_response(
	    template or 'sensorsdk/base_setup.html', 
	    {
		'form': form,
		'media': form.media,
		'step': step,
		'user': request.user,
		'step_form': step_form,
		'help_content': help_content,
		'show_save': True
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
You can use what ever smtp you have access too like for example gmail, hotmail, yahoo, etc or even your own maintained server.''')
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
Don\'t forget to mark the "Save Settings" field if you want changes to be persisted''')
	)



myadmin = MyAdminSite()

myadmin.index_template="admin/sensorsdk/index.html"
myadmin.register(SensorSDKBluetoothDongle)
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
       logger.exception(err)
