#!/bin/sh

PATH="`monetdb-clients-config --pkglibdir`/Tests:$PATH"
export PATH

PYTHONPATH="`monetdb-config --pythonlibdir`:$PYTHONPATH"
PYTHONPATH="`monetdb-clients-config --pythonlibdir`:`monetdb-clients-config --pythonlibdir`/MonetDB:$PYTHONPATH"
PYTHONPATH="`monetdb-sql-config --pythonlibdir`:`monetdb-sql-config --pythonlibdir`/MonetDB:$PYTHONPATH"
export PYTHONPATH

if [ -n "$TST_FIVE" ] ; then
	v=5
	c=`monetdb$v-config --sysconfdir`/monetdb5.conf
else
	v=4
	c=`monetdb$v-config --sysconfdir`/MonetDB.conf
fi
PYTHONPATH="$TSTBLDBASE/src/backends/python/monet$v/:$PYTHONPATH"
PYTHONPATH="$TSTBLDBASE/src/backends/python/monet$v/.libs:$PYTHONPATH"
export PYTHONPATH
# make sure we find module sql[_server]
mv $c $c.BAK
sed -e "s|^monet_mod_path=.*$|monet_mod_path=$MONETDB_MOD_PATH|" $c.BAK > $c

Mlog -x "sqlsample.py $GDK_DBFARM $TSTDB $v"

# clean-up
mv -f $c.BAK $c
