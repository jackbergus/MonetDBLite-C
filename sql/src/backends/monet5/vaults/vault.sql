-- The contents of this file are subject to the MonetDB Public License
-- Version 1.1 (the "License"); you may not use this file except in
-- compliance with the License. You may obtain a copy of the License at
-- http://monetdb.cwi.nl/Legal/MonetDBLicense-1.1.html
--
-- Software distributed under the License is distributed on an "AS IS"
-- basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
-- License for the specific language governing rights and limitations
-- under the License.
--
-- The Original Code is the MonetDB Database System.
--
-- The Initial Developer of the Original Code is CWI.
-- Copyright August 2008-2010 MonetDB B.V.
-- All Rights Reserved.

-- The data vault interface for SQL

CREATE SEQUENCE sys.vaultid AS int;

CREATE TABLE sys.vault (
vid             int PRIMARY KEY,-- Internal key
kind            string,         -- vault kind (CSV, MSEED, FITS,..)
source          string,         -- remote file name for cURL to access
target          string,         -- file name of source file in vault
created         timestamp,      -- timestamp upon entering the cache
lru             timestamp       -- least recently used
);

create function getvault()
returns string
external name vault.getdirectory;

create function basename(fnme string, split string)
returns string
external name vault.basename;

create function import(source string, target string)
returns string
external name vault.import;
