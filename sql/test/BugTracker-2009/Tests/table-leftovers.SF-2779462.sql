start transaction;

set optimizer='optimizer.inline();optimizer.remap();optimizer.evaluate();optimizer.costModel();optimizer.coercions();optimizer.emptySet();optimizer.aliases();optimizer.mergetable();optimizer.deadcode();optimizer.constants();optimizer.commonTerms();optimizer.reorder();optimizer.joinPath();optimizer.deadcode();optimizer.recycle();optimizer.reduce();optimizer.dataflow();optimizer.history();optimizer.multiplex();optimizer.garbageCollector();';

CREATE TABLE y (x int);
INSERT INTO y VALUES (10);
SELECT * FROM y;

rollback;


start transaction;

CREATE TABLE y (x int);
INSERT INTO y VALUES (13);
SELECT * FROM y;

rollback;
