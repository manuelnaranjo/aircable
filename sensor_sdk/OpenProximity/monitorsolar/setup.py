from setuptools import setup

from monitorsolar import __version__

setup(name="SensorSDK Solar Sensor",
    version=__version__,
    packages=['monitorsolar',],
    summary="SensorSDK Solar Sensor",
    description="""SensorSDK plugin""",
    long_description="""A sample plugin for solar watter heatter monitoring""",
    author="Naranjo Manuel Francisco",
    author_email= "manuel@aircable.net",
    license="GPL2",
    url="http://code.google.com/p/aircable/", 
)
