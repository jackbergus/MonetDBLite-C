#!/usr/bin/env python

# The contents of this file are subject to the MonetDB Public License
# Version 1.1 (the "License"); you may not use this file except in
# compliance with the License. You may obtain a copy of the License at
# http://www.monetdb.org/Legal/MonetDBLicense
#
# Software distributed under the License is distributed on an "AS IS"
# basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
# License for the specific language governing rights and limitations
# under the License.
#
# The Original Code is the MonetDB Database System.
#
# The Initial Developer of the Original Code is CWI.
# Portions created by CWI are Copyright (C) 1997-July 2008 CWI.
# Copyright August 2008-2013 MonetDB B.V.
# All Rights Reserved.

import monetdb.sql
import sys

dbh = monetdb.sql.Connection(port=int(sys.argv[1]),database=sys.argv[2],autocommit=True)

cursor = dbh.cursor();
cursor.execute('select 1;')
print(cursor.fetchall())

cursor = dbh.cursor();
cursor.execute('select 2;')
print(cursor.fetchone())

# deliberately executing a wrong SQL statement:
try:
    cursor.execute('( xyz 1);')
except monetdb.sql.OperationalError as e:
    print(e)

cursor.execute('create table python_table (i smallint,s string);');
cursor.execute('insert into python_table values ( 3, \'three\');');
cursor.execute('insert into python_table values ( 7, \'seven\');');
cursor.execute('select * from python_table;');
print(cursor.fetchall())

s = ((0, 'row1'), (1, 'row2'))
x = cursor.executemany("insert into python_table VALUES (%s, %s);", s)
print(x);

cursor.execute('drop table python_table;');
