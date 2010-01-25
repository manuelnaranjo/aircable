from django import forms
from django.forms import fields, models, widgets
from django.http import HttpResponseRedirect
from django.contrib.formtools.wizard import FormWizard
from django.core.urlresolvers import reverse
from django.utils.encoding import force_unicode
from django.utils.translation import ugettext as _
import models

from re import compile

class EmailForm(forms.Form):
    DEFAULT_FROM_EMAIL = forms.EmailField(
	label=_("Email sender"), 
	required=False,
	help_text=_("When an alert is triggered this will be the sender email.<br>Example: alert@opensensors.org")
    )
    EMAIL_HOST = forms.URLField(
	label=_("Email server"),
	help_text=_("Your SMTP email server address.<br>Example: smtp.google.com")
    )
    EMAIL_HOST_USER = forms.CharField(
	label=_("Email server user"), 
	required=False,
	help_text=_("User name you use to connect to this server")
    )
    EMAIL_HOST_PASSWORD = forms.CharField(
	label=_("Email server password"), 
	required=False,
	help_text=_("The password you use to access your SMTP server")
    )
    EMAIL_PORT = forms.IntegerField(
	label=_("Email server port"), 
	initial=25,
	help_text=_("Some servers don't provide the SMTP service at the regular port (25)<br>ask your SMTP provider for the port number.<br>Example Gmail: 587"),
	min_value=1,
	max_value=(2**16)-1
    )
    EMAIL_USE_TLS = forms.BooleanField(
	label=_("Should use TLS for this server?"), 
	initial=False, 
	required=False,
	help_text=_("Some servers like for example GMail require some content encryption<br>check this option if you need TLS encryption")
    )
    
class AlertTemplateForm(forms.Form):
    NO_DATA = forms.BooleanField(
	label=_("No data"),
	initial = False,
	required = False,
	help_text=("No data template is used when a known SensorSDK device stops reporting")
    )
    OVER_RANGE = forms.BooleanField(
	label=_("Over Range"),
	initial = False,
	required = False,
	help_text=("Over Range template is used when a certain variable from a known SensorSDK reports been over a certain treshold")
    )
    UNDER_RANGE = forms.BooleanField(
	label=_("Under Range"),
	initial = False,
	required = False,
	help_text=("Under Range template is used when a certain variable from a known SensorSDK reports been under a certain treshold")
    )
    IN_RANGE = forms.BooleanField(
	label=_("In Range"),
	initial = False,
	required = False,
	help_text=("Under Range template is used when a certain variable from a known SensorSDK reports been between two certain values")
    )
    ACCEPT = forms.BooleanField(
	label=_("Save Settings"),
	initial = False,
	required = False,
	help_text=("If you don't mark this field then settings will not be saved")
    )
