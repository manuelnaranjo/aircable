#
# symbian_socket.py
# 
# Copyright 2004 Helsinki Institute for Information Technology (HIIT)
# and the authors.  All rights reserved.
# 
# Authors: Tero Hasu <tero.hasu@hut.fi>
#
# A socket API that closely resembles the native Symbian socket API.
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
from aosocket.async_socket_exceptions import *
from aosocket.symbian.bt_utils import check_mac
from pdis.lib import logging




class SymbianSocketServ:
    """
    A handle to a Symbian socket server session.
    """

    def __init__(self):
        """
        Creates a new socket server session handle. Do not forget to
        call ``close`` to close the session when it is no longer
        required.
        """
        self.native = aosocketnativenew.AoSocketServ()
        self.native.connect()

    def close(self):
        """
        Closes the socket server session. Keep in mind that when you
        close a session, all resources associated with that session
        will be freed. In practice, this means that all sockets opened
        via that session will get closed.
        """
        self.native.close()




class SymbianSocket:
    """
    An abstract, transport-independent socket for Symbian that
    provides a subset of the operations offered by the native
    Symbian ``RSocket`` API.
    """

    def __init__(self):
        """
        Creates an unconnected socket. This is not the same as a
        "blank" socket, not in our terminology anyway. To turn the
        socket into a "blank" socket, a client socket, or a server
        socket, you must make an additional method call.
        """
        # This flag indicates whether has allocated resources
        # that must be cleanup up.
        self.inited = False

        # This flag keeps track of whether the socket is connected.
        self.connected = False

        # These are used to keep track of whether there are
        # outstanding requests of different types.
        # We are assuming all sockets have at least these,
        # regardless of transport.
        # ``accepting`` and ``connecting`` should probably
        # be mutually exclusive, and this can be enforced
        # as desired.
        self.reading = False
        self.writing = False
        self.accepting = False
        self.connecting = False

    def close(self):
        """
        A synchronous method that throws no exceptions.

        Closes the socket. There is no harm in calling ``close`` on a
        socket that has already been closed. Any outstanding requests
        on the socket will be cancelled, and no events regarding them
        will be delivered after a socket has been closed.
        """
        if not self.inited:
            return
        # This is mainly to reset state, as ``close`` should
        # otherwise cancel any requests.
        self.cancel_all()
        try:
            self.native.close()
        except:
            pass
        self.connected = False
        self.inited = False

    def blank(self, socket_serv):
        """
        A synchronous method that may throw an exception.

        Turns the closed socket into a blank socket, which is the type
        of socket that the ``accept`` method requires as a parameter.

        The ``socket_serv`` parameter must be a handle to an open
        socket session. The blank socket will then belong to that
        session.

        This method returns the object instance being operated upon.
        """
        if self.inited:
            raise AsyncSocketAlreadyOpen
        self.native = aosocketnativenew.AoSocket()
        self.inited = True
        try:
            self.native.set_socket_serv(socket_serv.native)
            self.native.blank()
        except:
            self.close()
            raise
        return self

    def recv(self, max_size, cb_func, cb_param):
        """
        An asynchronous method that may throw an exception.
        
        Reads some data from the socket; at least one byte, but no
        more than the specified amount.

        Once the request completes, an event will be delivered to the
        thread that made the request. The event will be delivered by
        calling ``cb_func`` with the following parameters:

        * a Symbian-specific error code (0 for no error or an EOF)

        * the data read (if there was no error), or an empty string if
          an EOF was received, or unspecified if there was an error

        * ``cb_param``

        An exception in the callback will be handled by the
        ``handle_callback_error`` method.
        """
        if not self.connected:
            raise AsyncSocketNotOpen
        if self.reading:
            raise AsyncSocketRequestPending
        params = (cb_func, cb_param)
        self.native.read_some(max_size, self.read_cb, params)
        self.reading = True

    def sendall(self, data, cb_func, cb_param):
        """
        An asynchronous method that may throw an exception.

        Writes all of the given data to the socket.

        Once the request completes, an event will be delivered to the
        thread that made the request. The event will be delivered by
        calling ``cb_func`` with the following parameters:

        * a Symbian-specific error code

        * ``cb_param``

        An exception in the callback will be handled by the
        ``handle_callback_error`` method.
        """
        if not self.connected:
            raise AsyncSocketNotOpen
        if self.writing:
            raise AsyncSocketRequestPending
        params = (cb_func, cb_param)
        self.native.write_data(data, self.write_cb, params)
        self.writing = True

    def read_cb(self, error, data, cb_param):
        """
        Registered as a callback with the native socket for read
        events. The ``data`` parameter is the data that was read from
        the socket, assuming the request completed successfully.
        """
        try:
            self.reading = False
            f, p = cb_param
            if error == -25: # KErrEof
                f(0, "", p)
            else:
                f(error, data, p)
        except:
            self.handle_callback_error()

    def write_cb(self, error, cb_param):
        """
        Registered as a callback with the native socket for write
        events.
        """
        try:
            self.writing = False
            f, p = cb_param
            f(error, p)
        except:
            self.handle_callback_error()

    def accept_cb(self, error, socket, cb_param):
        """
        Registered as a callback with the native socket for accept
        events. The ``socket`` parameter specifies the same socket as
        the one passed to the native socket's ``accept`` method,
        assuming the request completed successfully.
        """
        try:
            self.accepting = False
            passed_sock, f, p = cb_param
            if error == 0:
                passed_sock.connected = True
            f(error, passed_sock, p)
        except:
            self.handle_callback_error()

    def connect_cb(self, error, cb_param):
        """
        Registered as a callback with the native socket for connect
        events.
        """
        try:
            self.connecting = False
            if error == 0:
                self.connected = True
            f, p = cb_param
            f(error, p)
        except:
            self.handle_callback_error()

    def cancel_read(self):
        """
        A synchronous method that throws no exceptions.

        Cancels any outstanding asynchronous read request.

        Note that cancelled requests will not result in an event.
        """
        if self.reading:
            self.reading = False
            # This call does not fail.
            self.native.cancel_read()

    def cancel_write(self):
        """
        A synchronous method that throws no exceptions.

        Cancels any outstanding asynchronous write request.

        Note that cancelled requests will not result in an event.
        """
        if self.writing:
            self.writing = False
            # This call does not fail.
            self.native.cancel_write()
    
    def cancel_accept(self):
        """
        A synchronous method that throws no exceptions.

        Cancels any outstanding asynchronous accept request.

        Note that cancelled requests will not result in an event.
        """
        if self.accepting:
            self.accepting = False
            # This call does not fail.
            self.native.cancel_accept()

    def cancel_connect(self):
        """
        A synchronous method that throws no exceptions.

        Cancels any outstanding asynchronous connect request.

        Note that cancelled requests will not result in an event.
        """
        if self.connecting:
            self.connecting = False
            # This call does not fail.
            self.native.cancel_connect()

    def cancel_all(self):
        """
        A synchronous method that throws no exceptions.

        Cancels any outstanding asynchronous requests, regardless of
        their type.

        Note that cancelled requests will not result in an event.
        """
        self.cancel_read()
        self.cancel_write()
        self.cancel_accept()
        self.cancel_connect()

    def handle_callback_error(self):
        """
        Called when an error occurs in a callback function. The
        default behavior is to log the error and close the socket.
        """
        logging.log_exception("Exception in socket callback.")
        self.close()


    def accept(self, blank_socket, cb_func, cb_param):
        """
        An asynchronous method that may throw an exception.

        Accepts a connection on this socket, and initializes the
        passed ``blank_socket`` as the local end point for that
        connection. ``blank_socket`` must be of the same type
        as the receiver.

        Once the request completes, an event will be delivered to the
        thread that made the request. The event will be delivered by
        calling ``cb_func`` with the following parameters:

        * a Symbian-specific error code (0 for no error)

        * ``blank_socket`` unless there was an error, in which case
          unspecified

        * ``cb_param``

        An exception in the callback will be handled by the
        ``handle_callback_error`` method.
        """
        if not self.connected:
            raise AsyncSocketNotOpen
        if self.accepting:
            raise AsyncSocketRequestPending
        params = (blank_socket, cb_func, cb_param)
        blank_native = blank_socket.native
        self.native.accept_client(blank_native, self.accept_cb, params)
        self.accepting = True








