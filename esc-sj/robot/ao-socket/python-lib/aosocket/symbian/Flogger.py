#
# Flogger.py
# 
# Copyright 2004 Helsinki Institute for Information Technology (HIIT)
# and the authors.  All rights reserved.
# 
# Authors: Tero Hasu <tero.hasu@hut.fi>
#
# A logger that makes use of the native Symbian logging API.
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

"""
Does Close() close the whole session or just a
single log file? May a session handle be shared between threads?
Do we have to do something in particular to make that happen? Is
it okay to have multiple sessions writing to the same file, and
what will then happen with truncation?
I wish there was a document with answers to these questions.
"""

class Flogger:
    """
    A wrapper for ``aosocketnativenew.AoFlogger``.
    """
    
    def __init__(self):
        self.logger = aosocketnativenew.AoFlogger()

    def connect(self):
        self.logger.connect()

    def close(self):
        self.logger.close()

    def create_log(self, dirname, filename):
        self.logger.create_log(unicode(dirname), unicode(filename))

    def write(self, text):
        self.logger.write(unicode(text))
