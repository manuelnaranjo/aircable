#
# test_ao_loop_3.py
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
This works for as long as the ``logwrite`` call stays commented out.
So it looks like we can now use ``AoLoop`` and ``AoImmediate`` in
a thread other than the main thread, without a cleanup crash.

If we can also get ``AoItc``, ``AoSocket``, and ``AoSocketServ`` to
work equally well, our cleanup crash problem might well be a thing
in the past.

Should at some point examine whether there is something that can
be done about logging, but actually, if we get sockets working
reliably, we could even start logging over the network. Or we could
implement our own native file access routines, just enough for
logging, which should be a small task. There is also the ``flogger``
API, which we have used in the past, but were not quite happy with,
but that may have been just because we used it the wrong way;
look into it, and make sure to provide a cleanup call that can
be used to release any log file handle from the ``finish_logging``
call.
"""


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
    #logwrite(string)
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

from aosocketnativenew import AoLoop, AoImmediate



def completed(error, loop):
    loop.stop()

def wk_thread_func():
    try:
        tell("(worker thread)")
        loop = AoLoop()
        loop.open()
        imm = AoImmediate()
        imm.open()
        imm.complete(completed, loop)
        loop.start()
        imm.close()
        loop.close()
        tell("all done")
    except:
        log_exception()




tell("(main thread)")

tell("starting worker")
wk_thread = thread.start_new_thread(wk_thread_func, ())
tell("started worker thread")

tell("waiting for worker to die")
# hopefully robust enough for such a simple case
safe_ao_waittid(wk_thread)
tell("worker dead")

# --------------------------------------------------------------------

appuifw.app.title = old_title
finish_logging()
