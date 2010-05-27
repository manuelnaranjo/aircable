#
# test_ao_loop.py
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
from aosocket.symbian.symbian_itc import safe_ao_waittid

from pdis.lib.logging import *
init_logging(FileLogger("c:\\logs\\aosocket\\testapp.txt"))

# start dummy thread
import thread
thread_lck = thread.allocate_lock()
thread_lck.acquire()
def dummy_thread(thread_lck):
    thread_lck.acquire()
    thread_lck.release()
dummy_tid = thread.start_new_thread(dummy_thread, (thread_lck,))

# setup Exit key handler
old_title =appuifw.app.title
appuifw.app.title = u"TestApp"
script_lock = e32.Ao_lock()
def exit_handler():
    script_lock.signal()
appuifw.app.exit_key_handler = exit_handler

try:
    from aosocketnativenew import AoLoop, AoItc
    import time

    def signal(error, param):
        param.stop()

    def signaler_thread(param):
        time.sleep(5)
        param.complete()

    loop = AoLoop()
    itc = AoItc()
    # Make a request before calling "start" on the loop, or
    # the loop will never get any events, and will thus hang.
    itc.request(signal, loop)

    sign_tid = None
    try:
        sign_tid = thread.start_new_thread(signaler_thread, (itc,))
        print "signaler thread started"
    except:
        print "could not start signaler thread"
        itc.cancel()

    if sign_tid:
        print "starting loop"
        loop.start()
        print "loop stopped"
        safe_ao_waittid(sign_tid)

    script_lock.wait()
except:
    log_exception()
    appuifw.note(u"Fatal error.", "error")

# stop dummy thread
thread_lck.release()
safe_ao_waittid(dummy_tid)

appuifw.app.title = old_title
appuifw.app.set_exit()
