#
# async_socket_exceptions.py
# 
# Copyright 2004 Helsinki Institute for Information Technology (HIIT)
# and the authors.  All rights reserved.
# 
# Authors: Tero Hasu <tero.hasu@hut.fi>
#
# Various exceptions used by the library.
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

class AsyncSocketError(Exception):
    """
    All custom exceptions that may be raised by ``AsyncSocket``
    and its subclasses should be of this kind. This does not
    mean that other exceptions thrown by Python or its standard
    libraries could not get thrown.
    """
    pass

class AsyncSocketRequestPending(AsyncSocketError):
    """
    An attempt to make a request was made when a request of the same
    type was still pending.
    """
    pass

class AsyncSocketNotOpen(AsyncSocketError):
    """
    An attempt to make a request was made when the socket had already
    been closed, or the request did not have time to complete before
    the socket was closed.
    """
    pass

class AsyncSocketReqCancel(AsyncSocketError):
    """
    A request made on a socket was cancelled before the socket
    operation completed.
    """
    pass

class AsyncSocketMgrNotOpen(AsyncSocketError):
    """
    A socket request was made when the manager of the socket had
    already been closed, or the manager was closed during the request,
    before the request had time to complete.
    """
    pass

class AsyncSocketAlreadyOpen(AsyncSocketError):
    """
    An attempt was made to initialize a socket that was already open.
    """
    pass
