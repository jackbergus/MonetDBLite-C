#!/bin/sh

cat << EOF > .monetdb
user=monetdb
password=monetdb
EOF

LANG="en_US.UTF-8"
export LANG

Mlog -x "$MTIMEOUT java nl.cwi.monetdb.client.JdbcClient -h $HOST -p $MAPIPORT -d ${TSTDB} -e -f \"$TSTSRCBASE/$TSTDIR/bogus-auto-generated-keys.sql\""

rm -f .monetdb
