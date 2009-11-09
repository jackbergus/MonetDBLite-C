import os, sys
from MonetDBtesting import process

def client(infile, user = 'monetdb', passwd = 'monetdb'):
    clt = process.client('sql', user=user, passwd=passwd, stdin=open(infile),
                         stdout=process.PIPE, stderr=process.PIPE)
    out, err = clt.communicate()
    sys.stdout.write(out)
    sys.stderr.write(err)



def main():
    relsrcdir = os.getenv('RELSRCDIR')
    sys.stdout.write('trigger owner\n')
    client(os.path.join(relsrcdir, '..', 'trigger_owner_create.sql'))
    client(os.path.join(relsrcdir, '..', 'trigger_owner.sql'),
           user='user_test', passwd='pass')
    client(os.path.join(relsrcdir, '..', 'trigger_owner_drop.sql'))
    sys.stdout.write('done\n')

main()
