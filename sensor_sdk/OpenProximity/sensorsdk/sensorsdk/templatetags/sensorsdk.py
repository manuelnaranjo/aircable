from django import template
from django.conf import settings
from net.aircable.openproximity.pluginsystem import pluginsystem

try:
    from sensorsdk import __version__, find_plugins
except:
    from plugins.sensorsdk import __version__, find_plugins

register=template.Library()

class SettingsNode(template.Node):
    def __init__(self):
	print "settings node created"

    def render(self, context):
	print "sensorsdk settings", __version__
	context['sensorsdk.version'] = __version__
	#    'plugins': sensorsdk.find_plugins()
#	}
	return ''
	
def do_settings(parser, token):
    return SettingsNode()

def sensorsdk_version():
    return __version__

def sensorsdk_plugins_as_li():
    print "sensorsdk_plugins_as_li"
    out = ""
    for plugin in find_plugins():
	out+="<li>%s: %s</li>" % (plugin.module_name, getattr(plugin, '__version__', ''))
    return out

register.simple_tag(sensorsdk_version)
register.simple_tag(sensorsdk_plugins_as_li)
