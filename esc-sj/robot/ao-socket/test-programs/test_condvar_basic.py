#
# test_condvar_basic.py
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

try:
    import e32
    import appuifw
    on_symbian = True
except:
    on_symbian = False

import time
import thread


def tell(string):
    print string


if on_symbian:
    # setup Exit key handler
    old_title = appuifw.app.title
    appuifw.app.title = u"TestApp"

# --------------------------------------------------------------------


class CondVar:
    """
    Sort of a basic substitute for ``threading.Condition``. The API is
    different, though.
    """

    def __init__(self):
        self.waiters = []

    def wait(self, mutex):
        """
        Blocks the calling thread until signaled.
        
        Passed ``mutex`` must already be held.
        """
        semap = thread.allocate_lock()
        semap.acquire() # initialize to 0
        self.waiters.append(semap)
        mutex.release()
        semap.acquire() # wait on semaphore
        mutex.acquire()

    def signal(self):
        """
        Wakes up one waiter, if any.
        
        The ``mutex`` already be held (see ``wait``).
        """
        if len(self.waiters) > 0:
            semap = self.waiters.pop(0)
            semap.release()

    def signal_all(self):
        """
        Wakes up all waiters.
        
        The ``mutex`` already be held (see ``wait``).
        """
        if len(self.waiters) > 0:
            for semap in self.waiters:
                semap.release()
            self.waiters = []



condmutex = thread.allocate_lock()
condvar = CondVar()
mainmutex = thread.allocate_lock()
mainmutex.acquire()

def worker_thread():
    condmutex.acquire()
    try:
        condvar.wait(condmutex)
    finally:
        condmutex.release()
    mainmutex.release()

wtid = thread.start_new_thread(worker_thread, ())
time.sleep(2)
condmutex.acquire()
try:
    condvar.signal()
finally:
    condmutex.release()

mainmutex.acquire()
tell("looks like worker has been released")


# --------------------------------------------------------------------

if on_symbian:
    appuifw.app.title = old_title
