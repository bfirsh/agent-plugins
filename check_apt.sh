#!/bin/bash
# Cloudkick plugin to check for updated apt packages on Ubuntu
#
# Copyright (C) 2010 by Ben Firshman <ben@firshman.co.uk>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.


# Piggy back Ubuntu's cached update notices
UPDATES_AVAILABLE=`/usr/lib/update-notifier/update-motd-updates-available`
UPDATE_COUNT=`echo "$UPDATES_AVAILABLE" | awk 'NR==2 { print $1 }'`
SECURITY_COUNT=`echo "$UPDATES_AVAILABLE" | awk 'NR==3 { print $1 }'`
UPDATES_SINGLE_LINE=`echo "$UPDATES_AVAILABLE" | tr "\n" " "`

REBOOT_REQUIRED=`/usr/lib/update-notifier/update-motd-reboot-required`

if [ -n "$REBOOT_REQUIRED" ]; then
   echo "status err $REBOOT_REQUIRED, $UPDATES_SINGLE_LINE"
   exit
fi

if [ $SECURITY_COUNT -gt 0 ]; then
   STATUS="err"
else
   STATUS="ok"
fi

echo "status $STATUS $UPDATES_SINGLE_LINE"

