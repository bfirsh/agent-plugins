#!/usr/bin/python
# Cloudkick plugin to check for updated apt packages
# Requires python-apt package
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

import apt

DIST_UPGRADE = True
SECURITY_STATUS = 'err'
# If you do not want a warning for updates which aren't security updates,
# set this to 'ok'
CHANGED_STATUS = 'warn'

cache = apt.Cache()
cache.update()
cache.open(None)
# Doesn't actually upgrade unless we call commit
cache.upgrade(DIST_UPGRADE)

changed = cache.get_changes()
security = 0

for package in changed:
    for origin in package.candidate.origins:
        if 'security' in origin.archive:
            security += 1

if security > 0:
    print 'status %s %s packages with security updates' % (SECURITY_STATUS, security)
elif len(changed) > 0:
    print 'status %s %s packages changed status' % (CHANGED_STATUS, len(changed))
else:
    print 'status ok 0 packages changed status'

print 'metric changed int %s' % len(changed)
print 'metric security int %s' % security


