CREATE TABLE gp (id INT, rest varchar(100));
COMMIT;

-- create a general grant
GRANT SELECT ON gp TO PUBLIC;
GRANT INSERT ON gp TO PUBLIC;
GRANT UPDATE(id) ON gp TO PUBLIC;
COMMIT;

REVOKE INSERT ON gp FROM PUBLIC;
REVOKE UPDATE(id) ON gp FROM PUBLIC;
REVOKE SELECT ON gp FROM PUBLIC;
COMMIT;

-- failure situations
ROLLBACK;
GRANT SELECT ON gp TO PUBLIC;
GRANT INSERT ON gp TO PUBLIC;
GRANT UPDATE(id) ON gp TO PUBLIC;
COMMIT;
GRANT UPDATE(dumdum) ON gp TO PUBLIC;
ROLLBACK;

GRANT INSERT ON gp TO PUBLIC;
GRANT INSERT ON gp TO PUBLIC;
GRANT INSERT ON gp TO PUBLIC;
ROLLBACK;
REVOKE SELECT ON gp TO PUBLIC;
REVOKE SELECT ON gp TO PUBLIC;
ROLLBACK;

DROP TABLE gp;
COMMIT;
