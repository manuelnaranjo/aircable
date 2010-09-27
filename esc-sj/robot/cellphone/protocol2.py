'''
Created on 20/09/2010

@author: manuel
'''

import time, re
from functools import partial
    
S60=False

try:
    import e32
    S60=True
except:
    pass

if __name__=='__main__' and S60:
    import sys
    sys.path.append("e:\data\python")

if not S60:
    import asyncore
else:
    import asyncore60 as asyncore

pybluez = False
try:
    import btsocket as socket
except:
    try:
        import bluetooth
        pybluez=True
    except:
        import socket
        socket.AF_BT = socket.AF_BLUETOOTH

try:
    import logging 
    logging.basicConfig()
    logger=logging.getLogger('AIRcam')
    logger.setLevel(logging.DEBUG)
except:
    def internal_print(x):
        print x
    logger = object()
    logger.debug=internal_print
    logger.info=internal_print
    logger.error=internal_print
    
    
if not pybluez:
    Socket = partial(socket.socket, socket.AF_BT ,socket.SOCK_STREAM)
else:
    Socket = bluetooth.BluetoothSocket    
    
class FSM():
    NOTHING, \
    CONNECTING, \
    WELCOME, \
    SETUP, \
    IDLE, \
    STREAM, \
    ERROR, \
    COMMAND_MODE = range(8)

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

JPG_START=chr(0xff)+chr(0xD8)
JPG_END  =chr(0xff)+chr(0xD9)
def find_jpeg(buffer):
    start = buffer.find(JPG_START)
    end = buffer.find(JPG_END, start)
    return start, end

def isascii(buffer):
    try:
        buffer.decode('ascii')
        print "ascii"
        return True
    except UnicodeDecodeError:
        return False

class Camera(asyncore.dispatcher):
    last_time = None

    def __init__(self, sock, size=None, callback=lambda x: None, err_callback=lambda x: None):
        asyncore.dispatcher.__init__(self, sock=sock)
        self.size=size or 'QQVGA'
        self.callback=callback 
        self.err_callback = err_callback
        self.state = FSM.IDLE
        self.buffer = ''
    
    def connect(self, *args, **kwargs):
        self.state = FSM.CONNECTING
        asyncore.dispatcher.connect(self, *args, **kwargs)
    
    def handle_connect(self):
        # gets called as soon as we get connected, or when
        # we are waiting for the camera to leave the stream mode
        # or the error state
        logger.info("handle_connect")
        self.state = FSM.WELCOME
        #try:
        #    print self.recv(4096)
        #except Exception, err:
        #    print err
        logger.info("connect done")
        
    def handle_read(self):
        self.buffer+=self.recv(4096)
        
        if self.state in [FSM.WELCOME, FSM.ERROR, FSM.COMMAND_MODE]:
            # give control back to the handle connect mode until we're ready
            return self.do_welcome()
            
        if self.state != FSM.STREAM:
            logger.info("Invalid state on handle_read %i" % self.state)
            return
        
        if 'Over run Err' in self.buffer:
            logger.error("Over Run Error")
            self.do_error()
            
        start, end = find_jpeg(self.buffer)
        ready = start > -1 and end > -1 
        if not ready:
            if isascii(self.buffer):
                logger.debug(self.buffer)
            return
        
        self.callback(self.buffer[start:end+2])
        self.buffer = self.buffer[end+2:]
        
    def handle_close(self):
        logger.info("handle close")
        self.close()
        self.err_callback(self)
    
    def do_delay(self):
        if self.last_time and time.time() - self.last_time < 3:
            logger.info("Waiting for 3 seconds")
            return True
        self.last_time = time.time()
        return False

    
    def do_error(self):
        # once we get into this state the only way to go on
        # is reseting the chip, an ACK0000 will tell us 
        # when the chip is ready again
        logger.debug(self.buffer)
        if self.do_delay():
            return
        self.state = FSM.ERROR
        self.sendcommand('RESET_COMMAND')
        self.sendcommand('COMMAND_ECHO')
        self.buffer = ""
    
    def do_ack(self):
        self.sendcommand("RESET_COMMAND")
        time.sleep(2)
        self.sendcommand("COMMAND_ECHO")
    
    def do_welcome(self):
        logger.info("do_welcome")
        if isascii(self.buffer):
            logger.info(self.buffer)
            
        if 'ACK0000' in self.buffer: # camera was ready we can go on
            self.last_time = None
            time.sleep(0.01) # give time to processor to settle
            self.buffer = self.buffer[self.buffer.find('ACK0000')+9:]
            self.do_setup()
        elif 'Over run Err' in self.buffer or 'Decode Overrun' in self.buffer:
            # camera got into unstable state 
            logger.info("Error state")
            self.do_error()           
        elif not isascii(self.buffer): # and self.state != FSM.COMMAND_MODE:
            # camera is still streaming from previous connection
            logger.info("seems it is all ready in streaming mode")
            #self.sendcommand('SET_COMMAND_MODE') # tell the camera to stop the stream
            try:
                time.sleep(2)
                self.buffer+=self.recv(4096*4)
            except:
                logger.info("No more data in the buffer on first try")
            try:
                time.sleep(2)
                self.buffer+=self.recv(4096*4)
                self.state = FSM.STREAM
                logger.info("Camera was all ready in stream mode and can keep it")
            except:
                logger.info("No more data in the buffer on second try, can't get it up")
                self.handle_close()
            
        elif self.state == FSM.COMMAND_MODE:
            logger.info("are we ready?")
            time.sleep(.2) # ok wait for 200 ms and fill up the buffer with the remaining stuff
            try:
                self.buffer+=self.recv(1)
                logger.info("got something")
                return # there was still data in the buffer
            except:
                # no more data, we filled up our buffer
                self.do_ack()
                self.state=FSM.WELCOME
                return
        else:
            logger.debug("buffer not ready yet")
        
    def do_setup(self):
        logger.info("do setup")
        self.state = FSM.SETUP
        self.sendcommand(SIZES[self.size])
        self.sendcommand('SET_PREVIEW_MODE')
        self.state = FSM.STREAM

    def sendcommand(self, command):
        logger.info("Send Command %s" % command)
        if type(command) == str:
            command = COMMANDS.index(command)
        command = COMMAND_LINE % command
        self.send(command)
        time.sleep(0.1)

