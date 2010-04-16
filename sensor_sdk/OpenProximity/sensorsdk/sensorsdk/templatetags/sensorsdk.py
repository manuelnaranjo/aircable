from django import template
from net.aircable.openproximity.pluginsystem import pluginsystem

register=template.Library()

def getSensorSDK():
    try:
        return __import__('sensorsdk', level=0)
    except:	
        return __import__('plugins.sensorsdk', fromlist=['__version__', 'find_plugins'], level=0)
sensorsdk=getSensorSDK()

def sensorsdk_version():
    return sensorsdk.__version__

def sensorsdk_plugins_as_li():
    out = ""
    for plugin in pluginsystem.get_plugins('sensorsdk'):
	out+="<li>%s: %s</li>" % (plugin.name, plugin.__version__)
    return out

register.simple_tag(sensorsdk_version)
register.simple_tag(sensorsdk_plugins_as_li)
