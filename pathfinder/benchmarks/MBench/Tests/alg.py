import os
import string

TST = os.environ['TST']
TSTDB = os.environ['TSTDB']
MSERVER = os.environ['MSERVER'].replace('--trace','')
TSTSRCDIR = os.environ['TSTSRCDIR']

CALL = "pf -A %s.xq | %s --dbname=%s --dbinit=\"module(pathfinder);\"" % (TST,MSERVER,TSTDB)

if os.name == "nt":
    os.system("call Mlog.bat '%s'" % CALL.replace('|','\\|'))
else:
    os.system("Mlog '%s'" % CALL.replace('|','\\|'))
os.system(CALL)
        