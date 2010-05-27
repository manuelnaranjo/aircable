#
# pdis.lib.best_threading
#
# Copyright 2004 Helsinki Institute for Information Technology (HIIT)
# and the authors.  All rights reserved.
#
# Authors: Ken Rimey <rimey@hiit.fi>
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
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

"""
Basic threads and locks

This module defines two functions, start_thread() and allocate_lock().
It uses the threading module if it is available, and the thread module
otherwise.
"""

try:
    import threading

    allocate_lock = threading.Lock

    def start_thread(target, name = None, args = ()):
        """Create and start a new daemon thread."""
        thread = threading.Thread(target = target, name = name, args = args)
        thread.setDaemon(True)
        thread.start()
        return thread

except ImportError:
    import thread

    allocate_lock = thread.allocate_lock

    def start_thread(target, name = None, args = ()):
        """Create and start a new daemon thread."""
        return thread.start_new_thread(target, args)
