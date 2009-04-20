#!/usr/bin/env python

# The contents of this file are subject to the MonetDB Public License
# Version 1.1 (the "License"); you may not use this file except in
# compliance with the License. You may obtain a copy of the License at
# http://monetdb.cwi.nl/Legal/MonetDBLicense-1.1.html
#
# Software distributed under the License is distributed on an "AS IS"
# basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
# License for the specific language governing rights and limitations
# under the License.
#
# The Original Code is the MonetDB Database System.
#
# The Initial Developer of the Original Code is CWI.
# Portions created by CWI are Copyright (C) 1997-July 2008 CWI.
# Copyright August 2008-2009 MonetDB B.V.
# All Rights Reserved.
#

# TODO: cleanup, do we need monet_options.py?

import sys

try:
    from monetdb import monet_options
    from monetdb.mapi import Server
except ImportError:
    # if running from the build directory Mapi is not in MonetDB module
    import monet_options
    from mapi import Server


def main(argv) :

    cmd_options = [
        ('host',None,'host','hostname','host to connect to (default: localhost)'),
        ('port',None,'mapi_port','port','port to connect to (default: 50000)'),
        ('user',None,'user','user','login as user (default: monetdb)'),
        ('passwd',None,'passwd','passwd','password (default: monetdb)'),
        ('language',None,'language','language','language (default: sql)'),
        ('database',None,'database','database','database (default: "")'),
        ('mapi_trace',None,'mapi_trace', None, 'mapi_trace'),
        ('encoding',None,'encoding','encoding','character encoding'),
        ]

    try:
        opt, args = monet_options.parse_options(argv[1:], cmd_options)
    except monet_options.Error:
        # error parsing options
        sys.exit(1)

    encoding = opt.get("encoding", None)
    if encoding is None:
        import locale
        encoding = locale.getlocale()[1]
        if encoding is None:
            encoding = locale.getdefaultlocale()[1]

    s = Server()

    s.connect(hostname = opt.get("host", "localhost"),
              port = int(opt.get("mapi_port", 50000)),
              username = opt.get("user", "monetdb"),
              password = opt.get("passwd", "monetdb"),
              language = opt.get("language", "sql"),
              database = opt.get("database", ""))
    print "#mclient (python) connected to %s:%d as %s" % \
          (opt.get("host", "localhost"),
           int(opt.get("mapi_port", 50000)),
           opt.get("user", "monetdb"))

    #fi = fileinput.FileInput()
    fi = sys.stdin

    sys.stdout.write(s.prompt.encode('utf-8'))
    line = fi.readline()
    prompt = s.prompt
    if encoding != 'utf-8':
        prompt = unicode(prompt, 'utf-8').encode(encoding, 'replace')
    while line and line != "\q\n":
        if encoding != 'utf-8':
            line = unicode(line, encoding).encode('utf-8')
        res = s.cmd(line)
        if encoding != 'utf-8':
            res = unicode(res, 'utf-8').encode(encoding, 'replace')
        print res
        sys.stdout.write(prompt)
        line = fi.readline()

    s.disconnect()

### main(argv) #


if __name__ == "__main__":
    if '--trace' in sys.argv:
        sys.argv.remove('--trace')
        try:
            from MonetDBtesting import trace
        except ImportError:
            # if running from the build directory trace is not in MonetDB module
            import trace
        t = trace.Trace(trace=1, count=0)
        t.runfunc(main, sys.argv)
    else:
        main(sys.argv)
