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

# SensorSDK handler

__version_info__=('0','3','6')
__version__ = '.'.join(__version_info__)


def post_environ():
    from net.aircable.utils import logger
    logger.debug("senorsdk post environ")
    from models import post_init, post_plugins_load
    
    for p in find_plugins():
	try:
	    logger.debug("forcing model loading for %s" % p.name)
	    __import__('%s.models' % p.name)
	except Exception, err:
	    logger.error(err)
	    logger.exception(err)
    
    post_init()
    post_plugins_load()

def statistics_reset(connection):
    from django.db import models
    from django.core.management.color import no_style
    from django.core.management import sql
    from net.aircable.utils import logger
    import models
    
    tables = []
    for klass in models.SensorSDKRecord.__subclasses__():
	tables.append(klass._meta.db_table,)

    tables.append(models.SensorSDKRecord._meta.db_table,)
    
    for klass in models.SensorSDKRemoteDevice.__subclasses__():
	tables.append(klass._meta.db_table,)

    tables.append(models.SensorSDKRemoteDevice._meta.db_table,)
    
    logger.info("droping: %s" % tables)
    
    for table in tables:
	connection.cursor().execute("drop table %s" % table)

def find_plugins():
    from net.aircable.utils import logger
    from net.aircable.openproximity.pluginsystem import pluginsystem
    #look for all the sensorsdk plugins
    for plugin in pluginsystem.get_plugins('sensorsdk'):
	logger.info("Plugin %s" % plugin.name)
	yield plugin
