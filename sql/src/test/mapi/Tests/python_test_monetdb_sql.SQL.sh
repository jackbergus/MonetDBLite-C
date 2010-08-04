#!/bin/sh

# must be aligned with the installation directory chosen in
# clients/src/python/test/Makefile.ag
testpath="$TSTSRCBASE/../python/test"
PYTHONPATH=$testpath:$PYTHONPATH
export PYTHONPATH

Mlog -x "python $testpath/runtests.py"
