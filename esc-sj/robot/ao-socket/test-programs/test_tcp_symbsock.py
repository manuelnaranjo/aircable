#
# test_tcp_symbsock.py
# 
# Copyright 2004 Helsinki Institute for Information Technology (HIIT)
# and the authors.  All rights reserved.
# 
# Authors: Tero Hasu <tero.hasu@hut.fi>
#
# Tests the TcpSymbianSocket API.
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
init_logging(FileLogger("c:\\logs\\aosocket\\testapp.txt"))
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

from aosocket.symbian.symbian_socket import *

client_mode = False

if client_mode:
    address = ('pdis.hiit.fi', 80)
else:
    address = ('127.0.0.1', 2001)







def sv_thread_func(main_lock):
    
    def sv_written(error, dummy):
        try:
            if error == 0:
                tell("sent reply")
            else:
                tell("failed with code %d" % error)
            sv_loop.stop()
        except:
            log_exception()
    
    def sv_read(error, data, dummy):
        try:
            if error == 0:
                tell("got request " + data)
                tell("sending reply")
                sv_socket.sendall(data + " World!", sv_written, None)
                tell("reply send request made")
            else:
                tell("failed with code %d" % error)
                sv_loop.stop()
        except:
            log_exception()
    
    def sv_accepted(error, sv_socket, dummy):
        try:
            if error == 0:
                tell("accepted client, now making read request")
                sv_socket.recv(1024, sv_read, None)
                tell("did read request")
            else:
                tell("failed with code %d" % error)
                sv_loop.stop()
        except:
            log_exception()
        
    try:
        tell("(server thread)")

        sv_socket_serv = SymbianSocketServ()
        tell("created socket server")

        ac_socket = TcpSymbianSocket()
        tell("created socket")

        tell("creating blank socket")
        sv_socket = TcpSymbianSocket()
        sv_socket.blank(sv_socket_serv)
        tell("created blank socket")

        tell("calling listen")
        ac_socket.listen(sv_socket_serv, address, 5)
        tell("now listening -- doing an accept")
        ac_socket.accept(sv_socket, sv_accepted, None)
        tell("did accept request")
    except:
        log_exception()

    sv_loop = aosocketnativenew.AoLoop()
    sv_loop.open()
    sv_loop.start()
    
    sv_loop.close()
    sv_socket.close()
    ac_socket.close()
    sv_socket_serv.close()
        
    tell("server now all done, releasing main thread")
    thread_finish_logging()
    main_lock.signal()


    





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
                cl_socket.recv(1024, cl_read, None)
            else:
                tell("failed with code %d" % error)
                cl_loop.stop()
        except:
            log_exception()

    def cl_connected(error, dummy):
        try:
            if error == 0:
                tell("connected to server")
                cl_socket.sendall("GET / HTTP/1.0\n\n", cl_written, None)
            else:
                tell("failed with code %d" % error)
                cl_loop.stop()
        except:
            log_exception()


    try:
        tell("(client thread)")
    
        cl_socket_serv = SymbianSocketServ()
        tell("created socket server")

        cl_socket = TcpSymbianSocket()
        tell("created socket")

        tell("attempting connect")
        cl_socket.connect(cl_socket_serv, address,
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

if not client_mode:
    sv_blocker = e32.Ao_lock()
    sv_thread = start_thread(
        target = sv_thread_func,
        name = "server-thread",
        args = (sv_blocker,))
    tell("started server thread")
    time.sleep(3)

cl_blocker = e32.Ao_lock()
cl_thread = start_thread(
    target = cl_thread_func,
    name = "client-thread",
    args = (cl_blocker,))
tell("started client thread")

if not client_mode:
    tell("waiting for server")
    sv_blocker.wait()
tell("waiting for client")
cl_blocker.wait()

tell("all done")

# --------------------------------------------------------------------

appuifw.app.title = old_title
thread_finish_logging()
finish_logging()
