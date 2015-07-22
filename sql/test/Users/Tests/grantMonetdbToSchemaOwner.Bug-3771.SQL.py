###
# Let a scheam owner inherit the rights of monetdb.
# Check that by assuming the monetdb role the user has complete privileges (e.g. select, create, drop).
###


from util import sql_test_client

sql_test_client('monetdb', 'monetdb', input = """\
CREATE USER owner with password 'ThisIsAS3m1S3cur3P4ssw0rd' name 'user gets monetdb rights' schema sys;

CREATE SCHEMA schemaForOwner AUTHORIZATION owner;

CREATE table schemaForOwner.testTable(v1 int, v2 int);

-- Grant delete rights.
GRANT monetdb to owner;

""")

sql_test_client('owner', 'ThisIsAS3m1S3cur3P4ssw0rd', input = """\
-- Check delete.
set schema schemaForOwner;
set role monetdb;

DROP TABLE testTable;
CREATE TABLE testTable(v1 INT);
ALTER TABLE testTable ADD COLUMN v2 INT;


SELECT * FROM testTable;
INSERT INTO testTable VALUES (3, 3);
UPDATE testTable SET v1 = 2 WHERE v2 = 7;
DELETE FROM testTable WHERE v1 = 2;
""")

