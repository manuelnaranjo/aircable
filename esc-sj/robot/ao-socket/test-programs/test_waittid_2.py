#
# test_waittid_2.py
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
This code would seem to consistently hang under WINS,
in one of the safe_ao_waittid() calls, presumably.
Works on a phone.
"""



def safe_ao_waittid(tid):
    try:
        thread.ao_waittid(tid)
    except thread.error:
        # probably already dead when call made
        pass

def aoyield():
    tid = thread.start_new_thread(time.sleep, (0.1,))
    safe_ao_waittid(tid)

def tell(string):
    print string
    aoyield()


old_title = appuifw.app.title
appuifw.app.title = u"TestApp"

# --------------------------------------------------------------------


def worker_thread(number):
    time.sleep(2)

tell("creating threads")
wtids = []
for i in [0, 1, 2]:
    wtid = thread.start_new_thread(worker_thread, (i,))
    wtids.append(wtid)
    tell("created %d" % wtid)

tell("waiting for threads to die")
for wtid in wtids:
    tell("waiting for %d" % wtid)
    safe_ao_waittid(wtid)
tell("all workers dead")


# --------------------------------------------------------------------

appuifw.app.title = old_title
