#!/usr/bin/python

import logging
import gobject
import dbus.glib
import thread

from net.aircable.message import *
from re import compile

from Tkinter import *

global main_loop

KTEMP = compile(r'\$([\+|\-]?\d+):([\+|\-]?\d+)!([\+|\-]?\d+)#K(#[0-1])?$')
KIR = compile(r'\$([\+|\-]?\d+):([\+|\-]?\d+)!([\+|\-]?\d+)#IR#0$')
UPDATE = compile(r'\?UPDATE.*$')
AMB = compile(r'BATT\|(\d*).*\|TAMB\|(\d*).*')
MOISTURE = compile(r'BATT\|(\d*)\s*\|1-WIRE\|1E\,([0-9\.]*)\,([0-9\.]*)\,([0-9\.]*)\,([0-9\.]*)\,.*')

class BannerManager:

    def __init__(self, master):

        frame = Frame(master)
        frame.pack()

        self.frameTop = Label(frame, text="last", fg="red"
		, font=("Malige-t", 80) 
		)
        self.frameTop.pack(side=TOP)
	
	self.frameMiddle = Label(frame, text="middle", fg="green", 
		font=("Maligne-t", 90) )
	self.frameMiddle.pack()
	
	self.frameBottom = Label(frame, text="newest", fg="black", 
		font=("Maligne-t", 100) )
	self.frameBottom.pack(side=BOTTOM)
    
    def pushReading( self, ntext ):
	top = self.frameMiddle.cget('text')
	middle = self.frameBottom.cget('text')
	
	self.frameTop.configure(text=top)
	self.frameMiddle.configure(text=middle)
	self.frameBottom.configure(text=ntext)

def received_message(message):
    body = message.getBody()
    push = 'INVALID'
    if KTEMP.match(body):
	group = KTEMP.findall(body)
	group = group[0]
	push = 'K: %i %sC' % ((int(group[1])+int(group[2]))/20.0 , u'\xb0')
    elif KIR.match(body):
	group = KIR.findall(body)
	group = group[0]
	push = 'IR: %.1f %sC' % ( (int(group[1])/10.0) , u'\xb0' )	
    elif UPDATE.match(body):
	push = 'Update Request'
    elif AMB.match(body):
	group = AMB.findall(body)
	group = group[0]
	push = 'Amb: %i %sC' % ( ((int(group[1]) - 520 ) / 10) , u'\xb0')
    elif MOISTURE.match(body):
	group = MOISTURE.findall(body)[0]
	push = '1W T:%s,H:%s' % ( group [1], group [3] )
	
    app.pushReading(push)

if __name__ == '__main__':
    logging.basicConfig(level=logging.DEBUG,
        format='%(asctime)s %(levelname)s %(message)s',
        filename='/tmp/obex-messages.log',
        filemode='w')
			    
    console = logging.StreamHandler()
    console.setLevel(logging.DEBUG)
				    
    formatter = logging.Formatter('%(levelname)-8s %(message)s')
    console.setFormatter(formatter)
					    
    logging.getLogger('').addHandler(console)
				
    main_loop = gobject.MainLoop()
    
    server = MessageServer(main_loop)
    server.ReceivedCB = received_message
    
    gobject.threads_init()
								
    dbus.glib.init_threads()
    
    root = Tk()
    app = BannerManager(root)
    
    server.startServer('/tmp/airm')
    thread.start_new_thread(root.mainloop, ())

    main_loop.run()
