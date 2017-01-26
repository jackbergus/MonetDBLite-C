-- check all standard sys (and tmp) tables on Referential integrity
-- All queries should return NO rows (so no invalid references found).
SELECT * FROM sys.schemas WHERE authorization NOT IN (SELECT id FROM sys.auths);
SELECT * FROM sys.schemas WHERE owner NOT IN (SELECT id FROM sys.auths);

SELECT * FROM sys.tables WHERE schema_id NOT IN (SELECT id FROM sys.schemas);
SELECT * FROM sys._tables WHERE schema_id NOT IN (SELECT id FROM sys.schemas);
SELECT * FROM tmp._tables WHERE schema_id NOT IN (SELECT id FROM sys.schemas);
SELECT * FROM sys.tables WHERE type NOT IN (SELECT table_type_id FROM sys.table_types);
SELECT * FROM sys._tables WHERE type NOT IN (SELECT table_type_id FROM sys.table_types);
SELECT * FROM tmp._tables WHERE type NOT IN (SELECT table_type_id FROM sys.table_types);

SELECT * FROM sys.columns WHERE table_id NOT IN (SELECT id FROM sys.tables);
SELECT * FROM sys._columns WHERE table_id NOT IN (SELECT id FROM sys._tables);
SELECT * FROM tmp._columns WHERE table_id NOT IN (SELECT id FROM tmp._tables);
SELECT * FROM sys.columns WHERE type NOT IN (SELECT sqlname FROM sys.types);
SELECT * FROM sys._columns WHERE type NOT IN (SELECT sqlname FROM sys.types);
SELECT * FROM sys._columns WHERE type NOT IN (SELECT sqlname FROM sys.types);

SELECT * FROM sys.functions WHERE schema_id NOT IN (SELECT id FROM sys.schemas);
-- SELECT * FROM sys.functions WHERE type NOT IN (SELECT id FROM sys.function_types);  -- table sys.function_types added in default
SELECT * FROM sys.functions WHERE type NOT IN (1,2,3,4,5,6,7);  -- replace this check when table sys.function_types becomes available
-- SELECT * FROM sys.functions WHERE language NOT IN (SELECT language_id FROM sys.function_languages);  -- table sys.function_languages added in default
SELECT * FROM sys.functions WHERE language NOT IN (0,1,2,3,4,5,6,7);  -- replace this check when table sys.function_languages becomes available

SELECT * FROM sys.systemfunctions WHERE function_id NOT IN (SELECT id FROM sys.functions);
-- systemfunctions should refer only to functions in MonetDB system schemas (on Dec2016 these are: sys, json, profiler and bam)
SELECT * FROM sys.systemfunctions WHERE function_id NOT IN (SELECT id FROM sys.functions WHERE schema_id IN (SELECT id FROM sys.schemas WHERE name IN ('sys','json','profiler','bam')));

SELECT * FROM sys.args WHERE func_id NOT IN (SELECT id FROM sys.functions);
SELECT * FROM sys.args WHERE type NOT IN (SELECT sqlname FROM sys.types);

SELECT * FROM sys.types WHERE schema_id NOT IN (SELECT id FROM sys.schemas);
SELECT * FROM sys.types WHERE schema_id NOT IN (SELECT id FROM sys.schemas) AND schema_id <> 0;

SELECT * FROM sys.keys WHERE table_id NOT IN (SELECT id FROM sys.tables);
SELECT * FROM sys.keys WHERE table_id NOT IN (SELECT id FROM sys._tables);
SELECT * FROM tmp.keys WHERE table_id NOT IN (SELECT id FROM tmp._tables);
-- SELECT * FROM sys.keys WHERE type NOT IN (SELECT key_type_id FROM sys.key_types);  -- table sys.key_types added in default
-- SELECT * FROM tmp.keys WHERE type NOT IN (SELECT key_type_id FROM sys.key_types);  -- table sys.key_types added in default
SELECT * FROM sys.keys WHERE type NOT IN (0, 1, 2);  -- replace this check when table sys.key_types becomes available
SELECT * FROM tmp.keys WHERE type NOT IN (0, 1, 2);  -- replace this check when table sys.key_types becomes available

