#
# test_ntvsock_bt_sv.py
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
init_logging(FileLogger("c:\\logs\\aosocket\\testbtserver.txt"))
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
                sv_socket.write_data(data + " World!", sv_written, None)
            else:
                tell("failed with code %d" % error)
        except:
            log_exception()
    
    def sv_accepted(error, sv_socket, dummy):
        try:
            if error == 0:
                tell("accepted client")
                sv_socket.read_some(1024, sv_read, None)
            else:
                tell("failed with code %d" % error)
        except:
            log_exception()

    def ac_configured(error, dummy):
        try:
            if error == 0:
                tell("socket configured")
                tell("now making accept request")
                ac_socket.accept_client(sv_socket, sv_accepted, None)
                tell("did accept request")
            else:
                tell("failed with code %d" % error)
        except:
            log_exception()
    
    try:
        tell("(server thread)")

        sv_socket_serv = aosocketnativenew.AoSocketServ()
        sv_socket_serv.connect()
        tell("created socket server")

        ac_socket = aosocketnativenew.AoSocket()
        tell("created socket")
        ac_socket.open(sv_socket_serv)
        tell("initialized socket")

        tell("creating blank socket")
        sv_socket = aosocketnativenew.AoSocket()
        sv_socket.open(sv_socket_serv)
        sv_socket.blank()
        tell("created blank socket")

        tell("calling listen")
        ac_socket.listen_bt()
        tell("socket bound -- now configuring")

        ac_socket.config_bt(ac_configured, None)
        tell("did config request")
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



    




tell("(main thread)")

sv_blocker = e32.Ao_lock()
sv_thread = start_thread(
    target = sv_thread_func,
    name = "server-thread",
    args = (sv_blocker,))
tell("started server thread")
time.sleep(3)

tell("waiting for server")
sv_blocker.wait()

tell("all done")

# --------------------------------------------------------------------

appuifw.app.title = old_title
thread_finish_logging()
finish_logging()
