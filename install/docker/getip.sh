#!/bin/sh

# Copyright (c) 2015, 2016 Rafał Pocztarski
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# get internal IP address
# used for outgoing Internet connections
# see: https://github.com/rsp/scripts/blob/master/internalip.md

resolve() {
	(gethostip -d $1 || getent ahostsv4 $t | grep RAW | awk '{print $1; exit}') 2>/dev/null
}
noip() {
	[ -n "$(echo $1 | tr -d '0-9.\n')" ]
}

[ -n "$1" ] && t=$1 || t='8.8.8.8'

noip $t && t=$(resolve $t)

[ -n "$t" ] || { echo Cannot resolve domain $1 >&2; exit 1; }

ip route get $t | awk '{print $NF; exit}'