class TcpSymbianSocket(SymbianSocket):

    def connect(self, socket_serv, address, cb_func, cb_param):
        """
        An asynchronous method that may throw an exception.

        Connects the still closed socket into a server at ``address``.

        The ``socket_serv`` parameter must be a handle to an open
        socket server session. The connected socket will then belong
        to that session.

        Once the request completes, an event will be delivered to the
        thread that made the request. The event will be delivered by
        calling ``cb_func`` with the following parameters:

        * a Symbian-specific error code

        * ``cb_param``

        An exception in the callback will be handled by the
        ``handle_callback_error`` method.
        """
        if self.connected:
            raise AsyncSocketAlreadyOpen
        if self.connecting:
            raise AsyncSocketRequestPending
        if self.inited:
            self.close()
        self.native = aosocketnativenew.AoSocket()
        self.inited = True
        try:
            self.native.set_socket_serv(socket_serv.native)
            self.native.open_tcp()
            self.native.connect_tcp(unicode(address[0]), address[1],
                                    self.connect_cb, (cb_func, cb_param))
            self.connecting = True
        except:
            self.close()
            raise

    def listen(self, socket_serv, address, queue_size):
        """
        A synchronous method that may throw an exception.

        Opens the still closed socket, has it bound to the specified
        ``address``, and has it start listening to connections at that
        address. The maximum number of connections are allowed in the
        accept queue is set to ``queue_size``.

        The ``socket_serv`` parameter must be a handle to an open
        socket session. The listening socket will then belong to that
        session.
        """
        if self.inited:
            raise AsyncSocketAlreadyOpen
        self.native = aosocketnativenew.AoSocket()
        self.inited = True
        try:
            self.native.set_socket_serv(socket_serv.native)
            self.native.open_tcp()
            self.native.listen_tcp(unicode(address[0]),
                                   address[1], queue_size)
            self.connected = True
        except:
            self.close()
            raise





