# -*- coding: utf-8 -*-
# nokia camera viewer

import btsocket as socket
import appuifw, graphics
import e32
from protocol import *
from os import path
import struct
import os, sys
CONFIG_DIR='E:/'
TEMP_FILE=path.join(CONFIG_DIR, 'camera_temp.jpg')

#def btselect(sock, timeout=None):
#    def timeout_callback():
#	print "timeout callback"
#	lock.signal()
#
#    def data_callback():
#	out = True
#	print "got data callback"
#	lock.signal()
#
#    def check_data_available_callback():
#	if sock._recv_will_return_data_immediately():
#	    out = True
#	    print "there's data available"
#	    lock.signal()
#	print "no data available yet"
#	e32.ao_sleep(0.1, check_data_available_callback)
#
#    if sock._recv_will_return_data_immediately():
#	return True
#
#    out = False
#    lock = e32.Ao_lock()
#    if timeout is not None and timeout > 0:
#	e32.ao_sleep(timeout, timeout_callback)
#
#   e32.ao_sleep(0.1, check_data_available_callback)
#    sock._set_recv_listener(data_callback)
#    lock.wait()
#    sock._set_recv_listener(None)
#    return out
#
# def clearbuffer(sock, timeout=2):
#    print "clearing buffer"
#    def timeout_callback():
#	lock.signal()
#
#    while [ 1 ]:
#	print "select"
#	a = btselect(sock, timeout)
#	if not a:
#	    return
#	a = sock.recv(0xffff)
#	if len(a) == 0:
#	    print "no more data"
#	    return
#	print a

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

appuifw.app.screen = 'full'
print "creating canvas"
canvas = appuifw.Canvas()
appuifw.app.body=canvas

try:
    sock = connect()
except:
    appuifw.note(u'Failed to connect', 'error')
    sys.exit(0)

sock.setblocking(False)
clearbuffer(sock, None, sleep=1)  # wait a second to get something

for i in range(100):
    canvas.text((0,20), u"taking picture")
    temp = file(TEMP_FILE, 'wb')
    p = grab_picture(sock, 'VGA', timeout=0.1)
    canvas.text((0,20), u"saving picture")
    temp.write(p)
    temp.flush()
    temp.close()
    canvas.text((0,20), u"Loading image")
    canvas.blit(graphics.Image.open('E:\\camera_temp.jpg'))

app_lock = e32.Ao_lock()
app_lock.wait()
os.remove(TEMP_FILE)
sock.close()