def testS60():
    import appuifw, key_codes
    import airbotgraphics as graphics
    import e32, e32dbm
    
    def handle_redraw(rect):
        global img
        canvas.blit(img)

    global img
    img = graphics.Image.new((480, 360))
    
    global fps, start
    start = time.time()
    fps = 0

    # create canvas
    canvas = appuifw.Canvas(redraw_callback=handle_redraw)

    appuifw.app.screen = 'full'
    appuifw.app.body=canvas

    global running
    running = True

    timer = e32.Ao_timer()
    
    def quit():
        global running
        running = False
        appuifw.app.set_exit()

    appuifw.app.exit_key_handler=quit

    def timer_callback(arg=None):
        global fps, start
        timer.after(1.0, timer_callback)
        canvas.text((0,100), u"%s fps" % (fps/(time.time()-start)))
        start=time.time()
        fps=0
        
    timer.after(1.0, timer_callback)
    def callback(frame):
        global img, fps
        fps+=1
        img=graphics.Image.from_buffer(frame)
        canvas.blit(img)

    def err_callback(camera):
        print "got error", camera.state
        time.sleep(10)
        running = False
        appuifw.app.set_exit()
    
    target = "00:22:BF:00:01:34"

    c = Camera(Socket(), callback=callback, err_callback=err_callback)
    print "connecting to", target
    c.connect((target, 1))
    asyncore.loop()
    print "loop completed"    

def test():
    global myflag
    myflag = False
    
    def callback(frame):
        print "got frame", len(frame)
    
    def err_callback(camera):
        global myflag
        myflag = True
        print "got error", camera.state
    
    import sys
    if len(sys.argv) == 1:
        print "usage: %s <target>" % sys.argv[0]
        sys.exit(1)
    target = sys.argv[1]

    c = Camera(Socket(), callback=callback, err_callback=err_callback)
    print "connecting to", target
    c.connect((target, 1))
    asyncore.loop()
    print "loop completed"
    
    if myflag:
        logger.info("waiting 4 seconds")
        time.sleep(4)
        c = Camera(Socket(), callback=callback, err_callback=err_callback)
        print "connecting to", target
        c.connect((target, 1))
        asyncore.loop()
        print "loop completed"

if __name__=='__main__':
    if not S60:
        test()
    else:
        testS60()
