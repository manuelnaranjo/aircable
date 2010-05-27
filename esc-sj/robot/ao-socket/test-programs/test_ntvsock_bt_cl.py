#
# test_ntvsock_bt_cl.py
# 
# Copyright 2004 Helsinki Institute for Information Technology (HIIT)
# and the authors.  All rights reserved.
# 
# Authors: Tero Hasu <tero.hasu@hut.fi>
#

# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import e32
import appuifw
import time
import thread
import aosocketnativenew
from pdis.lib.best_threading import start_thread

from pdis.lib.logging import *
init_logging(FileLogger("c:\\logs\\aosocket\\testbtclient.txt"))
from aosocket.settings import enable_logging
enable_logging()

def tell(string):
    logwrite(string)
    if e32.is_ui_thread():
        print string
        e32.ao_yield()

# setup Exit key handler
old_title = appuifw.app.title
appuifw.app.title = u"TestApp"

# --------------------------------------------------------------------

address = "00:60:57:d5:ff:f7"




def cl_thread_func(main_lock):

    def cl_read(error, data, dummy):
        try:
            if error == 0:
                tell("read " + data)
            else:
                tell("failed with code %d" % error)
            cl_loop.stop()
        except:
            log_exception()

    def cl_written(error, dummy):
        try:
            if error == 0:
                tell("sent request")
                cl_socket.read_some(1024, cl_read, None)
            else:
                tell("failed with code %d" % error)
                cl_loop.stop()
        except:
            log_exception()

    def cl_connected(error, dummy):
        try:
            if error == 0:
                tell("connected to server")
                cl_socket.write_data("GET / HTTP/1.0\n\n", cl_written, None)
            else:
                tell("failed with code %d" % error)
                cl_loop.stop()
        except:
            log_exception()


    try:
        tell("(client thread)")
    
        cl_socket_serv = aosocketnativenew.AoSocketServ()
        cl_socket_serv.connect()
        tell("created socket server")

        cl_socket = aosocketnativenew.AoSocket()
        tell("created socket")
        cl_socket.open(cl_socket_serv)
        tell("initialized socket")

        tell("attempting connect")
        cl_socket.connect_bt(unicode(address),
                             cl_connected, None)
        tell("connect request made")
    except:
        log_exception()

    cl_loop = aosocketnativenew.AoLoop()
    cl_loop.open()
    cl_loop.start()
    
    cl_loop.close()
    cl_socket.close()
    cl_socket_serv.close()
        
    tell("client now all done, releasing main thread")
    thread_finish_logging()
    main_lock.signal()




















tell("(main thread)")

cl_blocker = e32.Ao_lock()
cl_thread = start_thread(
    target = cl_thread_func,
    name = "client-thread",
    args = (cl_blocker,))
tell("started client thread")

tell("waiting for client")
cl_blocker.wait()

tell("all done")

# --------------------------------------------------------------------

appuifw.app.title = old_title
thread_finish_logging()
finish_logging()
