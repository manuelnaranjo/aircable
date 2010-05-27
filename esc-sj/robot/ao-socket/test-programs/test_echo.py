#
# test_echo.py
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
from aosocket.MtFileLogger import *
init_logging(MtFileLogger("aosocket", "testapp"))

def tell(string):
    logwrite(string)
    if e32.is_ui_thread():
        print string
        e32.ao_yield()

# setup Exit key handler
old_title = appuifw.app.title
appuifw.app.title = u"TestApp"

# --------------------------------------------------------------------

tell("(main thread)")
tell("thread %d in main" % thread.get_ident())

## register a TCP manager
from aosocket.symbian.tcp import TcpManager
from pdis.socket.transport_registry import register_manager
_manager = TcpManager()
register_manager("ao_tcp", _manager)
register_manager("tcp", _manager)

# --------------------------------------------------------------------

from pdis.lib.best_threading import start_thread
from pdis.socket.safe_socket import SafeSocket
from pdis.socket.buffered_stream import BufferedStream
from pdis.socket.socket_exceptions import ServerTerminated
from pdis.socket.transport_registry import connect, listen

def echo_loop(stream):
    try:
        tell("thread %d in echo_loop" % thread.get_ident())
        while True:
            data = stream.readline()
            if not data:
                stream.close()
                break
            stream.write(data)
            stream.flush()
        tell("Echo loop exited normally.")
    except:
        tell("Echo loop exited abnormally.")
    thread_finish_logging()

def accept_loop(server):
    tell("thread %d in accept_loop" % thread.get_ident())
    try:
        while True:
            endpoint = server.accept()
            stream = BufferedStream(SafeSocket(endpoint))
            start_thread(echo_loop, args = (stream,))
    except ServerTerminated:
        tell("Accept loop exited normally.")
    except:
        tell("Accept loop exited abnormally.")
    tell("releasing main thread")
    thread_finish_logging()
    mn_wait_acc.release()

address = ("tcp", "localhost", 12345)

server = listen(address)
mn_wait_acc = thread.allocate_lock()
mn_wait_acc.acquire()
start_thread(accept_loop, args = (server,))

client = connect(address)
stream = BufferedStream(SafeSocket(client))

stream.write("Hello world!\n")
stream.flush()
print stream.readline(),

stream.write("This is a")
stream.write(" test.\n")
stream.flush()
print stream.readline(),

stream.close()
assert not stream.readline()

tell("closing server")
server.close()
tell("waiting for server to die")
mn_wait_acc.acquire()
time.sleep(0.2)

# --------------------------------------------------------------------

_manager.close()

# --------------------------------------------------------------------

appuifw.app.title = old_title
tell("main thread all done")
thread_finish_logging()
finish_logging()
