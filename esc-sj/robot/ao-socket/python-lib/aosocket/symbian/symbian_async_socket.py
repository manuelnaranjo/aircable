#
# symbian_async_socket.py
# 
# Copyright 2004 Helsinki Institute for Information Technology (HIIT)
# and the authors.  All rights reserved.
# 
# Authors: Tero Hasu <tero.hasu@hut.fi>
#
# A Symbian implementation of the type of asynchronous sockets
# that are used as an abstraction within this module.
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

from aosocket.async_socket import AsyncSocket
from aosocket.async_socket_exceptions import *
from aosocket.symbian.bt_utils import check_mac
from aosocket.symbian.symbian_socket import *
from aosocketnativenew import AoImmediate, AoPortDiscoverer



class SymbianNativeError(Exception):
    def __init__(self, value):
        """
        Records ``value``, which should be the error code
        of the Symbian native error.
        """
        self.value = value
    def __str__(self):
        return repr(self.value)




class SymbianAsyncSocket(AsyncSocket):
    """
    An abstract class intended to be used as a base class
    in ``AsyncSocket`` interface implementations for Symbian OS.
    """

    def __init__(self, socket_serv, **kw):
        self.socket_serv = socket_serv
        if kw.has_key('em_socket'):
            self.socket = kw['em_socket']
        else:
            self.socket = self.new_ll_socket()

    def new_ll_socket(self):
        """
        Returns a new low-level socket object of the kind
        used by the particular ``SymbianAsyncSocket``.

        Subclassers must implement.
        """
        raise NotImplementedError

    def close(self):
        self.socket.close()

    def recv(self, size, cb_func, cb_param):
        self.socket.recv(size, self.__recv_cb, (cb_func, cb_param))

    def __recv_cb(self, error, data, param):
        cb_func, cb_param = param
        if error:
            cb_func(self, "recv", SymbianNativeError(error),
                    None, cb_param)
        else:
            cb_func(self, "recv", None, data, cb_param)

    def sendall(self, data, cb_func, cb_param):
        self.socket.sendall(data, self.__sendall_cb,
                            (cb_func, cb_param))

    def __sendall_cb(self, error, param):
        cb_func, cb_param = param
        if error:
            cb_func(self, "sendall", SymbianNativeError(error),
                    None, cb_param)
        else:
            cb_func(self, "sendall", None, None, cb_param)



class TcpSymbianAsyncSocket(SymbianAsyncSocket):
    """
    Implements the ``AsyncSocket`` interface utilizing
    the lower-level operations provided by ``TcpSymbianSocket``.
    """

    def __init__(self, socket_serv, **kw):
        SymbianAsyncSocket.__init__(self, socket_serv, **kw)
        self.immediate = AoImmediate()
        self.immediate.open()
        
    def close(self):
        self.immediate.close()
        SymbianAsyncSocket.close(self)

    def new_ll_socket(self):
        return TcpSymbianSocket()

    def listen(self, cb_func, cb_param, **kw):
        """
        Binds the socket to the specified port at the specified
        network interface. Also has the socket start listening for
        connections. The maximum size of the backlog is optionally
        specified by ``number``.
        """
        host = kw['host']
        if not host:
            raise TypeError, "no host address given"
        port = kw['port']
        if not port:
            raise TypeError, "no port number given"
        address = (host, port)
        
        number = None
        if kw.has_key('number'):
            number = kw['number']
        if not number:
            number = 5
            
        self.socket.listen(self.socket_serv, address, number)
        self.immediate.complete(self.__listen_cb, (cb_func, cb_param))

    def __listen_cb(self, error, param):
        cb_func, cb_param = param
        cb_func(self, "listen", None, None, cb_param)

    def accept(self, cb_func, cb_param):
        """
        Once the socket is bound and listening, accepts a connection
        asynchronously.
        """
        bl_socket = self.new_ll_socket()
        bl_socket.blank(self.socket_serv)
        self.socket.accept(bl_socket, self.__accept_cb,
                           (cb_func, cb_param))

    def __accept_cb(self, error, bl_socket, param):
        cb_func, cb_param = param
        if error:
            cb_func(self, "accept", SymbianNativeError(error),
                    None, cb_param)
        else:
            cb_func(self, "accept", None,
                    TcpSymbianAsyncSocket(self.socket_serv,
                                          em_socket = bl_socket),
                    cb_param)

    def connect(self, cb_func, cb_param, **kw):
        """
        Connects to the specified port of the specified host.
        """
        host = kw['host']
        if not host:
            raise TypeError, "no host address given"
        port = kw['port']
        if not port:
            raise TypeError, "no port number given"
        address = (host, port)

        self.socket.connect(self.socket_serv, address,
                            self.__connect_cb, (cb_func, cb_param))

    def __connect_cb(self, error, param):
        cb_func, cb_param = param
        if error:
            cb_func(self, "connect", SymbianNativeError(error),
                    None, cb_param)
        else:
            cb_func(self, "connect", None, None, cb_param)



