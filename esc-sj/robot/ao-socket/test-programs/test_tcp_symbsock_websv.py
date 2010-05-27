#
# test_tcp_symbsock_websv.py
# 
# Copyright 2004 Helsinki Institute for Information Technology (HIIT)
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

from pdis.lib.logging import *
init_logging(FileLogger("c:\\logs\\aosocket\\testapp.txt"))

# start dummy thread
import thread
thread_lck = thread.allocate_lock()
thread_lck.acquire()
def worker_thread(thread_lck):
    thread_lck.acquire()
    thread_lck.release()
thread_id = thread.start_new_thread(worker_thread, (thread_lck,))

# setup Exit key handler
old_title = appuifw.app.title
appuifw.app.title = u"TestApp"
script_lock = e32.Ao_lock()
def exit_handler():
    script_lock.signal()
appuifw.app.exit_key_handler = exit_handler

response = r'''HTTP/1.1 200 OK
Date: Thu, 18 Mar 2004 15:23:46 GMT
Server: Apache/2.0.40 (Red Hat Linux)
Last-Modified: Thu, 11 Sep 2003 13:48:07 GMT
ETag: "113163-299-cb833c0"
Accept-Ranges: bytes
Content-Length: 665
Connection: close
Content-Type: text/html; charset=ISO-8859-1

<html>
<head>
<title>PDIS Web Server</title>
</head>

<body>

<a href="http://www.hiit.fi/">
  <img src="/rimey/images/hiit.jpg" alt="HIIT"
       border="0" align="left"/>
</a>

<a href="/pdis/">
  <img src="/rimey/images/no-commit.png" alt="PDIS"
       width="160" height="160" border="0" align="right"/>
</a>

<br clear="all"/>

<hr/>

<h1 align="center">PDIS Web Server</h1>

<h2><a href="/pdis/">PDIS Project</a>:</h2>
<ul>
<li><a href="/pdis/overview/">Brief project overview</a></li>
<li><a href="/wiki/pdis/">PDIS Wiki (partner organizations only)</a></li>
</ul>

<hr/>

<address>
  <a href="mailto:rimey@hiit.fi">Ken Rimey</a>
</address>

</body>
</html>
'''

# serve clients until Exit pressed
try:
    from aosocket.symbian.symbian_socket import TcpSymbianSocket, SymbianSocketServ


    def written(error, sock):
        if error == 0:
            print "response sent"
        else:
            print "failed to send a response"
        sock.close()

    def read(error, payload, sock):
        if error == 0:
            logwrite(payload)
            print "got request (logged)"
            sock.sendall(response, written, sock)
        else:
            print "read failed"
            sock.close()

    def accepted(error, cl_sock, sv_sock):
        if error == 0:
            print "client accepted"
            cl_sock.recv(1024, read, cl_sock)
        else:
            print "accept failed"
            cl_sock.close()
        sv_sock.accept(TcpSymbianSocket().blank(serv), accepted, sv_sock)


    serv = SymbianSocketServ()
    sock = TcpSymbianSocket()
    sock.listen(serv, ("127.0.0.1", 2000), 5)
    sock.accept(TcpSymbianSocket().blank(serv), accepted, sock)
    
    script_lock.wait()
    sock.close()
    serv.close()
except:
    log_exception()
    appuifw.note(u"Fatal error.", "error")

# stop dummy thread
thread_lck.release()
thread.ao_waittid(thread_id)

appuifw.app.title = old_title
appuifw.app.set_exit()