SELECT * FROM sys.idxs WHERE table_id NOT IN (SELECT id FROM sys.tables);
SELECT * FROM sys.idxs WHERE table_id NOT IN (SELECT id FROM sys._tables);
SELECT * FROM tmp.idxs WHERE table_id NOT IN (SELECT id FROM tmp._tables);
-- SELECT * FROM sys.idxs WHERE type NOT IN (SELECT index_type_id FROM sys.index_types);  -- table sys.index_types added in default
-- SELECT * FROM tmp.idxs WHERE type NOT IN (SELECT index_type_id FROM sys.index_types);  -- table sys.index_types added in default
SELECT * FROM sys.idxs WHERE type NOT IN (0, 1, 2);  -- replace this check when table sys.index_types becomes available
SELECT * FROM tmp.idxs WHERE type NOT IN (0, 1, 2);  -- replace this check when table sys.index_types becomes available

SELECT * FROM sys.sequences WHERE schema_id NOT IN (SELECT id FROM sys.schemas);

SELECT * FROM sys.triggers WHERE table_id NOT IN (SELECT id FROM sys.tables);
SELECT * FROM sys.triggers WHERE table_id NOT IN (SELECT id FROM sys._tables);
SELECT * FROM tmp.triggers WHERE table_id NOT IN (SELECT id FROM tmp._tables);

SELECT * FROM sys.dependencies WHERE depend_type NOT IN (SELECT dependency_type_id FROM sys.dependency_types);

-- to view the used depend_types run: SELECT depend_type, COUNT(*) AS count FROM sys.dependencies GROUP BY depend_type ORDER BY depend_type;
-- Key dependency on columns
SELECT * FROM sys.dependencies WHERE depend_type = 4 and id NOT IN (SELECT id FROM sys.columns);
SELECT * FROM sys.dependencies WHERE depend_type = 4 and depend_id NOT IN (SELECT id FROM sys.keys WHERE type IN (0,1));
-- View dependency on tables (incl other views)
-- SELECT * FROM sys.dependencies WHERE depend_type = 5 and id NOT IN (SELECT id FROM sys.tables);  -- TODO: refine check as it lists 7 rows
SELECT * FROM sys.dependencies WHERE depend_type = 5 and depend_id NOT IN (SELECT id FROM sys.tables);
-- Function dependency on columns (from views)
--SELECT * FROM sys.dependencies WHERE depend_type = 7 and id NOT IN (SELECT id FROM sys.columns);  -- TODO: refine check as it lists 57 rows
SELECT * FROM sys.dependencies WHERE depend_type = 7 and depend_id NOT IN (SELECT id FROM sys.functions);
-- Index dependency on columns
SELECT * FROM sys.dependencies WHERE depend_type = 10 and id NOT IN (SELECT id FROM sys.columns);
SELECT * FROM sys.dependencies WHERE depend_type = 10 and depend_id NOT IN (SELECT id FROM sys.idxs);
-- FKey dependency on columns
--SELECT * FROM sys.dependencies WHERE depend_type = 11 and id NOT IN (SELECT id FROM sys.columns);  -- TODO: refine check as it lists 3 rows
SELECT * FROM sys.dependencies WHERE depend_type = 11 and depend_id NOT IN (SELECT id FROM sys.keys WHERE type IN (2));
-- Procedure dependency on columns (from views)
--SELECT * FROM sys.dependencies WHERE depend_type = 13 and id NOT IN (SELECT id FROM sys.columns);  -- TODO: refine check as it lists 5 rows
SELECT * FROM sys.dependencies WHERE depend_type = 13 and depend_id NOT IN (SELECT id FROM sys.functions);
-- Type dependency on columns
--SELECT * FROM sys.dependencies WHERE depend_type = 15 and id NOT IN (SELECT id FROM sys.columns);  -- TODO: change check as it lists all 46 rows
--SELECT * FROM sys.dependencies WHERE depend_type = 15 and depend_id NOT IN (SELECT id FROM sys.types);  -- TODO: change check as it lists all 46 rows

