

import monetdb.sql
import os, sys, time

port = int(os.environ['MAPIPORT'])
db = os.environ['TSTDB']

dbh = monetdb.sql.Connection(port=port,database=db,autocommit=True)

cursor = dbh.cursor();

cursor.execute('select p.*, "location", "count" from storage(), (select value from env() where name = \'gdk_dbpath\') as p where "table"=\'lineitem\';');
res = (cursor.fetchall())
for (dbpath, fn, count) in res:
    fn =  os.path.join(dbpath, 'bat', fn + '.tail');
    print(fn, os.path.getsize(fn) , count)

