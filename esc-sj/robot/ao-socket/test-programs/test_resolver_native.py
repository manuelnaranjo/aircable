#
# test_resolver_native.py
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

"""
Do note that this test case accesses the native API directly, and the
API is not particularly user friendly in that, for instance, the
Bluetooth addresses are not returned using the "standard" coloned
notation--rather, they are expressed as returned by the Symbian
TBTDevAddr::GetReadable function. You may want to look at the other
test_resolver_*.py examples instead.
"""

import e32
import appuifw
import time
import thread
import aosocketnativenew
from pdis.lib.best_threading import start_thread

from pdis.lib.logging import *
init_logging(FileLogger("c:\\logs\\aosocket\\testresolver.txt"))
from aosocket.settings import enable_logging
enable_logging()

def tell(string):
    logwrite(string)
    if e32.is_ui_thread():
        print string
        e32.ao_yield()

# --------------------------------------------------------------------

from aosocketnativenew import AoLoop, AoResolver

def cl_thread_func(list):

    def discovered(error, address, name, list):
        try:
            if not error:
                list.append((address, name))
                resolver.next()
            else:
                # KErrEof -25 is what we get when no more devices
                logwrite("error %d" % error)
                cl_loop.stop()
        except:
            log_exception()
        
    try:
        tell("(client thread)")

        resolver = AoResolver()
        resolver.open()
        resolver.discover(discovered, list)

        cl_loop = AoLoop()
        cl_loop.open()
        cl_loop.start()

        cl_loop.close()
        resolver.close()
        
        tell("client now all done")
    except:
        log_exception()

def get_device_list():
    list = []
    tid = start_thread(
        target = cl_thread_func,
        name = "worker-thread",
        args = (list,))
    thread.ao_waittid(tid)
    return list
    
try:
    print str(get_device_list())
except:
    log_exception()
    appuifw.note(u"Fatal error.", "error")
