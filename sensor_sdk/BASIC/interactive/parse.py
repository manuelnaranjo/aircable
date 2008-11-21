#!/usr/bin/python
import string
import getopt, sys

VERBOSE=False

def usage():
	print('''
This script will fill menu lines with zero to fill %i
chars per line so you can then upload it to the
AIRcable SensorSDK interactive example.

Usage %s:
	-h, --help 			this menu
	-i, --input=<file> 	input file, default stdio
	-o, --output=<file>	output file, default stdout
	-v, --versbose		print out some logging
					information to stderr
''' %( LENGTH, sys.argv[0] ))
	
def log(text):
	if not VERBOSE:
		return
	print("%s" % text);

def main():
	global VERBOSE
	try:
		opts, args = getopt.getopt(sys.argv[1:], 
			"hi:o:v", 
			["help", "input=", "output=", "verbose"]
		)
	except getopt.GetoptError, err:
		# print help information and exit:
		print str(err) # will print something like "option -a not recognized"
		usage()
		sys.exit(2)
		
	LENGTH=32
	OUTPUT =  sys.stdout
	INPUT = sys.stdin

#	Options parsing

	for opt, arg in opts:
		if opt in ("-v", "--verbose"):
			VERBOSE = True
		elif opt in ("-h", "--help"):
			usage()
			sys.exit()
		elif opt in ("-o", "--output"):
			OUTPUT = file(arg,"w");
		elif opt in ("-i", "--input"):
			INPUT = file(arg, "r");
		else:
			assert False, "unhandled option"
	
	log("Menu Parsed")
	log("Parsing text")
	
	while ( 1 ):
		
		line = INPUT.readline()
		if ( not line):
			log("EOF")
			sys.exit(0)

#		Allow comments
		if (line.startswith("#")):
			log("ignoring comment")
			continue

		
		line=line.replace("\n","")
		log("line: %s" % line);
		
		length = len(line)
		log("length: %i" % length);
		
		if (length==0):
			log("Ignoring void");
			continue
		
		log("Filling with %i zeros" % (LENGTH-length) )
		if (length>LENGTH):
			sys.strerr.write("Line: %s\nIs too long, can't continue" % line)
			sys.exit(-3)
		
		OUTPUT.write(line)
		
		for i in range(length, LENGTH-1):
			OUTPUT.write("\x00")
		
		if length < LENGTH:
			OUTPUT.write("\n")

if __name__ == "__main__":
	main()

