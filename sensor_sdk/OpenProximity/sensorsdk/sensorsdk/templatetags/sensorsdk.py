from django import template

register=template.Library()

def getSensorSDK():
    try:
        return __import__('sensorsdk')
    except:	
        return __import__('plugins.sensorsdk')

def sensorsdk_version():
    return getattr(getSensorSDK(),'__version__', None)

def sensorsdk_plugins_as_li():
    print "sensorsdk_plugins_as_li"
    out = ""
    for plugin in getattr(getSensorSDK(),'find_plugins', lambda: [])():
	out+="<li>%s: %s</li>" % (plugin.module_name, getattr(plugin, '__version__', 'ND'))
    return out

register.simple_tag(sensorsdk_version)
register.simple_tag(sensorsdk_plugins_as_li)
