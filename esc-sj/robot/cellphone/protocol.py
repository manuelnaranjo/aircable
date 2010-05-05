import time, re, e32
try:
    import select
except:
    pass

COMMAND_LINE="$GENIESYS%04X\r\n"
CAPTURE_SIZE=re.compile("\$SZE\s*(?P<size>\d+)")

COMMANDS=[
    'COMMAND_ECHO',
    'SET_COMMAND_MODE',
    'SET_PREVIEW_MODE',
    'CAPTURE_COMMAND',
    'SET_CAPTURE_VGA',
    'SET_CAPTURE_QVGA',
    'SET_CAPTURE_QQVGA',
    'GET_VERSION',
    'GET_CAPTURE_SIZE',
    'START_CAPTURE_SEND',
    'SET_RAW_REGISTER',
    'GET_RAW_REGISTER',
    'SET_CAPTURE_SVGA',
    'SET_CAPTURE_XVGA',
    'READ_EEPROM',
    'WRITE_EEPROM',
    'RESET_COMMAND'
]

SIZES = {
    'VGA': 'SET_CAPTURE_VGA',
    'QVGA': 'SET_CAPTURE_QVGA',
    'QQVGA': 'SET_CAPTURE_QQVGA',
    'SVGA': 'SET_CAPTURE_SVGA',
    'XVGA': 'SET_CAPTURE_XVGA',
}

def btselect(in_objs, out_objs, exp_objs, timeout=None):
    ready_in = []
    
    for sock in in_objs:
	if sock._recv_will_return_data_immediately():
	    ready_in.append(sock)

    import e32socket, e32
    lock = e32.Ao_lock()
    if timeout is not None and timeout > 0:
	e32.ao_sleep(timeout, lock.signal)

    if len(ready_in) > 0 or timeout == 0:
	return ( ready_in, [], [] )

    def callback(sock):
	ready_in.append(sock)
	lock.signal()

    for sock in in_objs:
	sock._set_recv_listener(lambda sock=sock:callback(sock))
    lock.wait()
    for sock in in_objs:
	sock._set_recv_listener(None)
    return (ready_in, [], [])

def isPyS60(sock):
    return getattr(sock, 'read_all', None)

def btsendall(socket, data):
#    import e32
#    def sent_callback(*args, **kwargs):
#	lock.signal()

#    lock = e32.Ao_lock()
    socket.send(data)#, cb=sent_callback)
#    lock.wait()
    return

def btrecv(socket, bufsize):
#    import e32
#    print "reading", bufsize
#    def received_callback(*args, **kwargs):
#	print "got", args, kwargs
#	lock.signal()

#    lock = e32.Ao_lock()
#    o = 
    return socket.recv(bufsize)#, cb=received_callback)
#    print time.time(), "lock.wait"
#    lock.wait()
#    return

def do_sendall(sock, data):
#    print "do_sendall", data
    if isPyS60(sock):
	return btsendall(sock, data)
    return sock.sendall(data, socket.MSG_WAITALL)
    
def do_read(sock, bufsize):
    if isPyS60(sock):
	return btrecv(sock, bufsize)
    return sock.recv(bufsize)

def do_select(sock, timeout=1):
    if isPyS60(sock):
        rl = btselect([sock, ], [], [], timeout)
    else:
	rl = select.select([sock, ], [], [], timeout)
    return rl

def send_command(socket, command):
#    print 'send_command', command.strip()
    if type(command) == str:
        command = COMMANDS.index(command)
    command = COMMAND_LINE % command
    return do_sendall(socket, command)

def readbuffer(socket, timeout=0.2, ending=None, bufsize=0xffff, sleep=0.1):
    o = ''
    a = 0
#    socket.setblocking(False)
    last = time.time()
    while [ 1 ]:
	rl = do_select(socket, sleep)[0] # wait until we're ready or timeout
	if len(rl) > 0:
	    b=do_read(socket, bufsize)
    	    a=len(b)
    	    if a>0:
    		o+=b
    		last=time.time()
	if len(o) > 0:
	    if ending:
	        if o.find(ending)>0:
	    #    print "found ending"
		    break
	    elif a==0:
		#print "no more data"
    		break
	if time.time()-last > timeout:
	    #print "timeout"
	    break
	a = 0
