#
# test_resolver_4.py
# 
# Copyright 2005 Helsinki Institute for Information Technology (HIIT)
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
import aosocketnativenew

from pdis.lib.logging import *
init_logging(FileLogger("c:\\logs\\aosocket\\testresolver.txt"))

def tell(string):
    logwrite(string)
    if e32.is_ui_thread():
        print string
        e32.ao_yield()

# --------------------------------------------------------------------

from aosocket.symbian.bt_device_discoverer import *
from socket import bt_discover

def discovered(error, devices, cb_param):
    if error == 0:
        tell("devices: " + str(devices))
        try:
            for address, name in devices:
                services = bt_discover(address)
                tell("services: " + str(services))
        except:
            tell("service discovery failure")
            log_exception()
    else:
        tell("device discovery failure: error %d" % error)
    _discoverer.close()
    
try:
    _discoverer = BtDeviceLister()
    _discoverer.discover_all(discovered, None)
    tell("discovering")
except:
    tell("init failure")
    log_exception()
    appuifw.note(u"Fatal error.", "error")
