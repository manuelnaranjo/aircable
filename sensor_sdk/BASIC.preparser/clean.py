import sys

lines=dict()
interrupts={
    '@ERASE': False,
    '@INIT': 0,
    '@IDLE': 0,
    '@SLAVE': 0,
    '@MASTER': 0,
    '@PIN_CODE': 0,
    '@PIO_IRQ': 0,
    '@INQUIRY': 0,
    '@MESSAGE': 0,
    '@CONTROL': 0,
    '@SENSOR': 0,
    '@ALARM': 0,
    '@UART': 0,
    '@FTP': 0,
}


if __name__=='__main__':
    if len(sys.argv) > 1:
	f = open(sys.argv[1])
    else:
	f = sys.stdin
    
    for line in f.readlines():
	if len(line.strip()) == 0:
	    continue
	    
	line=line.strip()
	cont = line.split(' ', 1)
	if cont[0] in interrupts:
	    if cont[0] == '@ERASE':
		interrupts['@ERASE']=True
	    else:
		interrupts[cont[0]]=cont[1]
	elif cont[0].isdigit() and int(cont[0]) > 0:
	    if int(cont[0]) > 1023:
		sys.stderr.write("WARNING you have a line number that's forbidden %s\n" % cont[0])
	    if int(cont[0]) in lines:
		sys.stderr.write("WARNING line %s was overwritten\n" % cont[0])
		sys.stderr.write("\tPrevious:\t%s\n" % lines[int(cont[0])])
		sys.stderr.write("\tNew:\t\t%s\n\n" % line)
	    if len(cont)>1:
		lines[int(cont[0])] = cont[1];
	    else:
		lines[int(cont[0])] = None
    
    if interrupts['@ERASE']:
	print "@ERASE"
	print 
    v = interrupts.keys()
    v.remove('@ERASE')
    for key in v:
	print key, interrupts[key]
    
    print ''
    for k in range(1,1023):
	if k in lines:
	    print k, lines[k]
    print ''
