import os, time, sys
import subprocess

def server_start(x,dbname):
    srvcmd = '%s --dbname "%s"' % (os.getenv('MSERVER'),dbname)
    if os.name == 'nt':
        bufsize = -1
    else:
        bufsize = 0
    return subprocess.Popen(srvcmd, bufsize=bufsize, shell=True, universal_newlines=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE)

def server_stop(srv):
    out, err = srv.communicate()
    sys.stdout.write(out)

prelude_1 = '''
module(tcpip);
module(radix);
module(alarm);
VAR mapiport := monet_environment.find("mapi_port");

PROC g(): bat[void, dbl] {
        var a := uniform(100000).[dbl]().copy();
        printf("done...\n");
        RETURN a;
}

fork(listen(int(mapiport)));
'''

prelude_2 = '''
module(tcpip);
module(unix);
VAR host := getenv("HOST");
VAR mapiport := monet_environment.find("mapi_port");
VAR c := open(host+":"+mapiport);
'''

script_2 = '''
var res := rpc(c, "g();"); # caused crash
print(count(res));
print(mark(slice(res, 0, 10), 0@0)); # mark to avoid random output
'''

script_1 = '''
sleep(2);
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
