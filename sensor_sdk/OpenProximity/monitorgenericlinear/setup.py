from setuptools import setup
from monitorgenericlinear import __version__

setup(name="SensorSDK-GenericLinearSensor",
    version=__version__,
    packages=['monitorgenericlinear',],
    summary="SensorSDK Generic Linear Sensor",
    description="""SensorSDK plugin""",
    long_description="""A sample plugin for generic linear sensor monitoring""",
    author="Naranjo Manuel Francisco",
    author_email= "manuel@aircable.net",
    license="GPL2",
    url="http://code.google.com/p/aircable/", 
)
