#
# async_mgr_base.py
# 
# Copyright 2004 Helsinki Institute for Information Technology (HIIT)
# and the authors.  All rights reserved.
# 
# Authors: Tero Hasu <tero.hasu@hut.fi>
#
# A base class for socket managers that manage asynchronous sockets.
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

import thread
import time
from pdis.lib.logging import *
from aosocket.async_socket_exceptions import *
from aosocket.CondVar import *
from aosocket.settings import logging_enabled



class EvSubst:
    """
    A substitute for ``threading.Event``. Works the same way in very
    limited use cases. Either ``wait`` and ``set`` should not be
    called at all, or both should be called exactly once in any order.
    If ``set`` has not been called before ``wait`` is called, the call
    to ``wait`` will block.
    """
    def __init__(self):
        self.mutex = thread.allocate_lock()
        self.mutex.acquire()
    def wait(self):
        self.mutex.acquire()
    def set(self):
        self.mutex.release()



class AsyncMgrBase:
    """
    An abstract base class for socket managers that manage
    asynchronous sockets, more specifically sockets that implement the
    ``AsyncSocket`` interface.

    An instance of this class owns and manages sockets. It creates and
    deletes the sockets and makes any requests on them using an
    internal thread. No other thread will ever access the handles of
    the sockets owned by an instance of this class.

    The internal thread makes asynchronous requests on the sockets,
    allowing many requests on many sockets to be outstanding at any
    one time. It also handles any resulting socket events.

    The interface of this class is blocking; when a request is made,
    the callee has to wait until the internal thread receives a
    corresponding event.
    """

    # ----------------------------------------------------------------
    # request/event queue...

    def ext_queue_event(self, event):
        """
        This method may be used to deliver external events
        to this object.

        (Only called by external threads.)
        """
        event.insert(0, "ev")
        self.mutex.acquire()
        try:
            try:
                self.queue_add(event)
            except AsyncSocketMgrNotOpen:
                pass
        finally:
            self.mutex.release()

    def queue_add(self, item):
        """
        An item is either of the form
        ["req", handle, req_type, func, args, result, event] or
        ["ev", orig, ev_type, ev_stat, payload, cb_args].

        ``self.mutex`` must be held.

        (May be called by both external and internal threads.)
        """
        assert item[0] == "req" or item[0] == "ev"

        ## Whether we may still signal the internal thread.
        ## If not, no point in adding anything into the queue.
        if not self.may_signal:
            raise AsyncSocketMgrNotOpen

        ## Append the item.
        self.queue.append(item)

        ## Signal internal thread.
        tid = thread.get_ident()
        if tid != self.thread:
            #logwrite("signaling internal thread")
            # This fails with AsyncSocketMgrNotOpen if self.may_signal
            # changes value before we get to signal. But that's fine,
            # really, because we already added the item into the queue
            # earlier, and clearly the internal thread is active.
            try:
                self.awaken_internal_thread()
            except AsyncSocketMgrNotOpen:
                pass
        
    def awaken_internal_thread(self):
        """
        Either notifies the internal thread about something having
        happened, or throws an exception.
        
        ``self.mutex`` must be held.

        (Only called by external threads.)
        """
        while True:
            if not self.may_signal:
                raise AsyncSocketMgrNotOpen
            elif self.itc.is_active():
                #logwrite("calling complete on ITC")
                self.itc.complete()
                #logwrite("called complete on ITC")
                break
            else:
                #logwrite("waiting for chance to awaken internal thread")
                self.condition.wait(self.mutex)
                #logwrite("now may have that chance")
        
    # ----------------------------------------------------------------
    # initialization and cleanup...

    def __init__(self):
        """
        (Only called by an external thread.)
        """
        # This flag states whether the internal thread still
        # accepts notifications about changes in the queue.
        # (Requires mutex access.)
        self.may_signal = True

        # If this flag is set, any remaining pending requests will be
        # completed with "cancelled" status.
        # (Only accessed by the internal thread.)
        self.dying = False
        
        # This flag states whether all resources that require
        # cleaning up have been cleaned up. In particular,
        # this flag will not be set to true until the internal
        # thread has died.
        # (Set by the internal thread as the last thing it does.)
        self.dead = False

        # A list of sockets managed by this object,
        # keyed by their ``hash`` values, which are
        # also used as socket handles. Generally, we
        # will want to error complete requests about
        # sockets not in this map.
        # (Only accessed by the internal thread.)
        self.socket_map = {}

        # A queue for unprocessed requests, and possibly
        # events, too.
        # (Requires mutex access.)
        self.queue = []

        # A list of pending requests (i.e. requests that cannot
        # be completed without asynchronous socket events).
        # (Only accessed by the internal thread.)
        self.pending = []

        # This mutex controls access to internal property that
        # may be accessed by multiple threads, and requires
        # mutually exclusive access.
        self.mutex = thread.allocate_lock()

        # The condition under which signaling the internal
        # thread is allowed.
        self.condition = CondVar()
        
        # Creates the internal thread and any property it
        # requires. Also starts the thread.
        self.create_internal_thread()

    def close(self):
        """
        When this method is called, any callers blocking waiting for
        socket events will be released, and caused to throw a
        ``AsyncSocketMgrNotOpen`` exception. This call is synchronous,
        and will not return until all internal cleanup has been
        performed. Still, some waiters might end up throwing their
        exception only after this method returns, which is not
        a problem.

        (Only called by external threads.)
        """
        if self.dead:
            # Nothing to be done anymore.
            return

        try:
            if logging_enabled():
                logwrite("adding deathwish")
            self.wait_for_request(None, "die",
                                  self.mortally_wound_internal_thread, [])
            if logging_enabled():
                logwrite("deathwish acked")
        except AsyncSocketMgrNotOpen:
            # I guess someone else has already asked the manager
            # to stop accepting requests, which is fine.
            pass

        # This method may not return until cleanup is
        # complete, so do not.
        if logging_enabled():
            logwrite("waiting for internal death to die")
        while not self.dead:
            time.sleep(0.1)

    def mortally_wound_internal_thread(self, dummy, req):
        """
        This call causes the internal thread to wrap things up and
        die. The internal thread should take note of this, and start
        dying. It does not need to be dead yet by the time it signals
        the request. Indeed, it cannot itself signal anything after it
        already is dead.

        (Only called by the internal thread.)
        """
        if not self.dying:
            # After this flag has been set, the internal thread
            # can no longer be assumed to handle or successfully
            # complete socket-related requests, as it won't
            # be processing socket events.
            self.dying = True
        if logging_enabled():
            logwrite("completing wounding request")
        self.complete_request(req)
        if logging_enabled():
            logwrite("completed wounding request")

    # ----------------------------------------------------------------
    # abstract methods...

    def create_internal_thread(self):
        """
        This method creates and starts the internal thread that owns
        all the sockets, storing a reference to it in the internal
        ``thread`` property.

        (Only called by one external thread.)

        This method is for subclassers to implement.
        """
        raise NotImplementedError

    # ----------------------------------------------------------------
    # utilities for external thread(s)...

    def wait_for_request(self, handle, req_type, req_func, req_args):
        """
        Has the internal thread execute the function ``req_func`` with
        the arguments in list ``req_args``, and returns any result
        that ``req_func`` delivers back to this thread (by placing it
        into a known container). If the result indicates an error,
        ``wait_for_request`` throws the exception provided by
        ``req_func``.
        
        Note that we do not need to "send" requests to the internal
        thread. All we do need to do is to add them into the internal
        queue, and ensure that the internal thread notices. This
        operation may fail, and if it does, ``wait_for_request``
        throws an exception.

        The ``handle`` argument specifies that the request concerns
        the socket with the particular handle. If the value is
        ``None``, then the request concerns an uncreated socket,
        or the manager itself.

        The ``req_type`` value is a descriptive string that is used
        mostly for more informative logging, but may in some special
        cases also otherwise affect the way a request gets processed.
        """
        if logging_enabled():
            logwrite("making a " + req_type +
                     " request concerning " + str(handle))
            
        blocker = EvSubst()
        result = []
        req = ["req", handle, req_type,
               req_func, req_args,
               blocker, result]

        self.mutex.acquire()
        try:
            # This may fail with an exception, which is fine.
            self.queue_add(req)
        finally:
            self.mutex.release()

        # Wait for the request to complete.
        if logging_enabled():
            logwrite("wait_for_request--waiting")
        blocker.wait()
        if logging_enabled():
            logwrite("wait_for_request--released")

        # Return (or throw) the result.
        assert len(result) == 1
        error_status, data = result[0]
        if error_status:
            raise error_status
        return data

    # ----------------------------------------------------------------
    # utilities for the internal thread...

    def cancel_pending_requests(self, handle):
        """
        Cancels any pending requests concerning the specified socket.
        """
        for req in self.pending:
            if req[1] == handle:
                self.cancel_request(req, False)
                self.__mark_not_pending(req)

    def cancel_all_pending_requests(self):
        """
        Cancels any requests already being processed, but for which no
        completing event has not (and will not) be received. We keep
        record of such requests in the ``pending`` property for this
        purpose alone; otherwise all the required state could be
        maintained on the stack of the callee thread and the sockets
        associated with the requests.

        (Only called by the internal thread.)
        """
        for req in self.pending:
            self.cancel_request(req, True)
            # could clear the whole array at once, but
            # this also serves as an assertion of sorts
            self.__mark_not_pending(req)

    def close_all_managed_sockets(self):
        """
        Closes all the sockets being managed by this object.

        (Only called by the internal thread.)
        """
        if logging_enabled():
            logwrite("closing all managed sockets")
        for k, v in self.socket_map.iteritems():
            v.close()
        self.socket_map.clear()

    def __add_socket(self, socket):
        handle = hash(socket)
        assert not self.socket_map.has_key(handle)
        self.socket_map[handle] = socket
        return handle

    def __mark_pending(self, req):
        self.pending.append(req)

    def __mark_not_pending(self, req):
        self.pending.remove(req)

    def drain(self):
        """
        The caller must hold ``self.mutex`` as required for mutex
        access, as external threads also access ``self.queue``.
        
        Returns a list of all the unprocessed requests. The returned
        list may be empty.

        (Only called by the internal thread.)
        """
        if len(self.queue) == 0:
            return []
        reqs = self.queue
        self.queue = []
        return reqs

    def cancel_request(self, req, mgr_closed):
        """
        Signals the specified request as cancelled due to the socket
        manager having been closed, and thus having stopped processing
        requests.
        """
        if mgr_closed:
            self.complete_request(req, AsyncSocketMgrNotOpen())
        else:
            self.complete_request(req, AsyncSocketNotOpen())

    def complete_request(self, request, status = None, retval = None):
        """
        Signals the specified request as completed.
        The ``request`` parameter must be something that was
        acquired from the request queue.
        The ``status`` parameter must be either None,
        indicating that there was no problem, or some exception instance.
        The ``retval`` parameter is request specific, and will be
        returned to the callee as is.
        """
        request[6].append((status, retval))
        request[5].set()

    def process_request(self, req):
        """
        The ``req`` parameter specifies a request entry.
        It must be of the form
        ["req", handle, req_type, func, args, result, event]
        where

        * ``func`` is the function that processes the request

        * ``args`` is an array of arguments to pass to ``func``

        * ``result`` is empty array into which the result of the request
          will be stored in the form (status, retval), where

          * ``status`` is ``None``,
            or an exception in case of error completion

          * ``retval`` is a request specific result value
        
        * ``event`` is an ``Event`` object to signal when the request
          has been completed

        (Only called by the internal thread.)
        """
        func = req[3]
        args = req[4]
        try:
            if logging_enabled():
                logwrite("processing a " + req[2] +
                         " request concerning " + str(req[1]))
                logwrite("calling function " + str(func))
            func(self, req, *args)
            if logging_enabled():
                logwrite("called ok")
        except Exception, exc:
            if logging_enabled():
                logwrite("got exception")
                log_exception()
            self.complete_request(req, exc)
            if logging_enabled():
                logwrite("completed with error")

    # ----------------------------------------------------------------
    # the public API for managing individual sockets...

    def __check_state(self, req):
        """
        Returns true iff it is okay to proceed with processing the
        specified request. If not, this method cancels the request.
        """
        if self.dying:
            self.cancel_request(req, True)
            if req in self.pending:
                self.__mark_not_pending(req)
            return False
        handle = req[1]
        if handle and (not self.socket_map.has_key(handle)):
            self.cancel_request(req, False)
            if req in self.pending:
                self.__mark_not_pending(req)
            return False
        return True

    def create_socket(self, newsockfunc):
        """
        Creates a socket of the specified type, passing the specified
        arguments to its constructor. Returns a socket handle.
        """
        def createfunc(self, req, newsockfunc):
            if self.__check_state(req):
                #socket = clazz(**args) # where args is a hash
                socket = newsockfunc()
                handle = self.__add_socket(socket)
                self.complete_request(req, None, handle)
        return self.wait_for_request(
            None, "create", createfunc, [newsockfunc])

    def close_socket(self, handle):
        """
        Closes the specified socket. After this call, the socket
        handle will no longer be valid.
        """
        def closefunc(self, req, handle):
            if self.__check_state(req):
                socket = self.socket_map[handle]
                socket.close()
                del self.socket_map[handle]
                # As we are closing the socket, we will no longer
                # be getting events regarding the socket.
                # Therefore, we must release anyone waiting for
                # such events.
                self.cancel_pending_requests(handle)
                self.complete_request(req)
        return self.wait_for_request(
            handle, "close", closefunc, [handle])

    def listen_socket(self, handle, **kw):
        """
        See ``AsyncSocket.listen``.
        """
        def listenfunc(self, req, handle, kw):
            def cbfunc(orig, evtype, evstat, payload, cbparams):
                self, req = cbparams
                if self.__check_state(req):
                    self.__mark_not_pending(req)
                    assert evtype == "listen"
                    if not evstat:
                        self.complete_request(req)
                    else:
                        self.complete_request(req, evstat)
            if self.__check_state(req):
                socket = self.socket_map[handle]
                if logging_enabled():
                    logwrite("listenfunc--calling listen on " +
                             str(socket))
                socket.listen(cbfunc, (self, req), **kw)
                self.__mark_pending(req)
        return self.wait_for_request(
            handle, "listen", listenfunc, [handle, kw])

    def accept_socket(self, handle):
        """
        See ``AsyncSocket.accept``.
        """
        def acceptfunc(self, req, handle):
            def cbfunc(orig, evtype, evstat, cl_sock, cbparams):
                self, req = cbparams
                if self.__check_state(req):
                    self.__mark_not_pending(req)
                    assert evtype == "accept"
                    if not evstat:
                        cl_handle = self.__add_socket(cl_sock)
                        self.complete_request(req, None, cl_handle)
                    else:
                        self.complete_request(req, evstat)
            if self.__check_state(req):
                socket = self.socket_map[handle]
                socket.accept(cbfunc, (self, req))
                self.__mark_pending(req)
        return self.wait_for_request(
            handle, "accept", acceptfunc, [handle])

    def connect_socket(self, handle, **kw):
        """
        See ``AsyncSocket.connect``.
        """
        def connectfunc(self, req, handle, kw):
            def cbfunc(orig, evtype, evstat, payload, cbparams):
                self, req = cbparams
                if self.__check_state(req):
                    self.__mark_not_pending(req)
                    assert evtype == "connect"
                    if not evstat:
                        self.complete_request(req)
                    else:
                        self.complete_request(req, evstat)
            if self.__check_state(req):
                socket = self.socket_map[handle]
                socket.connect(cbfunc, (self, req), **kw)
                self.__mark_pending(req)
        return self.wait_for_request(
            handle, "connect", connectfunc, [handle, kw])

    def recv_socket(self, handle, size):
        """
        See ``AsyncSocket.recv``.
        """
        def recvfunc(self, req, handle, size):
            def cbfunc(orig, evtype, evstat, payload, cbparams):
                self, req = cbparams
                if self.__check_state(req):
                    self.__mark_not_pending(req)
                    assert evtype == "recv"
                    if not evstat:
                        self.complete_request(req, None, payload)
                    else:
                        self.complete_request(req, evstat)
            if self.__check_state(req):
                socket = self.socket_map[handle]
                socket.recv(size, cbfunc, (self, req))
                self.__mark_pending(req)
        return self.wait_for_request(
            handle, "recv", recvfunc, [handle, size])

    def sendall_socket(self, handle, data):
        """
        See ``AsyncSocket.sendall``.
        """
        def sendallfunc(self, req, handle, data):
            def cbfunc(orig, evtype, evstat, payload, cbparams):
                self, req = cbparams
                if self.__check_state(req):
                    self.__mark_not_pending(req)
                    assert evtype == "sendall"
                    if not evstat:
                        self.complete_request(req)
                    else:
                        self.complete_request(req, evstat)
            if self.__check_state(req):
                socket = self.socket_map[handle]
                socket.sendall(data, cbfunc, (self, req))
                self.__mark_pending(req)
        return self.wait_for_request(
            handle, "sendall", sendallfunc, [handle, data])
