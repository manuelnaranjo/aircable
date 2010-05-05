# -*- coding: utf-8 -*-
# nokia camera viewer

import btsocket as socket
import appuifw, graphics, key_codes
import e32
from os import path
import struct
import os, sys
import sysinfo

from protocol import *
import protocol
from motor import Robot

#CONFIG_DIR='E://camera_temp.jpg'
#TEMP_FILE=path.join(CONFIG_DIR, 'camera_temp.jpg')
TEMP_FILE='E:\\camera_temp.jpg'

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

camera = None
robot = None

def Connect(camera, robot, camera_address='00:22:BF:00:02:17', robot_address='00:50:C2:7F:42:A2'):
    try:
	if not camera:
	    camera = connect( (camera_address, 1)  )
	if not robot:
	    a = connect( (robot_address, 1)  )
	    robot = Robot( a )
    except Exception, err:
	appuifw.note(u'Failed to connect: %s' % str(err), 'error')
	sys.exit(0)
    return camera, robot

camera, robot = Connect(camera, robot)

KEYS={
    key_codes.EStdKeyLeftArrow: robot.left,
    key_codes.EStdKeyRightArrow:robot.right,
    key_codes.EStdKeyUpArrow:   robot.forward,
    key_codes.EStdKeyDownArrow: robot.backward,
    'stop':                     robot.stop
}

def key_pressed(event):
    if event['type'] == appuifw.EEventKeyUp:
         robot.stop()

# img buffer
img = graphics.Image.new(sysinfo.display_pixels())
def vf(im):
    global img
    img.blit(im)
    handle_redraw(())

def handle_redraw(rect):
    global canvas, img
    canvas.blit(img)

appuifw.app.screen = 'full'
appuifw.app.orientation = 'landscape'
canvas = appuifw.Canvas(event_callback=key_pressed, redraw_callback=handle_redraw)

canvas.bind(key_codes.EKeyUpArrow, robot.forward)
canvas.bind(key_codes.EKeyDownArrow, robot.backward)
canvas.bind(key_codes.EKeyLeftArrow, robot.left)
canvas.bind(key_codes.EKeyRightArrow, robot.right)
appuifw.app.body=canvas

camera.setblocking(False)
clearbuffer(camera, None, sleep=1)  # wait a second to get something

running = True

def quit():
    running = False
    #os.remove(TEMP_FILE)
    camera.close()
    robot.sock.close()
    appuifw.app.set_exit()


appuifw.app.exit_key_handler=quit

canvas.text((0,20), u'clear buffer')
clearbuffer(camera, timeout=2)

command_echo(camera, timeout=1)
canvas.text((0,20), u'command _mode')
set_command_mode(camera) # default timeout
canvas.text((0,20), u'sleeping')
e32.ao_sleep(2)
canvas.text((0,20), u'capture mode')
set_capture_mode(camera, size='QVGA', timeout=1)
canvas.text((0,20), u'clear buffer')
clearbuffer(camera, timeout=1)

while running:
    canvas.text((0,20), u'taking picture')
    try:
	p=grab_picture(camera, timeout=0.5)
    except Exception, err:
	appuifw.note(u'Lost Camera Connection: %s' % str(err), 'error')
	camera.close()
	camera=None
	camera, robot = Connect(camera, robot)

    canvas.text((0,20), u'saving')
    temp = file(TEMP_FILE, 'wb')
    temp.write(p)
    temp.flush()
    temp.close()

    canvas.text((0,20), u'display')
    try:
	vf(graphics.Image.open(TEMP_FILE)\
	    .transpose(graphics.FLIP_LEFT_RIGHT)\
	    .transpose(graphics.FLIP_TOP_BOTTOM)\
	    .resize((640, 480), keepaspect=1)
	)
    except Exception, err:
	canvas.text((0,20), u'error: %s' % str(err))

    e32.ao_yield()