SELECT * FROM sys.auths WHERE grantor NOT IN (SELECT id FROM sys.auths) AND grantor > 0;
SELECT * FROM sys.users WHERE default_schema NOT IN (SELECT id FROM sys.schemas);
SELECT * FROM sys.db_user_info WHERE default_schema NOT IN (SELECT id FROM sys.schemas);

--SELECT * FROM sys.user_role WHERE login_id NOT IN (SELECT name FROM sys.users);  -- how is user_role.login_id connected to users.name? They have different data types/domains
SELECT * FROM sys.user_role WHERE role_id NOT IN (SELECT id FROM sys.auths);
SELECT * FROM sys.privileges WHERE auth_id NOT IN (SELECT id FROM sys.auths);
SELECT * FROM sys.privileges WHERE grantor NOT IN (SELECT id FROM sys.auths) AND grantor > 0;
-- SELECT * FROM sys.privileges WHERE privileges NOT IN (SELECT privilege_code_id FROM sys.privilege_codes); -- 1 and 16 -- table sys.privilege_codes added in default
SELECT * FROM sys.privileges WHERE privileges NOT IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,32); -- replace this check when table sys.privilege_codes becomes available

SELECT * FROM sys.querylog_catalog WHERE owner NOT IN (SELECT name FROM sys.users);
SELECT * FROM sys.querylog_calls WHERE id NOT IN (SELECT id FROM sys.querylog_catalog);
SELECT * FROM sys.querylog_history WHERE id NOT IN (SELECT id FROM sys.querylog_catalog);

SELECT * FROM sys.queue WHERE tag > 0 AND tag NOT IN (SELECT qtag FROM sys.queue);
SELECT * FROM sys.queue WHERE "user" NOT IN (SELECT name FROM sys.users);

SELECT * FROM sys.sessions WHERE "user" NOT IN (SELECT name FROM sys.users);

SELECT * FROM sys.statistics WHERE column_id NOT IN (SELECT id FROM sys._columns);
SELECT * FROM sys.statistics WHERE type NOT IN (SELECT sqlname FROM sys.types);

SELECT * FROM sys.storage WHERE schema NOT IN (SELECT name FROM sys.schemas);
SELECT * FROM sys.storage WHERE table NOT IN (SELECT name FROM sys._tables);
SELECT * FROM sys.storage WHERE column NOT IN (SELECT name FROM sys._columns UNION ALL SELECT name FROM sys.keys);
SELECT * FROM sys.storage WHERE type NOT IN (SELECT sqlname FROM sys.types);

SELECT * FROM sys.storagemodel WHERE schema NOT IN (SELECT name FROM sys.schemas);
SELECT * FROM sys.storagemodel WHERE table NOT IN (SELECT name FROM sys._tables);
SELECT * FROM sys.storagemodel WHERE column NOT IN (SELECT name FROM sys._columns UNION ALL SELECT name FROM sys.keys);
SELECT * FROM sys.storagemodel WHERE type NOT IN (SELECT sqlname FROM sys.types);

SELECT * FROM sys.storagemodelinput WHERE schema NOT IN (SELECT name FROM sys.schemas);
SELECT * FROM sys.storagemodelinput WHERE table NOT IN (SELECT name FROM sys._tables);
SELECT * FROM sys.storagemodelinput WHERE column NOT IN (SELECT name FROM sys._columns UNION ALL SELECT name FROM sys.keys);
SELECT * FROM sys.storagemodelinput WHERE type NOT IN (SELECT sqlname FROM sys.types);

SELECT * FROM sys.tablestoragemodel WHERE schema NOT IN (SELECT name FROM sys.schemas);
SELECT * FROM sys.tablestoragemodel WHERE table NOT IN (SELECT name FROM sys._tables);

