#
# test_tcp_symbsock_webcl.py
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

from pdis.lib.logging import *
init_logging(FileLogger("c:\\logs\\aosocket\\testapp.txt"))

def tell(string):
    logwrite(string)
    if e32.is_ui_thread():
        print string
        e32.ao_yield()

# setup Exit key handler
old_title = appuifw.app.title
appuifw.app.title = u"TestApp"

# --------------------------------------------------------------------

from aosocket.symbian.symbian_socket import TcpSymbianSocket, SymbianSocketServ
from aosocketnativenew import AoLoop


def read(error, payload, sock):
    if error == 0:
        tell("got reply (logged)")
        logwrite(payload)
    else:
        tell("failed to get a reply")
    loop.stop()

def written(error, sock):
    if error == 0:
        tell("sent request")
        sock.recv(1024, read, sock)
    else:
        tell("failed to send a request")
        loop.stop()

def connected(error, sock):
    if error == 0:
        tell("connected")
        sock.sendall("GET / HTTP/1.0\n\n", written, sock)
    else:
        tell("failed to connect")
        loop.stop()


try:
    serv = SymbianSocketServ()
    sock = TcpSymbianSocket()

    loop = AoLoop()
    loop.open()

    tell("making connect request")
    sock.connect(serv, ("pdis.hiit.fi", 80), connected, sock)
    tell("made connect request")
    loop.start()
    
    sock.close()
    serv.close()
    loop.close()
except:
    log_exception()
    appuifw.note(u"Fatal error.", "error")

# --------------------------------------------------------------------

appuifw.app.title = old_title
finish_logging()
