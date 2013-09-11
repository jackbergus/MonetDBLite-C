import os, sys, re
try:
    from MonetDBtesting import process
except ImportError:
    import process

TSTSRCDIR = os.environ['TSTSRCDIR']

c = process.client('sql', stdin = process.PIPE, stdout = process.PIPE, stderr = process.PIPE)
c.stdin.write("set optimizer = 'no_mitosis_pipe';\n")
c.stdin.write('explain\n')
for ln in open(os.path.join(TSTSRCDIR,"%s.sql" % os.environ['TST'][0:2])):
    c.stdin.write(ln)
out, err = c.communicate()
sys.stdout.write(out)
sys.stderr.write(err)
