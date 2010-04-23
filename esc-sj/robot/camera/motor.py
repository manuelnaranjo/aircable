import btsocket as socket
import appuifw, e32, key_codes

def connect(address=None):
    """Form an RFCOMM socket connection to the given address. If
    address is not given or None, query the user where to connect. The
    user is given an option to save the discovered host address and
    port to a configuration file so that connection can be done
    without discovery in the future.

    Return value: opened Bluetooth socket or None if the user cancels
    the connection.
    """

    # Bluetooth connection
    sock=socket.socket(socket.AF_BT,socket.SOCK_STREAM)

    if not address:
            print "Discovering..."
            try:
                addr,services=socket.bt_discover()
            except socket.error, err:
                if err[0]==2: # "no such file or directory"
                    appuifw.note(u'No serial ports found.','error')
                elif err[0]==4: # "interrupted system call"
                    print "Cancelled by user."
                elif err[0]==13: # "permission denied"
                    print "Discovery failed: permission denied."
                else:
                    raise
                print "exception on bt_discover"
                return None
            print "Discovered: %s, %s"%(addr,services)
            address=(addr,1)

    print "Connecting to "+str(address)+"...",
    try:
        sock.connect(address)
    except socket.error, err:
        if err[0]==54: # "connection refused"
            appuifw.note(u'Connection refused.','error')
        raise
    print "OK."
    return sock


try:
    print "sock1"
    sock1 = connect( ('00:50:C2:7F:42:A2',1) )
    print "sock2"
    sock2 = connect( ('00:22:BF:00:02:17',1) )

except:
    appuifw.note(u'Failed to connect', 'error')
    sys.exit(0)

print "set blocking"
sock1.setblocking(False)
sock2.setblocking(False)

def M0_stop():
    return '\x88\x00' # M0 stop

def M0_forward():
    return '\x89\x7f'# M0 full steam ahead

def M0_backward():
    return '\x8B\x7f'# M0 full steam backward

def M1_stop():
    return '\x8C\x00' 

def M1_forward():
    return '\x8D\x7f'

def M1_backward():
    return '\x8F\x7f'

def stop(socket):
    socket.send(M0_stop()+M1_stop())

def forward(socket):
    socket.send(M0_forward()+M1_forward())

def backward(socket):
    socket.send(M0_backward()+M1_backward())

def right(socket):
    socket.send(M1_forward()+M0_backward())


def left(socket):
    socket.send(M0_forward()+M1_backward())

KEYS={
    key_codes.EStdKeyLeftArrow: left,
    key_codes.EStdKeyRightArrow: right,
    key_codes.EStdKeyUpArrow: forward,
    key_codes.EStdKeyDownArrow: backward
}

def key_pressed(event):
    global sock1
    code=event['scancode']
    if event['type'] == appuifw.EEventKeyDown:
         if code in KEYS:
            KEYS[code](sock1)
    elif event['type'] == appuifw.EEventKeyUp:
        print "button released"
        stop(sock1)

appuifw.app.screen = 'full'
print "creating canvas"
canvas=appuifw.Canvas(
	event_callback=key_pressed, 
	redraw_callback=None)
appuifw.app.body=canvas

running = True

appuifw.app.exit_key_handler=quit

def quit():
    global running
    running=False
    appuifw.app.set_exit()

while running:
    e32.ao_yield()

sock1.close()
sock2.close()
sys.exit(0)
