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
module(alarm);
VAR mapiport := monet_environment.find("mapi_port");
'''

script_1 = '''
{
fork(listen(int(mapiport)+%d));
var y := import("x", true);
y.print();
}
'''
#terminate(int(mapiport)+1);

prelude_2 = '''
module(tcpip);
module(alarm);
module(unix);
VAR host := getenv("HOST");
VAR mapiport := monet_environment.find("mapi_port");
'''

script_2 = '''
{
sleep(2); # waiting for first server to start listening
VAR c := open(host+":"+(int(mapiport)+%d));
var x := bat(oid, oid);
x.insert(0@0, 0@0);
x.insert(1@0, 0@0);
x.sort().print();
c.export(x, "x");
close(c);
}
'''

def main():
    x = 0
    x += 1; srv1 = server_start(x, "db" + str(x))
    x += 1; srv2 = server_start(x, "db" + str(x))
    time.sleep(1)                      # give servers time to start

    srv1.stdin.write(prelude_1)
    srv2.stdin.write(prelude_2)
    i = 0
    while i < 4:
        srv1.stdin.write(script_1 % (i))
        srv2.stdin.write(script_2 % (i))
        i += 1

    srv1.stdin.write("quit();\n")
    srv2.stdin.write("quit();\n")

    server_stop(srv1)
    server_stop(srv2)

main()
