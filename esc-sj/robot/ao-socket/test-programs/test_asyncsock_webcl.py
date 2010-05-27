#
# test_asyncsock_webcl.py
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

from aosocketnativenew import AoLoop
from aosocket.symbian.symbian_async_socket import *
from aosocket.symbian.symbian_socket import SymbianSocketServ


def ccompleted(orig, evtype, error, data, loop):
    loop.stop()

def wcompleted(orig, evtype, error, data, rescont):
    logwrite("wcompleted")
    if not error:
        logwrite("no errors")

def rcompleted(orig, evtype, error, data, param):
    logwrite("rcompleted")
    try:
        loop, rescont = param
        rescont.append(data)
        loop.stop()
    except:
        log_exception()


try:
    tell("started")
    loop = AoLoop()
    loop.open()
    serv = SymbianSocketServ()
    socket = TcpSymbianAsyncSocket(serv)
    socket.connect(("pdis.hiit.fi", 80), ccompleted, loop)
    loop.start()
    tell("connected")
    
    socket.sendall("GET / HTTP/1.0\n\n", wcompleted, None)
    rescont = []
    socket.recv(1024, rcompleted, (loop, rescont))
    loop.start()
    tell("got result (logged)")
    logwrite(rescont[0])

    socket.close()
    serv.close()
    loop.close()
    tell("all done")
except:
    log_exception()
    appuifw.note(u"Fatal error.", "error")



# --------------------------------------------------------------------

appuifw.app.title = old_title
finish_logging()
