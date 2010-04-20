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

from django.conf.urls.defaults import *

from admin import myadmin

import views
import charts

urlpatterns = patterns( '',
	url(r'^admin/', include(myadmin.get_urls()), name="sensorsdk-admin"),
	(r'^API/get-chart-data/(?P<address>.+)/(?P<fields>.+)/data.json$', charts.generate_chart_data),
	(r'^API/get-chart-data/data.json$', charts.generate_chart_data),
	(r'^API/get-chart-fields/(?P<address>.+)$', views.get_chart_fields_for_sensor),
	(r'^API/get-sensors/(?P<mode>.*)$', views.get_sensors),
	(r'^API/get-modes/$', views.get_modes),
	(r'^API/get-help/(?P<mode>.*)$', views.get_help),
	url(r'^rpc/last_records/', views.get_last_records, name="sensorsdk-last_records"),
	url(r'^rpc/last_alerts/', views.get_last_alerts, name="sensorsdk-last_records"),
	url(r'^chart/$', views.chart, name="sensorsdk-chart"),
	url(r'^$', views.index, name="sensorsdk-index"),
    )
