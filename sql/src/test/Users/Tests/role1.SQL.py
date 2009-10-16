import os, sys
from MonetDBtesting import process

def main():
    clt = process.client('sql', user = 'my_user', passwd = 'p1',
                         stdin = open(os.path.join(os.getenv('RELSRCDIR'), '..', 'role.sql')),
                         stdout = process.PIPE, stderr = process.PIPE)
    out, err = clt.communicate()
    sys.stdout.write(out)
    sys.stderr.write(err)

main()
