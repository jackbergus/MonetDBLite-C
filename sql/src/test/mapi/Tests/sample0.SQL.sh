#!/bin/sh

PATH="`monetdb-clients-config --pkglibdir`/Tests:$PATH"
export PATH

Mlog -x "sample0 $HOST $MAPIPORT sql"
