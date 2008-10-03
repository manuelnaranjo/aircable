#!/usr/bin/python

"""Host XR range calculation

This little script will help you calculate ranges in the AIRcable Host XR 
depending on the maximum output power you set it to work. NOTE: This values 
are estimated, and should be tretead as that.

WARNING: Don't use this code on any hardware except for the AIRcable Host XR,
or you might damage your hardware.

Usage:

	powertable.py [ arguments ]

Arguments:
	-h, --help 		this help message
	-d, --hci  <hciX> 	where hciX represents your hci device
	-g, --gain <dBm>	gain of the transmiting antenna you're using.
					Default: 5.5dBm
	-r, --reception <dBm>	gain of the receiving antenna, about 0dBm on 
					cell phones and bad radios.
	-s, --sensivity <dBm>	sensivity of the other end, about -83dBm on
					cell phones and bad radios.
	-a, --air-loss	<dBm>	amounts of dBs lost because of the enviroment,
					we estimate 22dBm in open air with no 
					humidity and good weather.
	-S, --set-gain	<dBm>	will set the gain to <dBm>, please use values
					from the table, the device will try to
					use closet minor value available.
"""

from subprocess import Popen,PIPE
from math import pi, pow
import sys
import getopt
import os

# globals used for calculations
GT=5.5
GR=0
R=-83
F=22
lamb=.125
hci="hci0"

def readtable():
	# run bccmd, get temporary table, close pipe.
	process = Popen('bccmd -d %s psget 0x0031' % hci , shell=True,bufsize=1024,
			stdout=PIPE)
	pipe=process.stdout

	ttable = pipe.read()
	pipe.close()

	process.wait()

	if process.returncode != 0:
		sys.stderr.write("Can't communicate with device, can't continue\n")
		exit(-1)

	# Now get real power table
	table = ttable.replace('Radio power table: ','').replace('\n','').split(' ')

	itable = range(0,len(table)*2);

	# convert table int
	for i in range(0, len(table)):
		t = int(table[i], 16);
		itable[i*2] = t & 0xff
		itable[i*2+1] = t >> 8 & 0xff

	# remove 2's complement
	for i in range(0, len(itable)):
		if itable[i] > 0x7f:
			itable[i]=itable[i]-256

	return itable

def printRangeVsdBm(itable):
	for i in range(4*2,len(itable),5*2):
		k = itable[i]
		print "%ddBm\t%im\t(0x%04x)" % (k, calcRange(k) , (0xffff & k) & 0xff )

def calcRange(P=18):
	return lamb / (4.0 * pi) * pow( 10.0, ( P + GT + GR - R - F)/20.0 )

def updateOutputPower(db):
	print "Setting output to %s dBm" % db
	os.system('bccmd -d %s psset -s psi 0x21 %s' % (hci,db))
	os.system('bccmd -d %s psget 0x21' % (hci))
	sys.exit(0)

if __name__ == '__main__' :
    	try:
        	opts, args = getopt.getopt(sys.argv[1:], "hd:g:r:s:a:S:", 
			["help", "hci", "gain", "reception", "sensivity", 
				"air-loss", "set-gain"])

	except getopt.error, msg:
        	print msg
		print "for help use --help"
		sys.exit(2)

	# process options
	for o, a in opts:
        	if o in ("-h", "--help"):
			print __doc__
			sys.exit(0)
		
		if o in ("-d", "--hci"):
			hci=a
		
		if o in ("-g", "--gain"):
			GT=float(a)

		if o in ("-a", "--air-loss"):
			F=float(a)

		if o in ("-r", "--reception"):
			GR=float(a)

		if o in ("-s", "--sensivity"):
			R=float(a)
		
		if o in ("-S", "--set-gain"):
			updateOutputPower(a)
	

	itable=readtable()

	printRangeVsdBm(itable)

