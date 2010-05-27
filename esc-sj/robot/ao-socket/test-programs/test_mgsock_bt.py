#
# test_mgsock_bt.py
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
init_logging(FileLogger("c:\\logs\\aosocket\\testapp.txt"))
from aosocket.settings import enable_logging
enable_logging()

def tell(string):
    logwrite(string)
    if e32.is_ui_thread():
        print string
        e32.ao_yield()

# --------------------------------------------------------------------




def sv_thread_func():
    try:
        tell("(server thread)")

        tell("starting to listen")
        ac_socket = _manager.listen(())
        tell("accepting a connection")
        sv_socket = ac_socket.accept()
        tell("connection accepted")
        request = sv_socket.recv(512)
        tell("received " + request)
        tell("sending response")
        sv_socket.sendall(request + " -- i am Server")
        tell("response sent")
        time.sleep(1)

        tell("server now all done")
    except:
        log_exception()




def cl_thread_func():
    try:
        tell("(client thread)")

        tell("connecting to server")
        cl_socket = _manager.connect((address,))
        tell("connected")
        tell("sending a request")
        cl_socket.sendall("i am Client, what are you")
        tell("request sent")
        tell("reading any reply")
        tell(cl_socket.recv(512))
        tell("reply read")

        tell("client now all done")
    except:
        log_exception()













try:
    roles = [u"client", u"server"]
    i = appuifw.popup_menu(roles, u"Select role:")
    tell("selected " + str(i))
    if i is not None:

        amClient = (i == 0)
        address = None

        if amClient:
            peers = [u"00:60:57:d5:ff:f7", u"00:11:9F:6E:9A:51",
                     u"00:0E:ED:0F:A5:C4"]
            i = appuifw.popup_menu(peers, u"Select peer:")
            tell("selected " + str(i))
            if i is not None:
                address = peers[i]

        if (not amClient) or address:
            from aosocket.symbian.bt import BtManager
            _manager = BtManager(400)
            try:
                tell("(main thread)")

                if amClient:
                    target = cl_thread_func
                else:
                    target = sv_thread_func
                
                tid = start_thread(
                    target = target,
                    name = "worker-thread",
                    args = ())
                tell("started thread")

                tell("waiting for worker thread to finish")
                thread.ao_waittid(tid)

                tell("all done")
            finally:
                _manager.close()
except:
    log_exception()
    appuifw.note(u"Fatal error.", "error")
