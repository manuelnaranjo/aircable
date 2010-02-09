from django import template

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
    for plugin in getattr(sensorsdk,'find_plugins', lambda: [])():
	out+="<li>%s: %s</li>" % (plugin.module_name, getattr(plugin, '__version__', 'ND'))
    return out

register.simple_tag(sensorsdk_version)
register.simple_tag(sensorsdk_plugins_as_li)
