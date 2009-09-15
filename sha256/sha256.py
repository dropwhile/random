#!/usr/bin/env python
# Copyright (c) 2009 elij <elij.mx [at] gmail.comm>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.

"""
Simple sha256 script for python.

Usage: 
  sha256.py file1 file2 .. fileN
"""
import sys
import hashlib

def chunksize(size, filename):
    """Read a file in chunks"""
    f = open(filename, 'rb')
    done = 0
    while not done:
        chunk=f.read(size)
        if chunk:
            yield chunk
        else:
            done = 1
    f.close()
    return

def sha256(filename):
    """Calculate the sha256 of a given file path"""
    h = hashlib.sha256()
    for chunk in chunksize(16384, filename):
        h.update(chunk)
    return h.hexdigest()

if __name__ == '__main__':
    for filename in sys.argv[1:]:
        print filename, sha256(filename)

