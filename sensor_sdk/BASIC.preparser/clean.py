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
    f = sys.argv[1]
    f = open(sys.argv[1])
    
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
	elif cont[0].isdigit():
	    if int(cont[0]) > 1023:
		print "WARNING you have a line number that's forbidden", cont[0]
	    lines[int(cont[0])] = cont[1];
    
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
