@echo off

call monetdb-clients-config --internal

# must be aligned with the installation directory chosen in
# clients/src/python/test/Makefile.ag
set testpath=%pkglibdir%\Tests
set PYTHONPATH=%testpath%;%PYTHONPATH%

prompt # $t $g  
echo on

python %testpath%/test_monetdb_sql_dbapi20.py
