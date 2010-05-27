#
# abst_async_mgr.py
# 
# Copyright 2004 Helsinki Institute for Information Technology (HIIT)
# and the authors.  All rights reserved.
# 
# Authors: Tero Hasu <tero.hasu@hut.fi>
#
# This module can be used to fit an asynchronous socket manager
# within the PDIS socket framework.
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

"""
This module implements the ``pdis.socket.blocking_socket`` interfaces
by wrapping functionality found in the ``aosocket.async_socket_mgr``
module.
"""

from aosocket.async_mgr_base import AsyncMgrBase
from pdis.socket.socket_exceptions import ConnectionFailed, ServerTerminated
from pdis.lib.logging import log_exception



class AbstAsyncSocket:
    """
    A wrapper for a single socket managed by an ``AbstAsyncMgr``
    instance. Implements both the ``Endpoint`` and ``Server``
    interfaces.
    """

    def __init__(self, manager, handle):
        self.manager = manager
        self.handle = handle

    # ----------------------------------------------------------------
    # common methods...

    def close(self):
        try:
            self.manager.close_socket(self.handle)
        except:
            pass

    # ----------------------------------------------------------------
    # Endpoint methods...

    def recv(self, size):
        """
        May throw a ``SessionClosed`` exception.
        """
        return self.manager.recv_socket(self.handle, size)

    def sendall(self, data):
        """
        May throw a ``SessionClosed`` exception.
        """
        return self.manager.sendall_socket(self.handle, data)

    # ----------------------------------------------------------------
    # Server methods...

    def accept(self):
        """
        The returned object will implement the ``Endpoint`` interface,
        or more specifically it will be an instance of ``AbstAsyncSocket``.

        May throw a ``ServerTerminated`` exception.
        """
        try:
            cl_handle = self.manager.accept_socket(self.handle)
            return AbstAsyncSocket(self.manager, cl_handle)
        except:
            log_exception()
            raise ServerTerminated



class AbstAsyncMgr(AsyncMgrBase):
    """
    An asynchronous socket manager that implements the ``Manager``
    interface.
    """

    def new_socket_instance(self):
        """
        A method that returns a new socket instance. We require this
        method as the ``connect`` and ``listen`` methods defined
        here do not take any parameters specifying the type of socket
        to instantiate.

        This method will be called by the internal thread only
        (whether or not that has any relevance to your implementation).
        
        For subclassers to implement.
        """
        raise NotImplementedError

    def parse_address(self, address):
        """
        Converts an address of the form ([host [port]] [dict])
        to a dictionary.
        """
        num = len(address)
        if num == 0:
            return {}
        if isinstance(address[num-1], dict):
            map = address[num-1].copy()
            num -= 1
        else:
            map = {}
        if num == 1:
            map["host"] = address[0]
        elif num == 2:
            map["host"] = address[0]
            map["port"] = address[1]
        elif num > 2:
            raise ValueError
        return map

    def connect(self, address):
        handle = self.create_socket(self.new_socket_instance)
        try:
            self.connect_socket(handle, **self.parse_address(address))
            return AbstAsyncSocket(self, handle)
        except:
            log_exception()
            try:
                self.close_socket(handle)
            except:
                pass
            raise ConnectionFailed

    def listen(self, address):
        handle = self.create_socket(self.new_socket_instance)
        try:
            self.listen_socket(handle, **self.parse_address(address))
        except:
            self.close_socket(handle)
            raise
        return AbstAsyncSocket(self, handle)
