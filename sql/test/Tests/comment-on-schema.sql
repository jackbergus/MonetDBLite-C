DROP SCHEMA IF EXISTS sch;
CREATE SCHEMA sch;
SET SCHEMA sch;

CREATE TABLE origs AS SELECT id FROM sys.comments;

CREATE FUNCTION all_kinds_of_object()
RETURNS TABLE (id INTEGER, name VARCHAR(80), type VARCHAR(30))
RETURN TABLE (
        SELECT id, name, table_type_name
        FROM sys.tables, sys.table_types
        WHERE type = table_type_id
        UNION ALL
        SELECT id, name, 'SCHEMA'
        FROM sys.schemas
        UNION ALL
        SELECT c.id, t.name || '.' || c.name, 'COLUMN'
        FROM sys.columns AS c, sys.tables AS t
        WHERE c.table_id = t.id
        UNION ALL
        SELECT id, name, 'INDEX'
        FROM sys.idxs
        UNION ALL
        SELECT id, name, 'SEQUENCE'
        FROM sys.sequences
        UNION ALL
        SELECT id, name, function_type_name
        FROM sys.functions, sys.function_types
        WHERE type = function_type_id
);

CREATE FUNCTION new_comments()
RETURNS TABLE (name VARCHAR(80), source VARCHAR(30), remark CLOB)
RETURN TABLE (
        SELECT o.name, o.type, c.remark
        FROM sys.comments AS c LEFT JOIN all_kinds_of_object() AS o ON c.id = o.id
        WHERE c.id NOT IN (SELECT id FROM origs)
);

------------------------------------------------------------------------

-- create a schema and comment on it
CREATE SCHEMA sch2;
COMMENT ON SCHEMA sch2 IS 'yet another schema';
SELECT * FROM new_comments();

-- drop it by dropping the table
COMMENT ON SCHEMA sch2 IS 'banana';
DROP SCHEMA sch2;
SELECT * FROM new_comments();
