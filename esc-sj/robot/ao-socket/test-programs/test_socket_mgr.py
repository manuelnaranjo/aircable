#
# test_socket_mgr.py
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
from pdis.lib.best_threading import start_thread

from pdis.lib.logging import *
from aosocket.MtFileLogger import *
init_logging(MtFileLogger("aosocket", "testapp"))
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

from aosocket.symbian.tcp import TcpManager
from aosocket.symbian.symbian_async_socket import SymbianAsyncSocket


address = ('127.0.0.1', 2001)

def server_loop(manager, mutex):
    try:
        logwrite("(server) now running")
        ac_socket = manager.create_socket(manager.new_socket_instance)
        logwrite("created socket %d" % ac_socket)
        manager.listen_socket(ac_socket, address = address, number = 5)
        logwrite("socket now listening")
        sv_socket = manager.accept_socket(ac_socket)
        logwrite("now connected to a client")
        reqdata = manager.recv_socket(sv_socket, 100)
        logwrite("client said " + reqdata)
        manager.sendall_socket(sv_socket, reqdata + " World!")
        logwrite("sent reply to client")
        time.sleep(1)
        logwrite("server all done")
        thread_finish_logging()
    except:
        log_exception()
    mutex.release()

try:
    manager = TcpManager()
    tell("created manager")
    cl_socket = manager.create_socket(manager.new_socket_instance)
    tell("created client socket %d" % cl_socket)

    blocker = thread.allocate_lock()
    blocker.acquire()
    server_thread = start_thread(
        target = server_loop,
        name = "server-thread",
        args = (manager, blocker))
    tell("started thread")
    time.sleep(3)

    tell("attempting connect")
    manager.connect_socket(cl_socket, address)
    tell("connected client socket")
    time.sleep(1)
    manager.sendall_socket(cl_socket, "Hello")
    tell("did a send")
    data = manager.recv_socket(cl_socket, 1024)
    tell("received response (logged)")
    logwrite(data)
    time.sleep(1)
    manager.close_socket(cl_socket)
    tell("closed client socket")
     
    blocker.acquire()
    manager.close()
except:
    log_exception()
    appuifw.note(u"Fatal error.", "error")

# --------------------------------------------------------------------

appuifw.app.title = old_title
tell("main thread all done")
thread_finish_logging()
finish_logging()