class BtSymbianSocket(SymbianSocket):

    def __init__(self):
        SymbianSocket.__init__(self)
        self.configuring = False

    def connect(self, socket_serv, address, cb_func, cb_param):
        """
        This method has the same semantics as the ``connect``
        method of ``TcpSymbianSocket``.

        In the BT case, ``address`` must be of the form
        ("hh:hh:hh:hh:hh:hh", port).
        """
        address, port = address
        check_mac(address)
        if self.connected:
            raise AsyncSocketAlreadyOpen
        if self.connecting:
            raise AsyncSocketRequestPending
        if self.inited:
            self.close()
        self.native = aosocketnativenew.AoSocket()
        self.inited = True
        try:
            self.native.set_socket_serv(socket_serv.native)
            self.native.open_bt()
            self.native.connect_bt(unicode(address), port,
                                   self.connect_cb, (cb_func, cb_param))
            self.connecting = True
        except:
            self.close()
            raise

    def get_available_port(self):
        return self.native.get_available_bt_port()

    def listen(self, socket_serv, address, queue_size,
               service_id, service_name):
        """
        This method has the same semantics as the ``listen``
        method of ``TcpSymbianSocket``.

        Note that no listening address needs to be specified
        in the BT case, as it is determined automatically.
        """
        if self.inited:
            raise AsyncSocketAlreadyOpen
        self.native = aosocketnativenew.AoSocket()
        self.inited = True

        try:
            port = address[1]
        except IndexError:
            port = None

        try:
            self.native.set_socket_serv(socket_serv.native)
            self.native.open_bt()
            if not port:
                port = self.get_available_port()
            self.native.listen_bt(port, queue_size, service_id, service_name)
            self.connected = True
        except:
            self.close()
            raise

    def configure(self, cb_func, cb_param):
        """
        An asynchronous method that may throw an exception.

        Adds an SDP record for the service, and depending on
        the implementation, might do other things such as seting
        the security requirements for any accepted connections.
        Both of these settings will persist until ``close`` is called.

        Once the request completes, an event will be delivered to the
        thread that made the request. The event will be delivered by
        calling ``cb_func`` with the following parameters:

        * a Symbian-specific error code

        * ``cb_param``

        An exception in the callback will be handled by the
        ``handle_callback_error`` method.
        """
        if not self.connected:
            raise AsyncSocketNotOpen
        if self.configuring:
            raise AsyncSocketRequestPending
        params = (cb_func, cb_param)
        self.native.config_bt(self.__configure_cb, params)
        self.configuring = True

    def __configure_cb(self, error, cb_param):
        """
        Registered as a callback with the native socket for configure
        events.
        """
        try:
            self.configuring = False
            f, p = cb_param
            f(error, p)
        except:
            self.handle_callback_error()

