import os, sys, time
import subprocess


def client(cmd, infile = None):
    if infile is not None:
        f = open(infile)
    else:
        f = None
    Mlog = "\n%s  %s\n\n" % (time.strftime('# %H:%M:%S >',time.localtime(time.time())), cmd)
    sys.stdout.write(Mlog)
    sys.stderr.write(Mlog)
    clt = subprocess.Popen(cmd, shell=True, stdin = f)
    if f is not None:
        f.close()
    clt.wait()


def main():
    client(os.getenv('SQL_CLIENT'),
           os.path.join(os.getenv('TSTSRCDIR'),
                        'JdbcClient_create_tables.sql'))
    client(os.getenv('SQL_CLIENT'),
           os.path.join(os.getenv('TSTSRCDIR'),
                        'JdbcClient_inserts_selects.sql'))
    client(os.getenv('SQL_DUMP'))

main()