class BtSymbianAsyncSocket(SymbianAsyncSocket):
    """
    Implements the ``AsyncSocket`` interface utilizing
    the lower-level operations provided by ``BtSymbianSocket``.
    """

    def __init__(self, socket_serv, **kw):
        SymbianAsyncSocket.__init__(self, socket_serv, **kw)
        self.discoverer = AoPortDiscoverer()
        self.discoverer.open()
        
    def close(self):
        self.discoverer.close()
        SymbianAsyncSocket.close(self)

    def new_ll_socket(self):
        return BtSymbianSocket()

    def listen(self, cb_func, cb_param, **kw):
        """
        If you want, you may pass the "port" keyword argument to
        specify which port to bind to--otherwise, a free one is
        allocated automatically. Note that there is no need to specify
        any local address other than the port--it is assumed that
        there is only one Bluetooth interface, and that one will be
        used automatically.

        If you do not want to use the default value, use the "number"
        keyword argument to specify the queue size for peer-initiated
        connections.

        For SDP advertising purposes, you must supply the "service_id"
        and "service_name" keyword arguments.
        """
        port = None
        if kw.has_key('port'):
            port = kw['port']
        address = (None, port)

        number = None
        if kw.has_key('number'):
            number = kw['number']
        if not number:
            number = 5
            
        service_id = None
        if kw.has_key('service_id'):
            service_id = kw['service_id']
        if not service_id:
            raise ValueError, "service ID not given"
            
        service_name = None
        if kw.has_key('service_name'):
            service_name = kw['service_name']
        if not service_name:
            raise ValueError, "service name not given"
        
        self.socket.listen(self.socket_serv, address, number,
                           service_id, service_name)
        self.socket.configure(self.__config_cb, (cb_func, cb_param))

    def __config_cb(self, error, param):
        cb_func, cb_param = param
        if error:
            cb_func(self, "listen", SymbianNativeError(error),
                    None, cb_param)
        else:
            cb_func(self, "listen", None, None, cb_param)

    def accept(self, cb_func, cb_param, **kw):
        bl_socket = self.new_ll_socket()
        bl_socket.blank(self.socket_serv)
        self.socket.accept(bl_socket, self.__accept_cb,
                           (cb_func, cb_param))

    def __accept_cb(self, error, bl_socket, param):
        cb_func, cb_param = param
        if error:
            cb_func(self, "accept", SymbianNativeError(error),
                    None, cb_param)
        else:
            cb_func(self, "accept", None,
                    BtSymbianAsyncSocket(self.socket_serv,
                                         em_socket = bl_socket),
                    cb_param)

    def connect(self, cb_func, cb_param, **kw):
        """
        You should specify either the "host" and "port" to connect to,
        or the "host" and "service_id" to connect to. In the latter
        case, an attempt is made to have the port discovered using
        SDP.
        """
        host = None
        if kw.has_key('host'):
            host = kw['host']
        if not host:
            raise ValueError, "host address not given"

        port = None
        if kw.has_key('port'):
            port = kw['port']
        
        if port:
            self.socket.connect(self.socket_serv, (host, port),
                                self.__connect_cb, (cb_func, cb_param))
        else:
            # Have to resolve the port first.
            check_mac(host)

            service_id = None
            if kw.has_key('service_id'):
                service_id = kw['service_id']
            if not service_id:
                raise TypeError, "no port or service ID specified"

            self.discoverer.discover(unicode(host),
                                     service_id,
                                     self.__discover_cb,
                                     (cb_func, cb_param, host))

    def __discover_cb(self, error, port, param):
        cb_func, cb_param, host = param
        if error:
            cb_func(self, "connect", SymbianNativeError(error),
                    None, cb_param)
        else:
            try:
                self.socket.connect(self.socket_serv, (host, port),
                                    self.__connect_cb,
                                    (cb_func, cb_param))
            except Exception, exc:
                cb_func(self, "connect", exc, None, cb_param)

    def __connect_cb(self, error, param):
        cb_func, cb_param = param
        if error:
            cb_func(self, "connect", SymbianNativeError(error),
                    None, cb_param)
        else:
            cb_func(self, "connect", None, None, cb_param)
