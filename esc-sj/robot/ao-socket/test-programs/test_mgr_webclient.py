#
# test_mgr_webclient.py
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
from aosocket.symbian.symbian_itc import safe_ao_waittid
from aosocketnativenew import on_wins

from pdis.lib.logging import *
init_logging(FileLogger("c:\\logs\\aosocket\\testapp.txt"))

if on_wins():
    def aoyield():
        def wait(mutex):
            time.sleep(0.1)
            mutex.release()
        mutex = thread.allocate_lock()
        mutex.acquire()
        thread.start_new_thread(wait, (mutex,))
        mutex.acquire()
else:
    def aoyield():
        tid = thread.start_new_thread(time.sleep, (0.1,))
        thread.ao_waittid(tid)

def tell(string):
    logwrite(string)
    print string
    aoyield()

# setup Exit key handler
old_title = appuifw.app.title
appuifw.app.title = u"TestApp"

# --------------------------------------------------------------------

# This is a white-box test of the internals of TcpManager.  See
# pdis.pipe.blocking_socket for the normal external interface.

from aosocket.symbian.tcp import TcpManager

address = ('pdis.hiit.fi', 80)

try:
    manager = TcpManager()
    tell("created manager")
    cl_socket = manager.create_socket(manager.new_socket_instance)
    tell("created client socket %d" % cl_socket)

    manager.connect_socket(cl_socket, host = address[0], port = address[1])
    tell("connected client socket")
    time.sleep(1)
    manager.sendall_socket(cl_socket, "GET / HTTP/1.0\n\n")
    tell("did a send")
    data = manager.recv_socket(cl_socket, 1024)
    tell("received response (logged)")
    logwrite(data)
    time.sleep(1)
    manager.close_socket(cl_socket)
    tell("closed client socket")
     
    manager.close()
except:
    log_exception()
    appuifw.note(u"Fatal error.", "error")

# --------------------------------------------------------------------

appuifw.app.title = old_title
finish_logging()
