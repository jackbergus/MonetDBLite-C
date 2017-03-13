CREATE TABLE test101(
  A INT NOT NULL PRIMARY KEY,
  B INT NOT NULL,
  C INT NOT NULL,
  CONSTRAINT "fC" FOREIGN KEY (C) REFERENCES test101(A)
);

INSERT INTO test101 VALUES (101, 101, 101);
-- INSERT INTO: FOREIGN KEY constraint 'test101.fC' violated


ALTER TABLE test101 ALTER C SET NULL;

INSERT INTO test101 VALUES (100, 100, NULL);

INSERT INTO test101 VALUES (102, 102, 102);
-- INSERT INTO: FOREIGN KEY constraint 'test101.fC' violated

INSERT INTO test101 VALUES (103, 103, 101);

UPDATE test101 SET C = 100 WHERE C IS NULL;

select * from test101;


ALTER TABLE test101 ALTER C SET NOT NULL;

INSERT INTO test101 VALUES (104, 104, 104);
-- INSERT INTO: FOREIGN KEY constraint 'test101.fC' violated
 
DROP TABLE test101;

