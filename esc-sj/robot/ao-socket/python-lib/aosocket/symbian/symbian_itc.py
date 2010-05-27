#
# symbian_itc.py
# 
# Copyright 2004 Helsinki Institute for Information Technology (HIIT)
# and the authors.  All rights reserved.
# 
# Authors: Tero Hasu <tero.hasu@hut.fi>
#
# Utilities for interthread (and intertask) communication (and control).
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

import aosocketnativenew
import thread
import time



class ItcError(Exception):
    pass

class ReqAlreadyPendingItcError(ItcError):
    pass

class NoReqPendingItcError(ItcError):
    pass

class SessionClosedItcError(ItcError):
    pass

class SessionAlreadyOpenItcError(ItcError):
    pass





class SymbianItc:
    """
    This class is just a wrapper to ``AoItc``. Its purpose is to act
    as documentation, to keep track of whether the wrapped active
    object is active, and to throw reasonably informatively named
    exceptions in error conditions.

    Note that this object is not thread safe. When a request has
    been made, you may complete it either by calling ``cancel``
    (or ``close``) with the requesting thread, or ``complete``
    with some other thread, but you may not do both.
    """

    def __init__(self):
        self.itc = aosocketnativenew.AoItc()
        self.pending = False
        self.closed = True

    def open(self):
        if not self.closed:
            raise SessionAlreadyOpenItcError
        self.itc.open()
        self.closed = False

    def cancel(self):
        """
        This method may be called at any time, and it will not throw
        an exception. It will simply do nothing if there is no pending
        request.

        If, when calling ``cancel``, there is an active request,
        the callback for that request will not get called.
        """
        if self.pending:
            self.itc.cancel()
            self.pending = False

    def complete(self):
        """
        You may not call this method unless there is a pending
        request.

        This method does not take any parameters, and always signals
        completion as a successful one, i.e. with error value
        ``KErrNone``. Note that it is still possible to arrange to
        pass some result to the requester, by having the requester
        pass some sort of a result object as a parameter to
        ``request``, and then filling in that request object prior to
        calling ``complete``.
        """
        if self.closed:
            raise SessionClosedItcError
        if self.pending:
            self.itc.complete()
            self.pending = False
        else:
            raise NoReqPendingItcError

    def request(self, cb_func, cb_param):
        """
        You may not call this method twice in a row without calling
        either ``complete`` or ``cancel`` in between.
        """
        if self.closed:
            raise SessionClosedItcError
        if self.pending:
            raise ReqAlreadyPendingItcError
        else:
            self.itc.request(cb_func, cb_param)
            self.pending = True

    def is_active(self):
        return self.pending

    def close(self):
        """
        If, when calling ``close``, there is an active request,
        the callback for that request will not get called.
        """
        if not self.closed:
            self.itc.close()
            self.closed = True
            self.pending = False






def safe_ao_waittid(tid):
    try:
        thread.ao_waittid(tid)
    except thread.error:
        # probably already dead when call made
        pass


if aosocketnativenew.on_wins():
    def safe_ao_yield():
        def wait(mutex):
            time.sleep(0.1)
            mutex.release()
        mutex = thread.allocate_lock()
        mutex.acquire()
        thread.start_new_thread(wait, (mutex,))
        mutex.acquire()
else:
    def safe_ao_yield():
        tid = thread.start_new_thread(time.sleep, (0.1,))
        safe_ao_waittid(tid)

