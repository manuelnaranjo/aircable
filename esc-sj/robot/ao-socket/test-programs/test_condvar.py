#
# test_condvar.py
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
Note that this code will probably hang on WINS, so run on a phone only.
"""



import e32
import appuifw
import time
import thread
from aosocket.symbian.symbian_itc import safe_ao_waittid
from aosocket.CondVar import CondVar


from pdis.lib.logging import *
init_logging(FileLogger("c:\\logs\\aosocket\\testapp.txt"))

def aoyield():
    tid = thread.start_new_thread(time.sleep, (0.1,))
    safe_ao_waittid(tid)

def tell(string):
    logwrite(string)
    print string
    aoyield()

# setup Exit key handler
old_title = appuifw.app.title
appuifw.app.title = u"TestApp"

# --------------------------------------------------------------------



condmutex = thread.allocate_lock()
condvar = CondVar()

def worker_thread():
    condmutex.acquire()
    try:
        condvar.wait(condmutex)
    finally:
        condmutex.release()

try:
    tell("creating one thread")
    workertid = thread.start_new_thread(worker_thread, ())
    time.sleep(2)
    condmutex.acquire()
    try:
        condvar.signal()
    finally:
        condmutex.release()
    tell("waiting for it to die")
    safe_ao_waittid(workertid)
    tell("worker dead")

    
    
    tell("creating many threads")
    workertids = []
    for i in [0, 1, 2]:
        workertid = thread.start_new_thread(worker_thread, ())
        workertids.append(workertid)
        tell("created %d" % workertid)

    for dummy in workertids:
        time.sleep(2)
        tell("signaling one thread")
        condmutex.acquire()
        try:
            condvar.signal()
        finally:
            condmutex.release()
        tell("signaling done")

    tell("waiting for threads to die")
    for workertid in workertids:
        tell("waiting for %d" % workertid)
        safe_ao_waittid(workertid)
    tell("all workers dead")




    tell("creating many threads")
    workertids = []
    for i in [0, 1, 2]:
        workertid = thread.start_new_thread(worker_thread, ())
        workertids.append(workertid)
        tell("created %d" % workertid)

    time.sleep(2)
    tell("signaling all threads at once")
    condmutex.acquire()
    try:
        condvar.signal_all()
    finally:
        condmutex.release()
    tell("signaling done")
    
    tell("waiting for threads to die")
    for workertid in workertids:
        tell("waiting for %d" % workertid)
        safe_ao_waittid(workertid)
    tell("all workers dead")




    tell("all done")
except:
    log_exception()
    appuifw.note(u"Fatal error.", "error")



# --------------------------------------------------------------------

appuifw.app.title = old_title
finish_logging()
