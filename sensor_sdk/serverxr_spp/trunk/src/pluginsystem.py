import os, re, StringIO
import ConfigParser, pkgutil

import sensorsdk.plugins

def find_plugin_dirs():
        return [os.path.expanduser('~/.sensorsdk/plugins'),
                '/usr/lib/sensorsdk/plugins']

# add dirs from sys.path:
sensorsdk.plugins.__path__ = pkgutil.extend_path(sensorsdk.plugins.__path__, 
                                              sensorsdk.plugins.__name__)
# add dirs specific to sensorsdk:
sensorsdk.plugins.__path__ = find_plugin_dirs() + sensorsdk.plugins.__path__


class Plugin(object):
        def __init__(self, path, name, load):
                self.path = path
                self.name = name
		try:
            	    _module = load()
		    for i in dir(_module):
			setattr(self, i, getattr(_module, i))
		    self._module = _module
                except Exception, err:
                    print "Failed to load plugin %s." % self.name
		    print err
                    return None
                
class PluginSystem(object):
        def __init__(self):
                self.plugin_infos = list()

        def get_plugins(self):
                return self.plugin_infos

        def find_plugins(self):
                for path in sensorsdk.plugins.__path__:
                        if not os.path.isdir(path):
                                continue
                        for entry in os.listdir(path):
                                if entry.startswith('_'):
                                        continue # __init__.py etc.
                                if entry.endswith('.py'):
                                        try:
                                                self.load_info(path, entry[:-3])
                                        except Exception:
                                                print "Failed to load info:", 
                                                print os.path.join(path, entry)

        def load_info(self, path, name):
                plugin = Plugin(path, name,
                                lambda:self.import_plugin(name))

                self.plugin_infos.append(plugin)

        def import_plugin(self, name):
                __import__('sensorsdk.plugins', {}, {}, [name], 0)
                plugin = getattr(sensorsdk.plugins, name)
                return plugin

pluginsystem = PluginSystem()

if __name__=='__main__':
    pluginsystem.find_plugins()
    for plug in pluginsystem.get_info():
	print dir(plug)
