#
# test_ao_lock_2.py
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
This test program calls wait() on an e32.Ao_lock()
in a thread other than the one that created it.
Just to experiment to see whether this is okay.
"""


import e32
import appuifw
import time
import thread

try:
    from pdis.lib.logging import *
    from aosocket.MtFileLogger import *
    init_logging(MtFileLogger("c:\\logs\\aosocket\\testapp"))
except:
    def logwrite(string):
        pass
    def log_exception():
        pass
    def finish_logging():
        pass

def tell(string):
    logwrite(string)
    if e32.is_ui_thread():
        print string
        e32.ao_yield()

def safe_ao_waittid(tid):
    try:
        thread.ao_waittid(tid)
    except thread.error:
        # probably already dead when call made
        pass

# setup Exit key handler
old_title = appuifw.app.title
appuifw.app.title = u"TestApp"

# --------------------------------------------------------------------


def wk_thread_func():
    try:
        tell("(worker thread)")
        tell("creating lock to wait on")

        tell("signalling that lock is ready")
        mn_lock.release()
        tell("waiting on the lock")
        wk_lock.wait()
        tell("worker now all done, so releasing main thread")
        mn_lock.release()
    except:
        log_exception()




tell("(main thread)")

mn_lock = thread.allocate_lock()
mn_lock.acquire()

# creating lock here in a thread other than the one
# that is going to do a wait() on it
wk_lock = e32.Ao_lock()
        
tell("starting worker")
wk_thread = thread.start_new_thread(wk_thread_func, ())
tell("started worker thread")

tell("waiting for worker to create lock")
mn_lock.acquire()
tell("lock ready")

tell("waiting a while")
time.sleep(2)
tell("waking up worker")
wk_lock.signal()
tell("signal sent")

tell("waiting for worker to finish")
# not using ao_waittid, as not reliable on WINS
mn_lock.acquire()
# waiting a bit to hopefully ensure that worker has time to die
time.sleep(3)
tell("all done")

# --------------------------------------------------------------------

appuifw.app.title = old_title
finish_logging()
