#
# test_mt_log.py
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


"""
Tests the use of the MtFileLogger API with multiple threads.
Note that it is imperative that ``close`` be called by each
thread before exiting the VM.
"""




try:
    from pdis.lib.logging import *
    from aosocket.MtFileLogger import *
    init_logging(MtFileLogger("aosocket", "testapp"))
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

old_title = appuifw.app.title
appuifw.app.title = u"TestApp"

# --------------------------------------------------------------------

from aosocketnativenew import AoLoop, AoImmediate



def wk_thread_func():
    try:
        tell("(worker thread)")
        loop = AoLoop()
        loop.open()
        loop.close()
        tell("all done")
        mn_lock.release()
        thread_finish_logging()
    except:
        log_exception()




tell("(main thread)")

mn_lock = thread.allocate_lock()
mn_lock.acquire()

tell("starting worker")
wk_thread = thread.start_new_thread(wk_thread_func, ())
tell("started worker thread")

tell("waiting for worker")
mn_lock.acquire()
time.sleep(2)
tell("worker dead")
tell("all done")

# --------------------------------------------------------------------

appuifw.app.title = old_title
thread_finish_logging()
finish_logging()
