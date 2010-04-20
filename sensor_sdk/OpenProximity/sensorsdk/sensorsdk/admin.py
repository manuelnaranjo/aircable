# -*- coding: utf-8 -*-

from django.contrib import admin
from django.shortcuts import render_to_response
from django.db import models
from django import forms, template
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
from django.views.decorators.cache import never_cache
from utils import save_email_settings, isAIRcable
import rpyc
import help_text

#auth needed pieces
from django.contrib.auth.models import User
from django.contrib.auth.admin import UserAdmin


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
    help_text=help_text.SensorCampaignAdmin
    
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
    help_text=help_text.AlertDefinitionTemplateAdmin

class AlertDefinitionAdmin(MyModelAdmin):
    class Media:
        js = ( 
	    '/site_media/MochiKit.js',
	    '/site_media/alert_definition.js'
        )

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
    help_text=help_text.AlertDefinitionAdmin

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
	    dongles=server.root.getDongles()
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
    model_order=dict()
    app_order=list()
    
    def register(self, model, *args, **kwargs):
	# order is important for us.
	app_label = model._meta.app_label
	module_name = model._meta.module_name
	if app_label not in self.app_order:
	    self.app_order.append(app_label)
	if app_label not in self.model_order:
	    self.model_order[app_label]=list()
	if module_name not in self.model_order[app_label]:
	    self.model_order[app_label].append(module_name)

	super(MyAdminSite,self).register(model, *args, **kwargs)
    
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

    def sort_app_list(self, app_list):
	out = list()
	for app in self.app_order:
	    for random in app_list:
		if random['app_label'] == app:
		    out.append(random)
		    app_list.remove(random)
		    break
	out.extend(app_list)
	return out

    def sort_app_dict(self, model_list, order):
	out = list()
	for ordered in order:
	    for random in list(model_list):
		if str(random['module_name']) == ordered:
		    out.append(random)
		    model_list.remove(random)
		    break
	out.extend(model_list)
	return out

    def index(self, request, extra_context=None):
        """
    	SensorSDK index page
        """
        
        # contect customization
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
	    {
		'url': 'auth/user/add/', 
		'state': get_icon(User.objects.filter(is_staff=False).count()>0), 
		'text': mark_safe(
		    _('Create a few <b>non staff</b> users, so they can receive emails from Alarms'))
	    },
	    self.generateSetupStepContentForModel(
		AlertDefinition, _('Create Alert Definitions')),
	]
	
	extra_context['extra_list'] = [
	    {'url': mark_safe('setup_email/'), 'name': _("Setup Email Server")},
	    {'url': mark_safe('alert_template_fill/'), 'name': _("Automatically Fill Alert Templates")},
	]
        
        app_dict = {}
        user = request.user
        for model, model_admin in self._registry.items():
            app_label = model._meta.app_label
            has_module_perms = user.has_module_perms(app_label)

            if has_module_perms:
                perms = model_admin.get_model_perms(request)

                # Check whether user has any perm for this module.
                # If so, add the module to the model_list.
                if True in perms.values():
                    model_dict = {
                        'name': capfirst(model._meta.verbose_name_plural),
                        'module_name': model._meta.module_name,
                        'admin_url': mark_safe('%s/%s/' % (app_label, model.__name__.lower())),
                        'perms': perms,
                    }
                    if app_label in app_dict:
                        app_dict[app_label]['models'].append(model_dict)
                    else:
                        app_dict[app_label] = {
                            'name': app_label.title(),
                            'app_label': app_label,
                            'app_url': app_label + '/',
                            'has_module_perms': has_module_perms,
                            'models': [model_dict],
                        }

	# first check if we have our own order
        # Sort the apps alphabetically.
        app_list = app_dict.values()
        app_list=self.sort_app_list(app_list)

        # Sort the models alphabetically within each app.
        for app in app_list:
            app['models']=self.sort_app_dict(app['models'], self.model_order[app['app_label']])

        context = {
            'title': _('Site administration'),
            'app_list': app_list,
            'root_path': self.root_path,
        }
        context.update(extra_context or {})
        context_instance = template.RequestContext(request, current_app=self.name)
        return render_to_response(self.index_template or 'admin/index.html', context,
            context_instance=context_instance
        )
    index = never_cache(index)


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
myadmin.register(SensorCampaign, SensorCampaignAdmin)
myadmin.register(SensorSDKBluetoothDongle, SensorDongleAdmin)
myadmin.register(AlertDefinitionTemplate, AlertDefinitionTemplateAdmin)
myadmin.register(AlertDefinition, AlertDefinitionAdmin)
myadmin.register(Alert, AlertAdmin)


# add user creation forms
myadmin.register(User, UserAdmin)


# now it's time to get the rest of the admins
from net.aircable.openproximity.pluginsystem import pluginsystem
for plugin in pluginsystem.get_plugins('sensorsdk'):
    try:
       logger.debug("import admin for plugin %s" % plugin.name)
       mod = __import__("%s.sdkadmin" % plugin.name, fromlist=['register'])
       if not getattr(mod, 'register', None):
           logger.debug("no admin provided by %s" % plugin.name)
           continue
       for k, a in getattr(mod, 'register')():
           myadmin.register(k, a)
       logger.debug("admin loaded for %s" % plugin.name)
    except Exception, err:
       logger.error("couldn't load admin for %s" % plugin.name)
