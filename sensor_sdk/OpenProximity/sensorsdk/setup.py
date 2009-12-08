from setuptools import setup

setup(name="SensorSDK",
    version="0.1b",
    packages=['sensorsdk',],
    summary="SensorSDK core",
    description="""SensorSDK OpenProximity plugin""",
    long_description="""this plugin allows OpenProximity to be used for remote bluetooth sensing networks.
It provides plugin with basic stuff such: data storage, charting, data sync, etc.
SensorSDK is a plugin system it self, sensors talk to SensorSDK through plugins""",
    author="Naranjo Manuel Francisco",
    author_email= "manuel@aircable.net",
    package_dir={'sensorsdk': 'sensorsdk'},
    package_data={'sensorsdk': ['templates/sensorsdk/*.html',]},
    license="GPL2",
    url="http://code.google.com/p/aircable/", 
)
