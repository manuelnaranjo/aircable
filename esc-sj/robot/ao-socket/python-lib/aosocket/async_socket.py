#
# async_socket.py
# 
# Copyright 2004 Helsinki Institute for Information Technology (HIIT)
# and the authors.  All rights reserved.
# 
# Authors: Tero Hasu <tero.hasu@hut.fi>
#
# Defines an interface for asynchronous sockets. This library
# contains an implementation of this interface for Symbian sockets.
# At one time, we also had an up-to-date ``asyncore`` implementation.
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

class AsyncSocket:
    """
    Defines an asynchronous socket interface. Implementors are not
    required to inherit this class, but they must define the same
    interface.

    Note that only the thread that creates an instance of this class
    may access the instance.

    Note also that all the callbacks made by this object are
    passed the following parameters, in the order listed:
    
    1. event originator (an ``AsyncSocket`` handle)

    2. event type (the name of the method used to make the request)

    3. status (an ``Exception`` instance, or ``None`` if no error)

    4. any request-specific payload (or ``None`` if none)

    5. callback parameter, as specified when making the request
    """

    def close(self):
        """
        Closes the socket and frees all the associated network
        resources. After this call, any asynchronous requests will
        have been cancelled, and no events will be delivered.

        This method does not throw any exceptions.
        
        It is safe to call this method even if the socket has already
        been closed. However, after calling this method no other
        methods in the object may be called.
        """
        raise NotImplementedError

    def recv(self, size, cb_func, cb_param):
        """
        Makes a request to read at most ``size`` bytes from the
        socket, and to call the ``cb_func`` callback function passing
        the result as well as ``cb_param`` as function arguments.

        The callback will not be made until the operation either
        completes or fails. An empty string is returned as the
        requested data to signal an EOF sent by the peer.

        At most one ``recv`` request at a time may be outstanding.
        """
        raise NotImplementedError

    def sendall(self, data, cb_func, cb_param):
        """
        Sends the given data, calling the ``cb_func`` callback
        function with a result value and ``cb_param`` as arguments
        once the socket operation has either completed or failed.

        At most one ``sendall`` request at a time may be outstanding.
        """
        raise NotImplementedError

    def listen(self, cb_func, cb_param, **kw):
        """
        Binds the socket, and has it start listening for connections.
        This allows for connection requests to be queued, potentially
        speeding up the completion of ``accept`` requests. Once the
        operation completes or fails, calls the ``cb_func`` callback
        function with a result value and ``cb_param`` as arguments. At
        most one ``connect`` request at a time may be outstanding. The
        keyword arguments are transport-specific.
        """
        raise NotImplementedError

    def accept(self, cb_func, cb_param):
        """
        Has the socket accept a connection. Once the operation
        completes or fails, calls the ``cb_func`` callback function
        with a result value, the created socket, and ``cb_param`` as
        arguments. At most one ``accept`` request at a time may be
        outstanding.
        """
        raise NotImplementedError

    def connect(self, cb_func, cb_param, **kw):
        """
        Tries to connect the socket to a peer. Once the operation
        completes or fails, calls the ``cb_func`` callback function
        with a result value and ``cb_param`` as arguments. At most one
        ``connect`` request at a time may be outstanding. The keyword
        arguments are transport-specific.
        """
        raise NotImplementedError
