from setuptools import setup
from monitorlinkth import __version__

setup(name="SensorSDK Linkth Sensor",
    version=__version__,
    packages=['monitorlinkth',],
    summary="SensorSDK Linth Sensor",
    description="""SensorSDK plugin""",
    long_description="""A sample plugin for iButton monitoring""",
    author="Naranjo Manuel Francisco",
    author_email= "manuel@aircable.net",
    license="GPL2",
    url="http://code.google.com/p/aircable/", 
)
