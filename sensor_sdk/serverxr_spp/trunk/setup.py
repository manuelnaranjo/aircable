#!/usr/bin/env python

from distutils.core import setup

setup(name='AIRcableSPP',
	version='0.1',
	description='AIRcable SDKSensors SPP Server',
	author='Naranjo Manuel Francisco',
	author_email='manuel@aircable.net',
	package_dir= {'' : 'src' } ,
	url='www.aircable.net',
	packages=['net', 'net.aircable', 'net.aircable.spp'],
	license="Apache version 2",
    )
    
