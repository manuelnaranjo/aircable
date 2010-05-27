#
# bt_device_discoverer.py
# 
# Copyright 2004 Helsinki Institute for Information Technology (HIIT)
# and the authors.  All rights reserved.
# 
# Authors: Tero Hasu <tero.hasu@hut.fi>
#
# A module for non-interactive Bluetooth device discovery.
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

from aosocket.symbian.bt_utils import add_colons
import aosocketnativenew
from pdis.lib.logging import log_exception

# --------------------------------------------------------------------
# exceptions...

class BtDeviceDiscovererNoLongerOpen(Exception):
    pass

class BtDeviceDiscovererNextBeforeFirst(Exception):
    pass

class BtDeviceDiscovererRequestPending(Exception):
    pass

class BtDeviceDiscovererReadPastEof(Exception):
    pass

# --------------------------------------------------------------------
# low-level API...

class BtDeviceDiscoverer:
    """
    Wraps the native ``aosocketnativenew.AoResolver`` API with a thin
    layer that adds some extra error checking, and functions as API
    documentation for sorts. The native API is not so clearly visible
    from the C++ source.

    If you don't like the overhead introduced by this API, just don't
    import this module, and use the native API directly instead.
    """

    def __init__(self):
        self.resolver = aosocketnativenew.AoResolver()
        self.resolver.open()
        self.closed = False
        self.pending = False
        self.firstdone = False
        self.nomore = False

    def close(self):
        """
        If you successfully construct an object, this method
        must be called to clean up any allocated resources.
        No harm in calling this method more than once.
        """
        if not self.closed:
            self.resolver.close()
            self.closed = True

    def cancel(self):
        """
        Cancels any outstanding ``first`` or ``next`` request.
        No harm in calling if there is no outstanding request.
        """
        self.resolver.cancel()
        self.pending = False

    def first(self, cb_func, cb_param):
        """
        Makes a request for the address and name of the first
        discoverable device in range. The callback function
        will be called with parameters (error, address, name, cb_param),
        where ``error`` is non-zero iff there was an error,
        and ``address`` and ``name`` are ``None`` if there are no (more)
        devices to be found. Calls to ``next`` can be made
        to find subsequent devices.
        """
        if self.closed:
            raise BtDeviceDiscovererNoLongerOpen
        if self.pending:
            raise BtDeviceDiscovererRequestPending
        self.resolver.discover(self.__callback, (cb_func, cb_param))
        self.firstdone = True
        self.nomore = False
        self.pending = True

    def next(self):
        """
        Makes a request for the next name and address. You may not
        call this method without calling ``first`` first.
        """
        if self.closed:
            raise BtDeviceDiscovererNoLongerOpen
        if self.pending:
            raise BtDeviceDiscovererRequestPending
        if not self.firstdone:
            raise BtDeviceDiscovererNextBeforeFirst
        if self.nomore:
            raise BtDeviceDiscovererReadPastEof
        self.resolver.next()
        self.pending = True

    def __callback(self, error, addr, name, param):
        self.pending = False
        f, p = param
        try:
            if error == 0:
                f(0, add_colons(addr), name, p)
            else:
                if error == -25: # KErrEof (no more devices)
                    error = 0
                self.nomore = True
                f(error, None, None, p)
        except:
            self.handle_error()

    def handle_error(self):
        """
        We do not like exceptions in callbacks, but subclassers may
        override the default behavior to do something less drastic.
        """
        log_exception()
        # This also cancels any request that may have been made
        # in the callback before the exception was thrown.
        self.close()

# --------------------------------------------------------------------
# high-level API...

class BtDeviceLister:
    """
    An instance of this class is capable of discovering all devices in
    the piconet with a single request.
    """

    def __init__(self):
        self.engine = BtDeviceDiscoverer()

    def discover_all(self, cb_func, cb_param):
        """
        Results in a callback of the form (error, device_list, cb_param).
        """
        self.cancel()
        self.list = []
        self.engine.first(self.__callback, (cb_func, cb_param))

    def cancel(self):
        self.engine.cancel()

    def close(self):
        self.engine.close()

    def __callback(self, error, addr, name, param):
        cb_func, cb_param = param
        if error != 0:
            cb_func(error, self.list, cb_param)
        elif not addr:
            cb_func(0, self.list, cb_param)
        else:
            self.list.append((addr, name))
            self.engine.next()
