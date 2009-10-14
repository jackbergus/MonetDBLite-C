import os, time, sys
import subprocess

def server_start(x,dbname):
    if os.name == 'nt':
        bufsize = -1
    else:
        bufsize = 0
    srvcmd = '%s --dbname "%s"' % (os.getenv('MSERVER'),dbname)
    return subprocess.Popen(srvcmd, bufsize=bufsize, shell=True, universal_newlines=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE)

def server_stop(srv):
    out, err = srv.communicate()
    sys.stdout.write(out)

prelude_1 = '''
module(tcpip);
VAR mapiport := monet_environment.find("mapi_port");
fork(listen(int(mapiport)));
'''

prelude_2 = '''
module(tcpip);
module(unix);
module(ascii_io);
VAR host := getenv("HOST");
VAR mapiport := monet_environment.find("mapi_port");
VAR c := open(host+":"+mapiport);
VAR TSTTRGDIR := getenv("TSTTRGDIR");
'''

script_2 = '''
var test1 := bat(oid, oid);
test1.import(TSTTRGDIR + "/tcpip2.init.bat");
test1.kunique().count().print();
c.export(test1, "test1");
'''

script_1 = '''
var test2 := import("test1", true);
test2.kunique().count().print();
'''

def main():
    x = 0
    x += 1; srv1 = server_start(x, "db" + str(x))
    x += 1; srv2 = server_start(x, "db" + str(x))

    srv1.stdin.write(prelude_1)
    time.sleep(1)                      # give server 1 time to start
    srv2.stdin.write(prelude_2)

    srv2.stdin.write(script_2)
    srv1.stdin.write(script_1)

    srv1.stdin.write("quit();\n")
    srv2.stdin.write("quit();\n")

    server_stop(srv1)
    server_stop(srv2)

main()