#    socket.setblocking(True)
    #print "buffer length", len(o)
    return o

def clearbuffer(socket, timeout=1, sleep=0.2):
    readbuffer(socket, timeout=timeout, sleep=sleep)
    #print "dropped"

def readline(socket, timeout=0.5, sleep=0.2):
    out = readbuffer(socket, timeout, '\r\n', bufsize=1, sleep=sleep)
    #print "readline:", out
    return out

def command_echo(socket, timeout):
    while [ 1 ]:
	send_command(socket, 'COMMAND_ECHO')
        l = readline(socket, timeout=timeout)
        if l.find('ACK') > 0:
            return

def set_command_mode(socket, timeout=1.5):
    send_command(socket, 'SET_COMMAND_MODE')
    clearbuffer(socket, timeout=timeout)

def set_capture_mode(socket, size='VGA', timeout=0.5):
    send_command(socket, SIZES[size])
    clearbuffer(socket, timeout=timeout)

def capture_command(socket, timeout=0.5):
    send_command(socket, 'CAPTURE_COMMAND')
    #clearbuffer(socket, timeout=timeout)

def get_capture_size(socket, timeout=1):
    while [ 1 ]:
	send_command(socket, 'GET_CAPTURE_SIZE')
	for line in readbuffer(socket, timeout).splitlines():
	    res = CAPTURE_SIZE.match(line.strip())
	    if res:
		return int(res.groupdict()['size'])

def start_capture_send(socket, size, timeout=0.2):
    send_command(socket, 'START_CAPTURE_SEND')
    ini = time.time()
    #print "waiting to read %s bytes" % size
    out = ""
    prev = len(out)
    while [ 1 ]:
	out += readbuffer(socket, timeout, sleep=0.2, bufsize=200)
	if prev == len(out): # got nothing for 2 cycles
	    #print "elapsed", time.time()-ini
	    return out
	#print "elapsed", time.time()-ini, len(out)
	prev += len(out)

def setup(socket, timeout=0.2, size='VGA'):
    command_echo(socket, timeout=timeout)
    set_command_mode(socket) # default timeout
    e32.ao_sleep(2)
    set_capture_mode(socket, size=size, timeout=timeout)
    clearbuffer(socket, timeout=timeout)

def grab_picture(socket, timeout=0.2):
    capture_command(socket, timeout=timeout)
    clearbuffer(socket, timeout=timeout)
    size = get_capture_size(socket, timeout=timeout)
    if size == 0xFFFFFFFF:
        raise Exception("function not supported")
    return start_capture_send(socket, size, timeout)

if __name__=='__main__':
    import sys

    pybluez = False

    try:
	from socket import MSG_WAITALL
	import bluetooth as socket
	socket.MSG_WAITALL = MSG_WAITALL
	pybluez = True
	#print "pybluez available"
    except:
	import socket
    
    if len(sys.argv) < 3:
        print "usage %s target <output or count>" % sys.argv[0]
        sys.exit(1)
    
    target = sys.argv[1]
    if pybluez:
	sock = socket.BluetoothSocket( proto = socket.RFCOMM );
    else:
	sock = socket.socket( 
            socket.AF_BLUETOOTH,
	    socket.SOCK_STREAM,
	    socket.BTPROTO_RFCOMM
	);

    #Let BlueZ decide outgoing port
    print 'binding to %s, %i' % ( 0, 0 )
    #sock.bind( (,0) );

    print 'connecting to %s, %i' % ( target, 1 )
    sock.connect( (target, 1) );
    clearbuffer(sock, 2)
    if sys.argv[2].isdigit():
        c = int(sys.argv[2])
        nam = "output"
        ext = "jpg"
    else:
        out=open(sys.argv[2], 'w')
        out.write(grab_picture(sock, 'VGA'))
        clearbuffer(sock)
        out.close()
        print "output created"
        sys.exit(0)
    
    for i in range(c):
        out=open("%s%s.%s" % (nam, i, ext), 'w')
        out.write(grab_picture(sock, 'VGA'))
        clearbuffer(sock)
        out.close()
        print "took %s out of %s" % (i+1, c)    

