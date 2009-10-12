import os, time, sys
import subprocess

def server_start(x,s,dbinit):
    srvcmd = '%s --dbname "%s" --dbinit "%s"' % (os.getenv('MSERVER'),os.getenv('TSTDB'),dbinit)
    sys.stdout.write('\nserver %d%d : "%s"\n' % (x,s,dbinit))
    sys.stderr.write('\nserver %d%d : "%s"\n' % (x,s,dbinit))
    sys.stdout.flush()
    sys.stderr.flush()
    srv = subprocess.Popen(srvcmd, shell = True, stdin = subprocess.PIPE)
    time.sleep(5)                      # give server time to start
    return srv

def server_stop(srv):
    srv.communicate()

def client(x,s, c, dbinit, lang, cmd, h):
    cltcmd = os.getenv('%s_CLIENT' % lang)
    sys.stdout.write('\nserver %d%d : "%s", client %d: %s%s\n' % (x,s,dbinit,c,h,lang))
    sys.stderr.write('\nserver %d%d : "%s", client %d: %s%s\n' % (x,s,dbinit,c,h,lang))
    sys.stdout.flush()
    sys.stderr.flush()
    clt = subprocess.Popen(cltcmd, shell = True, stdin = subprocess.PIPE)
    clt.communicate(cmd)
    return '%s(%s) ' % (h,lang)

def clients(x,dbinit):
    s = 0
    s += 1; srv = server_start(x,s,dbinit)
    c = 0 ; h = ''
    c += 1; h = client(x,s,c,dbinit,'XQUERY',      '%d%d%d\n'   % (x,s,c),h)
    c += 1; h = client(x,s,c,dbinit,'XQUERY',      '%d%d%d\n'   % (x,s,c),h)
    c += 1; h = client(x,s,c,dbinit,'MIL'   ,'print(%d%d%d);\n' % (x,s,c),h)
    c += 1; h = client(x,s,c,dbinit,'MIL'   ,'print(%d%d%d);\n' % (x,s,c),h)
    server_stop(srv)
    s += 1; srv = server_start(x,s,dbinit)
    c = 0 ; h = ''
    c += 1; h = client(x,s,c,dbinit,'XQUERY',      '%d%d%d\n'   % (x,s,c),h)
    c += 1; h = client(x,s,c,dbinit,'MIL'   ,'print(%d%d%d);\n' % (x,s,c),h)
    c += 1; h = client(x,s,c,dbinit,'XQUERY',      '%d%d%d\n'   % (x,s,c),h)
    c += 1; h = client(x,s,c,dbinit,'MIL'   ,'print(%d%d%d);\n' % (x,s,c),h)
    server_stop(srv)
    s += 1; srv = server_start(x,s,dbinit)
    c = 0 ; h = ''
    c += 1; h = client(x,s,c,dbinit,'MIL'   ,'print(%d%d%d);\n' % (x,s,c),h)
    c += 1; h = client(x,s,c,dbinit,'XQUERY',      '%d%d%d\n'   % (x,s,c),h)
    c += 1; h = client(x,s,c,dbinit,'XQUERY',      '%d%d%d\n'   % (x,s,c),h)
    c += 1; h = client(x,s,c,dbinit,'MIL'   ,'print(%d%d%d);\n' % (x,s,c),h)
    server_stop(srv)
    s += 1; srv = server_start(x,s,dbinit)
    c = 0 ; h = ''
    c += 1; h = client(x,s,c,dbinit,'XQUERY',      '%d%d%d\n'   % (x,s,c),h)
    c += 1; h = client(x,s,c,dbinit,'MIL'   ,'print(%d%d%d);\n' % (x,s,c),h)
    c += 1; h = client(x,s,c,dbinit,'MIL'   ,'print(%d%d%d);\n' % (x,s,c),h)
    c += 1; h = client(x,s,c,dbinit,'XQUERY',      '%d%d%d\n'   % (x,s,c),h)
    server_stop(srv)
    s += 1; srv = server_start(x,s,dbinit)
    c = 0 ; h = ''
    c += 1; h = client(x,s,c,dbinit,'MIL'   ,'print(%d%d%d);\n' % (x,s,c),h)
    c += 1; h = client(x,s,c,dbinit,'XQUERY',      '%d%d%d\n'   % (x,s,c),h)
    c += 1; h = client(x,s,c,dbinit,'MIL'   ,'print(%d%d%d);\n' % (x,s,c),h)
    c += 1; h = client(x,s,c,dbinit,'XQUERY',      '%d%d%d\n'   % (x,s,c),h)
    server_stop(srv)
    s += 1; srv = server_start(x,s,dbinit)
    c = 0 ; h = ''
    c += 1; h = client(x,s,c,dbinit,'MIL'   ,'print(%d%d%d);\n' % (x,s,c),h)
    c += 1; h = client(x,s,c,dbinit,'MIL'   ,'print(%d%d%d);\n' % (x,s,c),h)
    c += 1; h = client(x,s,c,dbinit,'XQUERY',      '%d%d%d\n'   % (x,s,c),h)
    c += 1; h = client(x,s,c,dbinit,'XQUERY',      '%d%d%d\n'   % (x,s,c),h)
    server_stop(srv)

def main():
    x = 0
    x += 1; clients(x,"module(pathfinder); mil_start();")

main()
