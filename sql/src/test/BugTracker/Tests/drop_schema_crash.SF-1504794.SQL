#!/bin/bash

cat << EOF > .monetdb
user=monetdb
password=monetdb
EOF

LANG="en_US.UTF-8"
export LANG

Mlog   "$MTIMEOUT mjclient -h $HOST -p $MAPIPORT -d ${TSTDB} -f $RELSRCDIR/drop_schema_crash.SF-1504794-data.sql"
	$MTIMEOUT mjclient -h $HOST -p $MAPIPORT -d ${TSTDB} -f $RELSRCDIR/drop_schema_crash.SF-1504794-data.sql
