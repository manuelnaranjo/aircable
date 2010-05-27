# -*- coding: utf-8 -*-
# nokia camera viewer

import btsocket as socket
import appuifw, key_codes
import airbotgraphics as graphics
import e32, e32dbm
from os import path
import struct
import os, sys
import sysinfo
import time

from protocol import *
import protocol
from motor import Robot

TEMP_FILE='E:\\airbot_temp.jpg'
DATABASE='E:\\airbot.db'

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

db=e32dbm.open(DATABASE,"c")

def get_camera_address():
    if 'CAMERA' in db:
	if appuifw.query(u'Use %s as Camera?' % db['CAMERA'], u'query'):
	    return db['CAMERA']
    appuifw.note(u'Scanning for Camera', u'info')
    sock=socket.socket(socket.AF_BT,socket.SOCK_STREAM)
    addr,services=socket.bt_discover()
    db['CAMERA'] = addr
    db.sync()
    return addr

def get_robot_address():
    if 'ROBOT' in db:
	if appuifw.query(u'Use %s as Robot Controller?' % db['ROBOT'], u'query'):
	    return db['ROBOT']
    
    appuifw.note(u'Scanning for Robot Controller', u'info')
    sock=socket.socket(socket.AF_BT,socket.SOCK_STREAM)
    addr,services=socket.bt_discover()
    db['ROBOT'] = addr
    db.sync()
    return addr

camera = None
robot = None

def Connect(camera, robot, camera_address=None, robot_address=None):
    if not camera_address: 
	    camera_address=get_camera_address()
    if not robot_address:	
	    robot_address=get_robot_address()
    db.sync()

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

def key_pressed(event):
    if event['type'] == appuifw.EEventKeyUp:
	if robot:
	  robot.stop()

# img buffer
img = graphics.Image.new((480, 360))

def handle_redraw(rect):
    #global canvas, img
    canvas.blit(img)

appuifw.app.screen = 'full'
appuifw.app.orientation = 'landscape'
canvas = appuifw.Canvas(redraw_callback=handle_redraw, event_callback=key_pressed)

# make sure we keep the backlight on
t = e32.Ao_timer()
def light_on():
    #Reset the user inactivity time, turning the backlight on, do periodic
    e32.reset_inactivity()
    t.after(30, light_on)
light_on()

# key handlers
def forward():
    if robot: 
      robot.forward()

def backward():
    if robot:
      robot.backward()

def left():
    if robot:
      robot.left()

def right():
    if robot:
      robot.right()

# bind keys
canvas.bind(key_codes.EKeyUpArrow, forward)
canvas.bind(key_codes.EKeyDownArrow, backward)
canvas.bind(key_codes.EKeyLeftArrow, left)
canvas.bind(key_codes.EKeyRightArrow, right)
appuifw.app.body=canvas

running = True

def quit():
    global running
    running = False
    db.close()
    os.remove(TEMP_FILE)
    send_command(camera, 'COMMAND_ECHO')
    camera.close()
    robot.sock.close()
    os.remove(TEMP_MOVIE)
    appuifw.app.set_exit()

appuifw.app.exit_key_handler=quit

setup(camera, size="QQVGA")

camera_stream=stream_mode(camera)
while running:
    p=None
    p=camera_stream.next()
    
    try:
	img=graphics.Image.from_buffer(p)
	e32.ao_yield()
    	canvas.blit(img)
    except Exception, err:
	canvas.text((0,100), u'error: %s %s' % (str(err), time.time()))
    e32.ao_yield()
