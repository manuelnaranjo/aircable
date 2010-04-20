from setuptools import setup
from sensorsdk import __version__

setup(name="SensorSDK",
    version=__version__,
    packages=[
	'sensorsdk',
	'sensorsdk.management', 
	'sensorsdk.management.commands', 
	'sensorsdk.templatetags'
    ],
    summary="SensorSDK core",
    description="""SensorSDK OpenProximity plugin""",
    long_description="""this plugin allows OpenProximity to be used for remote bluetooth sensing networks.
It provides plugin with basic stuff such: data storage, charting, data sync, alarms, etc.
SensorSDK is a plugin system it self, sensors talk to SensorSDK through plugins""",
    author="Naranjo Manuel Francisco",
    author_email= "manuel@aircable.net",
    package_dir={'sensorsdk': 'sensorsdk',},
    package_data={
	'sensorsdk': [
	    'templates/sensorsdk/*', 
	    'templates/admin/sensorsdk/*',
	    'media/*', 
	]},
    license="GPL2",
    url="http://code.google.com/p/aircable/", 
)
