#
# symbian_async_mgr.py
# 
# Copyright 2004 Helsinki Institute for Information Technology (HIIT)
# and the authors.  All rights reserved.
# 
# Authors: Tero Hasu <tero.hasu@hut.fi>
#
# An asynchronous socket manager implementation for Symbian.
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

import time
from pdis.lib.best_threading import start_thread
from pdis.lib.logging import *
from pdis.lib.priority import set_thread_priority
from aosocket.abst_async_mgr import AbstAsyncMgr
from aosocket.async_socket_exceptions import *
from aosocket.settings import logging_enabled
from aosocket.symbian.symbian_itc import SymbianItc
from aosocket.symbian.symbian_socket import SymbianSocketServ
from aosocketnativenew import AoImmediate, AoLoop




class SymbianAsyncMgr(AbstAsyncMgr):
    """
    This class implements a base class for socket managers that use
    sockets in an asynchronous manner in a Symbian environment.

    Each instance of this class has an internal thread that makes any
    asynchronous requests on the sockets managed by the instance,
    allowing many requests on many sockets to be outstanding at any
    one time. The thread is driven by its own native active scheduler,
    i.e. the thread does nothing but responds to events issued by the
    active scheduler.
    """

    def __init__(self, thread_pri = None):
        AbstAsyncMgr.__init__(self)
        if thread_pri:
            self.thread_pri = thread_pri
        else:
            # EPriorityAbsoluteHigh
            self.thread_pri = 500

    def create_internal_thread(self):
        """
        This method creates and starts the internal thread that owns
        all the sockets, storing a reference to it in the internal
        ``thread`` property.
        """
        # Create the Symbian-specific instance of this.
        self.itc = SymbianItc()

        # Now create and start the thread.
        # Do not forget to store the thread ID.
        if logging_enabled():
            logwrite("starting internal thread")
        self.thread = None
        self.thread = start_thread(
            target = self.__loop,
            name = "socket-owner-thread-%d" % hash(self),
            args = ())

    def __loop(self):
        """
        The thread that owns all the sockets runs this loop that
        processes all asynchronous events, as well as decides how to
        handle any requests in the internal queue. To get this thread
        to do something for you (instead of blocking and waiting for
        events), simply queue a new asynchronous request for the
        thread to deal with.
        """
        try:
            if logging_enabled():
                logwrite("internal thread running")
                logwrite("logging enabled")
            
            # We use this value internally, too, so ensure it's set
            # before we do.
            while not self.thread:
                time.sleep(0.1)

            set_thread_priority(self.thread_pri)
            
            self.aoloop = AoLoop()
            self.aoloop.open()
        
            # Note that it is imperative that we _create_ active objects
            # within this thread, as otherwise they will get registered
            # with the active scheduler of some other thread, resulting
            # in stray signals when requests are made. We should also
            # note that some other thread may try to access the ``itc``
            # object already before this thread gets to run, which is
            # why we created the object earlier, but are only now
            # registering it with the active scheduler.
            self.immediate = AoImmediate()
            self.immediate.open()
            self.itc.open()
        
            # We do not use this in this class, but we assume all
            # subclassers need an instance of this for initializing
            # RSocket instances.
            if logging_enabled():
                logwrite("creating socket server handle")
            self.socket_serv = SymbianSocketServ()
            
            # Run a new active scheduler loop until someone
            # calls ``close``.
            self.immediate.complete(self.__req_init, None)
            if logging_enabled():
                logwrite("starting ao loop")
            self.aoloop.start()
            if logging_enabled():
                logwrite("ao loop exited")

            # This will cancel any remaining requests.
            self.__process_any_requests()

            # Now release those waiting for requests that we already
            # started processing.
            self.cancel_all_pending_requests()
            
            # This will ensure that no new socket-related events
            # will be generated, but some might have been generated
            # already, causing callbacks after all the cleanup
            # has already been done. We must make sure not to do
            # anything in such callbacks.
            self.close_all_managed_sockets()

            # Note that those objects that might have thread-specific
            # sessions must be cleaned up by this thread, rather
            # than left for GC to handle. We are doing the cleanup here.
            self.socket_serv.close()
            self.aoloop.close()
            self.immediate.close()
            self.itc.close()
            if logging_enabled():
                logwrite("stopping logging for internal thread")
            thread_finish_logging()

            # This thread should die any moment after this.
            self.dead = True
        except:
            # Does nothing if logging has been stopped already.
            log_exception()

    def __req_init(self, error, dummy_param):
        """
        Starts accepting requests. No requests, not even a ``close``
        request can be delivered to the internal thread before this
        has been done.
        """
        try:
            #logwrite("enter __req_init")
            self.mutex.acquire()
            try:
                self.itc.request(self.__got_request, None)
                self.condition.signal()
            finally:
                self.mutex.release()
            #logwrite("exit __req_init")
        except:
            log_exception()

    def __process_any_requests(self):
        ## Get any requests.
        #logwrite("check for new requests")
        self.mutex.acquire()
        try:
            reqs = self.drain()
        finally:
            self.mutex.release()

        ## Prosess any requests we got.
        #logwrite("process any new requests")
        for req in reqs:
            #logwrite("processing request")
            self.process_request(req)

    def __got_request(self, error, dummy_param):
        try:
            #logwrite("enter __got_request")
            
            ## In our case, nobody ever calls ``cancel`` on ``self.itc``,
            ## so the only possible ``error`` value should be 0.
            assert error == 0

            ## Process all the requests in the queue.
            self.__process_any_requests()

            ## Let more requests arrive, unless one of the requests
            ## triggered a shutdown.
            #logwrite("maybe let new requests come")
            self.mutex.acquire()
            try:
                if self.dying:
                    #logwrite("no, no more requests")
                    self.may_signal = False
                    self.condition.signal_all()
                    self.aoloop.stop()
                else:
                    #logwrite("yes, new requests may come")
                    self.itc.request(self.__got_request, None)
                    self.condition.signal()
            finally:
                self.mutex.release()
                
            #logwrite("exit __got_request")
        except:
            log_exception()
