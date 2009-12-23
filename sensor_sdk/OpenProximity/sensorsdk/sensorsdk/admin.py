# -*- coding: utf-8 -*-

from django.contrib import admin
from django.db import models
from django import forms
from models import *

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


myadmin = admin.AdminSite()

myadmin.register(SensorSDKBluetoothDongle)
myadmin.register(SensorCampaign, SensorCampaignAdmin)
myadmin.register(AlertDefinitionTemplate, AlertDefinitionTemplateAdmin)
myadmin.register(AlertDefinition, AlertDefinitionAdmin)
myadmin.register(Alert, AlertAdmin)
