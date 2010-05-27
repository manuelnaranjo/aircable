#
# test_waittid.py
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
from aosocket.symbian.symbian_itc import safe_ao_waittid


def tell(string):
    print string

old_title = appuifw.app.title
appuifw.app.title = u"TestApp"

# --------------------------------------------------------------------


def worker_thread(number):
    time.sleep(2)


tell("creating threads")
tids = []
for i in [0, 1, 2]:
    tid = thread.start_new_thread(worker_thread, (i,))
    tids.append(tid)
    tell("created %d" % tid)

tell("waiting for threads to die")
for tid in tids:
    tell("waiting for %d" % tid)
    safe_ao_waittid(tid)
tell("all workers dead")


# --------------------------------------------------------------------

appuifw.app.title = old_title
