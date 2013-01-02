#/usr/bin/env perl

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

use strict;
use warnings;

$|++;

use DBI();

my $dsn = "dbi:monetdb:database=$ARGV[1];host=localhost;port=$ARGV[0]";
my $dbh = DBI->connect(
    $dsn, 'monetdb', 'monetdb'
);

my $query = qq{
SELECT
    *
FROM
    functions
UNION ALL
SELECT
    *
FROM
    functions
UNION ALL
SELECT
    *
FROM
    functions
UNION ALL
SELECT
    *
FROM
    functions
UNION ALL
SELECT
    *
FROM
    functions
;
};

my $sth = $dbh->prepare($query);
$sth->execute;

# Here we tell DBI to fetch at most 1000 lines (out of ~5000 available)
my $r = $sth->fetchall_arrayref(undef, 1000);

# Print "200 rows" in my case, should print "1000 rows"
print scalar(@{$r}) . " rows\n";

$dbh->disconnect();

