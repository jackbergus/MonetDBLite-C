-- sample application based on partitions
CREATE TABLE day1 ( clk timestamp, currency string, ts timestamp, bid decimal(12,6), offer decimal(12,6), spread decimal(12,6) );
CREATE TABLE day1stage ( clk bigint, currency string, ts bigint, bid decimal(12,6), offer decimal(12,6), spread decimal(12,6) );

COPY 10 RECORDS INTO day1stage FROM STDIN USING DELIMITERS '|','\n';
1413267171000|EUR/USD|1413267158643|1.271810|1.271890|0.000080
1413267171000|USD/JPY|1413267171225|107.121000|107.127000|0.006000
1413267171000|GBP/USD|1413267161304|1.606820|1.606930|0.000110
1413267171000|EUR/GBP|1413267150417|0.791460|0.791570|0.000110
1413267171000|USD/CHF|1413267158643|0.950420|0.950550|0.000130
1413267171000|EUR/JPY|1413267171318|136.240000|136.253000|0.013000
1413267171000|EUR/CHF|1413267158643|1.208760|1.208950|0.000190
1413267171000|USD/CAD|1413267171318|1.121180|1.121270|0.000090
1413267171000|AUD/USD|1413267162803|0.878680|0.878780|0.000100
1413267171000|GBP/JPY|1413267171239|172.126000|172.146000|0.020000

SELECT * FROM day1stage;

INSERT INTO day1
SELECT epoch(clk), currency, epoch(ts), bid, offer,spread 
FROM day1stage;

DROP TABLE day1stage;

SELECT * from day1;
ALTER TABLE day1 SET READ ONLY;

CREATE TABLE day2 ( clk timestamp, currency string, ts timestamp, bid decimal(12,6), offer decimal(12,6), spread decimal(12,6) );
CREATE TABLE day2stage ( clk bigint, currency string, ts bigint, bid decimal(12,6), offer decimal(12,6), spread decimal(12,6) );

COPY 10 RECORDS INTO day2stage FROM STDIN USING DELIMITERS '|','\n';
1413267176000|EUR/USD|1413267177168|1.271780|1.271880|0.000100
1413267176000|USD/JPY|1413267177168|107.120000|107.125000|0.005000
1413267176000|GBP/USD|1413267175356|1.606820|1.606950|0.000130
1413267176000|EUR/GBP|1413267175336|0.791440|0.791550|0.000110
1413267176000|USD/CHF|1413267175367|0.950430|0.950560|0.000130
1413267176000|EUR/JPY|1413267177033|136.235000|136.248000|0.013000
1413267176000|EUR/CHF|1413267158643|1.208760|1.208950|0.000190
1413267176000|USD/CAD|1413267173063|1.121150|1.121260|0.000110
1413267176000|AUD/USD|1413267176076|0.878680|0.878760|0.000080
1413267176000|GBP/JPY|1413267176950|172.122000|172.142000|0.020000

INSERT INTO day2
SELECT epoch(clk), currency, epoch(ts), bid, offer,spread 
FROM day2stage;
DROP TABLE day2stage;

SELECT * from day2;
ALTER TABLE day2 SET READ ONLY;

CREATE TABLE day3 ( clk timestamp, currency string, ts timestamp, bid decimal(12,6), offer decimal(12,6), spread decimal(12,6) );

-- update the last part
INSERT INTO day3 VALUES( epoch(1413267181000), 'EUR/USD', epoch(1413267182327), 1.271910, 1.271990, 0.000080);
INSERT INTO day3 VALUES( epoch(1413267181000), 'USD/JPY', epoch(1413267181647), 107.114000,107.121000,0.007000);
INSERT INTO day3 VALUES( epoch(1413267181000), 'GBP/USD', epoch(1413267182048), 1.606870, 1.606980, 0.000110);
INSERT INTO day3 VALUES( epoch(1413267181000), 'EUR/GBP', epoch(1413267181968), 0.791490, 0.791600, 0.000110);
INSERT INTO day3 VALUES( epoch(1413267181000), 'USD/CHF', epoch(1413267182041), 0.950350, 0.950460, 0.000110);
INSERT INTO day3 VALUES( epoch(1413267181000), 'EUR/JPY', epoch(1413267182406), 136.241000,136.253000,0.012000);
INSERT INTO day3 VALUES( epoch(1413267181000), 'EUR/CHF', epoch(1413267181950), 1.208770, 1.208950, 0.000180);
INSERT INTO day3 VALUES( epoch(1413267181000), 'USD/CAD', epoch(1413267181830), 1.121120, 1.121230, 0.000110);
INSERT INTO day3 VALUES( epoch(1413267181000), 'AUD/USD', epoch(1413267181549), 0.878730, 0.878810, 0.000080);
INSERT INTO day3 VALUES( epoch(1413267181000), 'GBP/JPY', epoch(1413267181618), 172.116000,172.138000,0.022000);

SELECT * from day3;
ALTER TABLE day3 SET READ ONLY;

CREATE MERGE TABLE forex ( clk timestamp, currency string, ts timestamp, bid decimal(12,6), offer decimal(12,6), spread decimal(12,6) );
ALTER TABLE forex ADD TABLE day1;
ALTER TABLE forex ADD TABLE day2;
ALTER TABLE forex ADD TABLE day3;

SELECT * FROM forex WHERE currency = 'EUR/USD';
-- perform some compound queries
SELECT avg(bid), sum(bid) FROM forex;
SELECT currency, cast(avg(bid) AS DECIMAL(12,6)), sum(bid) FROM forex GROUP BY currency;

-- drop the first day
ALTER TABLE forex DROP TABLE day1;

SELECT * FROM forex WHERE currency = 'EUR/USD';

DROP TABLE forex;
DROP TABLE day1;
DROP TABLE day2;
DROP TABLE day3;
