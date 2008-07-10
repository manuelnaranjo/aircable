#!/usr/bin/env python

from distutils.core import setup

setup(name='AIRmessage',
	version='0.1',
	description='AIRcable SDKSensors Messages Server',
	author='Naranjo Manuel Francisco',
	author_email='manuel@aircable.net',
	package_dir= {'' : 'messages' } ,
	url='www.aircable.net',
	packages=['net.aircable.message'],
    )
    
