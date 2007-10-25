import os
import string

TST = os.environ['TST']
TSTDB = os.environ['TSTDB']
MSERVER = os.environ['MSERVER'].replace('--trace','')

CALL = 'pf -O0 "%s.xq" | %s --dbname=%s "--dbinit=module(pathfinder);"' % (TST,MSERVER,TSTDB)

if os.name == "nt":
    os.system('Mlog "%s"' % CALL)
else:
    os.system("Mlog '%s'" % CALL.replace('|','\\|'))
os.system(CALL)
