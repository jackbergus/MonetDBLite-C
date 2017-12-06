DROP SCHEMA IF EXISTS foo;
CREATE SCHEMA foo;
SET SCHEMA foo;

/* initially, no comments visible */
\dn
\dn foo

/* comment can be set */
COMMENT ON SCHEMA foo IS 'foo foo';
\dn
\dn foo

/* comment can be changed */
COMMENT ON SCHEMA foo IS 'bar bar';
\dn
\dn foo

/* comment can be deleted by setting to null */
COMMENT ON SCHEMA foo IS NULL;
\dn
\dn foo

/* comment can be restored */
COMMENT ON SCHEMA foo IS 'foo bar';
\dn
\dn foo

/* comment can also be deleted by setting to '' */
COMMENT ON SCHEMA foo IS '';
\dn
\dn foo

/* leave the comment set so we can test msqldump */
COMMENT ON SCHEMA foo IS 'one final comment';

/* finally, awkward names work as well */
CREATE SCHEMA "space separated";
COMMENT ON SCHEMA "space separated" IS 'space separated';
\dn
\dn "space separated"
DROP SCHEMA "space separated";

/* TABLES */

\d

/* initially, no comment */
CREATE TABLE tab(i INT, j DECIMAL(4,2));
\d

/* comments show both in the table list and the description */
COMMENT ON TABLE tab IS 'table';
\d
\d tab

/* qualified tables also work */
COMMENT ON TABLE foo.tab IS 'qualified table';
\d
\d tab

/* even when referring to another schema */
SET SCHEMA sys;
COMMENT ON TABLE foo.tab IS 'table';
SET SCHEMA foo;
\d
\d tab

/* views show both in the table list and in the description */
CREATE VIEW vivi AS SELECT * FROM tab;
COMMENT ON VIEW vivi IS 'phew';
\dv
\d vivi

/* comment on table does not work on views and vice versa */
COMMENT ON VIEW tab IS '';
COMMENT ON TABLE vivi IS '';
\d

/* cannot comment on temporary table */
CREATE TEMPORARY TABLE tempo(LIKE foo.tab);
COMMENT ON TABLE tempo IS 'temporary';
COMMENT ON TABLE tmp.tempo IS 'temporary';

/* commenting on columns works both with and without schema. */
/* also, column comments are listed in table order, not addition order */
COMMENT ON COLUMN tab.j IS 'jj';
COMMENT ON COLUMN foo.tab.i IS 'ii';
\d tab

/* comment on index works */
CREATE INDEX idx ON tab(j,i);
COMMENT ON INDEX idx IS 'index on j';
\d tab

/* comment on sequence works */
CREATE SEQUENCE counter AS INT;
\ds
COMMENT ON SEQUENCE counter IS 'counting';
\ds
\ds counter

/* comment on schema.sequence also works */
SET SCHEMA sys;
COMMENT ON SEQUENCE foo.counter IS 'still counting';
SET SCHEMA foo;
\ds

