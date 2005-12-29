import os
import string

TST = os.environ['TST']
TSTDB = os.environ['TSTDB']
MSERVER = os.environ['MSERVER'].replace('--trace','')
TSTSRCBASE = os.environ['TSTSRCBASE']

CALL = "pf -A %s.xq | %s --dbname=%s %s.prelude" % (os.path.join(TSTSRCBASE,'tests','XMark','Tests',TST),MSERVER,TSTDB,TST)

if os.name == "nt":
    os.system("call Mlog.bat '%s'" % CALL.replace('|','\\|'))
else:
    os.system("Mlog '%s'" % CALL.replace('|','\\|'))
os.system(CALL)
        