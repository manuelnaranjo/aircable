'''
Created on 27/09/2010

@author: manuel
'''
import sys
sys.path.append("e:\data\python")

import appuifw, key_codes
import airbotgraphics as graphics
import e32, e32dbm, time
import asyncore60 as asyncore
from protocol2 import Camera, Socket
import btsocket as socket
import myglobalui as globalui
from motor import Robot

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
    lb = appuifw.Listbox(items, lock.signal)
    old_body=appuifw.app.body
    
    appuifw.app.title = title
    appuifw.app.body = lb
    lock.wait()
    appuifw.app.body=old_body
    appuifw.app.title = old_title

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

def callback(frame):
    global img, fps, canvas
    fps+=1
    img=graphics.Image.from_buffer(frame)
    canvas.blit(img)

def err_callback(camera):
    global running
    print "got error", camera.state
    running = False
    appuifw.app.set_exit()

def handle_redraw(rect):
    global img, canvas
    canvas.blit(img)

def key_pressed(event):
    print "key_pressed", event
    if event['type'] == appuifw.EEventKeyUp:
        global robot
        if robot:
            robot.stop()

# make sure we keep the backlight on
t = e32.Ao_timer()
def light_on():
    #Reset the user inactivity time, turning the backlight on, do periodic
    e32.reset_inactivity()
    t.after(30, light_on)
light_on()

def run():
    global robot, camera, timer, canvas
    robot = None
    camera = None

    camera_address=get_camera_address()
    robot_address=get_robot_address()

    camera = Camera(Socket(), callback=callback, err_callback=err_callback)
    camera.connect((camera_address, 1))

    robot = Robot(connect((robot_address,1)))
    robot.forward()
    e32.ao_sleep(1)
    robot.stop()
    e32.ao_sleep(1)
    robot.backward()
    e32.ao_sleep(1)
    robot.stop()

    appuifw.app.orientation = 'landscape'
    appuifw.app.screen = 'normal'
    appuifw.app.title=TITLE
    
    # create canvas
    canvas = appuifw.Canvas(redraw_callback=handle_redraw, event_callback=key_pressed)

    # bind keys
    canvas.bind(key_codes.EKeyUpArrow, robot.forward)
    canvas.bind(key_codes.EKeyDownArrow, robot.backward)
    canvas.bind(key_codes.EKeyLeftArrow, robot.left)
    canvas.bind(key_codes.EKeyRightArrow, robot.right)

    appuifw.app.screen = 'full'
    appuifw.app.body=canvas

    global running
    running = True

    appuifw.app.exit_key_handler=quit

    # fps timer
    timer = e32.Ao_timer()
    #timer.after(1.0, timer_callback)

    asyncore.loop()
    print "loop completed"
    appuifw.app.set_exit()    
    robot.sock.close()
    camera.close()


global img, fps, start
img = graphics.Image.new((480, 360))
start = time.time()
fps = 0

def quit():
    global running, robot, camera
    running = False
    if camera:
        camera.close()
    if robot:
        robot.sock.close()
    appuifw.app.set_exit()

def timer_callback(arg=None):
    global fps, start, timer, canvas
    timer.after(1.0, timer_callback)
    canvas.text((0,100), u"%s fps" % (fps/(time.time()-start)))
    start=time.time()
    fps=0

if __name__=='__main__':
    run()
    