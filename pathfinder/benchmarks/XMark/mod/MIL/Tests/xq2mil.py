import os
from MonetDBtesting import process

TSTSRCDIR = os.environ['TSTSRCDIR']
XQ = os.path.join('XQ','Tests')
MIL = os.path.join('MIL','Tests')

pf = process.pf(args = ['-M', '%s.xq' % os.path.join(TSTSRCDIR.replace(MIL,XQ),
                                                     'xmark')],
                stdout = open('xmark.mil', 'w'), log = True)
pf.communicate()
