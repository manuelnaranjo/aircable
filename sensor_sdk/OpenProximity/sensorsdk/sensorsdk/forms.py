from django import forms
from django.forms import fields, models, widgets, ValidationError
from django.forms.util import ErrorList
from django.http import HttpResponseRedirect
from django.contrib.formtools.wizard import FormWizard
from django.core.urlresolvers import reverse
from django.utils.encoding import force_unicode
from django.utils.translation import ugettext as _
from django.utils.safestring import mark_safe
import models
from urlparse import urlparse

class ServerField(forms.CharField):
    def clean(self, value):
	if len(urlparse(value).path) > 0:
	    return value
	raise ValidationError(_("%s not matching a valid Server url") % value)

class BooleanField(forms.BooleanField):
    def is_checkbox(self):
	return True

class EmailForm(forms.Form):
    DEFAULT_FROM_EMAIL = forms.EmailField(
	label=_("Email sender"), 
	required=False,
	help_text=_("When an alert is triggered this will be the sender email. <b>Example</b>: alert@opensensors.org")
    )
    EMAIL_HOST = ServerField(
	label=_("Email server"),
	help_text=_("Your SMTP email server address. <b>Example</b>: smtp.gmail.com")
    )
    EMAIL_HOST_USER = forms.CharField(
	label=_("Email server user"), 
	required=False,
	help_text=_("User name you use to connect to this server. <b>Example</b>: youruser@gmail.com")
    )
    EMAIL_HOST_PASSWORD = forms.CharField(
	label=_("Email server password"), 
	required=False,
	help_text=_("The password you use to access your SMTP server")
    )
    EMAIL_PORT = forms.IntegerField(
	label=_("Email server port"), 
	initial=25,
	help_text=_("Some servers don't provide the SMTP service at the regular port (25) ask your SMTP provider for the port number.<b>Example</b> 587 for <b>Gmail</b>"),
	min_value=1,
	max_value=(2**16)-1
    )
    EMAIL_USE_TLS = BooleanField(
	label=_("Should use TLS for this server?"), 
	initial=False, 
	required=False,
	help_text=_("Some servers like Gmail require content encryption check this option if you need TLS encryption")
    )
    
    def clean_EMAIL_PORT(self):
	value=self.cleaned_data['EMAIL_PORT']
	if int(value) <= 0:
	    raise ValidationException(_("Port number invalid"))
	return value
    
    def clean(self):
	if 'EMAIL_HOST_USER' in self.cleaned_data and \
	    (not 'EMAIL_HOST_PASSWORD' in self.cleaned_data or \
		len(self.cleaned_data['EMAIL_HOST_PASSWORD'].strip())==0):
	    self._errors['EMAIL_HOST_PASSWORD']=ErrorList([_("You need to set a password if you set a username")])
	return self.cleaned_data
    
class AlertTemplateForm(forms.Form):
    NO_DATA = BooleanField(
	label=_("No data"),
	initial = False,
	required = False,
	help_text=_("No data template is used when a known SensorSDK device stops reporting")
    )
    OVER_RANGE = BooleanField(
	label=_("Over Range"),
	initial = False,
	required = False,
	help_text=_("Over Range template is used when a certain variable from a known SensorSDK reports been over a certain treshold")
    )
    UNDER_RANGE = BooleanField(
	label=_("Under Range"),
	initial = False,
	required = False,
	help_text=_("Under Range template is used when a certain variable from a known SensorSDK reports been under a certain treshold")
    )
    IN_RANGE = BooleanField(
	label=_("In Range"),
	initial = False,
	required = False,
	help_text=_("Under Range template is used when a certain variable from a known SensorSDK reports been between two certain values")
    )
    ACCEPT = BooleanField(
	label=_("Save Settings"),
	initial = False,
	required = False,
	help_text=_("If you don't mark this field then settings will not be saved")
    )
    
    def clean(self):
	if ( self.cleaned_data['NO_DATA'] or \
	    self.cleaned_data['OVER_RANGE'] or \
	    self.cleaned_data['UNDER_RANGE'] or \
	    self.cleaned_data['IN_RANGE'] ) and not self.cleaned_data['ACCEPT']:
		self._errors['ACCEPT']=ErrorList([
		    mark_safe(_('No changes are saved as <b>Save Settings</b> wasn\'t selected')),
		    ])
	return self.cleaned_data
