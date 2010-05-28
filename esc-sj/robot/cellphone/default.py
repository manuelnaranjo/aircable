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
import myglobalui as globalui

from protocol import *
import protocol
from motor import Robot

TEMP_FILE='E:\\airbot_temp.jpg'
DATABASE='E:\\airbot.db'

TITLE=u"AIRbot"

def inquiry(title=None):
    from aosocketnativenew import AoResolver
    items = list()
    lock = e32.Ao_lock()
    old_title = appuifw.app.title
    noteId=globalui.global_note(u"Scanning...", u"wait")
    print "noteId", noteId
    #appuifw.app.title = u"Scanning Please Wait..."
  
    def discovered(error, address, name, *args, **kwargs):
	try:
	    if not error:
		address = ':'.join([ address[i*2:(i*2)+2] for i in range(6)]).upper()
		print "found", address, name
		items.append(("%s [%s]" %(name, address), address))
		resolver.next()
	    else:
		print "Scan completed", error
		lock.signal()
	except Exception, err:
	    appuifw.note(u'Failed to discover: %s' % err,'error')
	    lock.signal()
    
    try:
	resolver=AoResolver()
	resolver.open()
	resolver.discover(discovered, None)
  
	# start inquiry
	lock.wait()

	# if we get here then the inquiry ended
	resolver.close()
    except Exception, err:
	appuifw.note(u'Failed to discover: %s' % err,'error')
	lock.signal()

    globalui.global_notehide(noteId)

    if len(items) == 0:
	appuifw.app.title = old_title
	raise Exception("None device found")

    lock = e32.Ao_lock()
    #Define a function that is called when an item is selected
    def handle_selection():
	lock.signal()
 
    #Create an instance of Listbox and set it as the application's body
    lb = appuifw.Listbox(items, handle_selection)
    old_body=appuifw.app.body
    appuifw.app.body = lb
    appuifw.app.title = title
    lock.wait()
    appuifw.app.title = old_title
    appuifw.app.body=old_body

    return items[lb.current()][1]

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
	    addr = inquiry()
            print "selected", addr
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

    print "Discovering..."
    addr = inquiry(u"Choose Camera Device")
    print "selected", addr

    db['CAMERA'] = addr
    db.sync()
    return addr

def get_robot_address():
    if 'ROBOT' in db:
	if appuifw.query(u'Use %s as Robot Controller?' % db['ROBOT'], u'query'):
	    return db['ROBOT']

    print "Discovering..."
    addr = inquiry(u"Choose Robot Controller")
    print "selected", addr
    
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

def key_pressed(event):
    if event['type'] == appuifw.EEventKeyUp:
	if robot:
	  robot.stop()


def handle_redraw(rect):
    #global canvas, img
    canvas.blit(img)

# make sure we keep the backlight on
t = e32.Ao_timer()
def light_on():
    #Reset the user inactivity time, turning the backlight on, do periodic
    e32.reset_inactivity()
    t.after(30, light_on)
light_on()

#appuifw.app.orientation = 'landscape'
appuifw.app.screen = 'normal'
appuifw.app.title=TITLE

camera, robot = Connect(camera, robot)

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

# img buffer
img = graphics.Image.new((480, 360))

# create canvas
canvas = appuifw.Canvas(redraw_callback=handle_redraw, event_callback=key_pressed)

# bind keys
canvas.bind(key_codes.EKeyUpArrow, forward)
canvas.bind(key_codes.EKeyDownArrow, backward)
canvas.bind(key_codes.EKeyLeftArrow, left)
canvas.bind(key_codes.EKeyRightArrow, right)

appuifw.app.screen = 'full'
appuifw.app.body=canvas

running = True

def quit():
    global running
    running = False
    os.remove(TEMP_FILE)
    send_command(camera, 'COMMAND_ECHO')
    camera.close()
    robot.sock.close()
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
