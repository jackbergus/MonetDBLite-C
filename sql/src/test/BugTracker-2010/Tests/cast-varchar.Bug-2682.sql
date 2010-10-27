CREATE TABLE "sys"."sensor_readings" (
   "src_ip"    VARCHAR(15),
   "recv_time" TIMESTAMP,
   "emit_time" TIMESTAMP,
   "location"  VARCHAR(30),
   "type"      VARCHAR(30),
   "value"     VARCHAR(30)
);
COPY 20 RECORDS INTO "sensor_readings" FROM STDIN USING DELIMITERS ',','\n';
127.0.0.1,2010-08-25 14:56:12.000000,2010-07-15 13:56:10.000000,L318,temperature,27.56
127.0.0.1,2010-08-25 14:56:12.000000,2010-07-15 13:56:12.000000,L318,temperature,27.5
127.0.0.1,2010-08-25 14:56:12.000000,2010-07-15 13:56:13.000000,L318,temperature,27.56
127.0.0.1,2010-08-25 14:56:12.000000,2010-07-15 13:56:14.000000,L318,temperature,27.56
127.0.0.1,2010-08-25 14:56:12.000000,2010-07-15 13:56:15.000000,L318,temperature,27.5
127.0.0.1,2010-08-25 14:56:12.000000,2010-07-15 13:56:17.000000,L318,temperature,27.5
127.0.0.1,2010-08-25 14:56:12.000000,2010-07-15 13:56:18.000000,L318,temperature,27.5
127.0.0.1,2010-08-25 14:56:12.000000,2010-07-15 13:56:19.000000,L318,temperature,27.5
127.0.0.1,2010-08-25 14:56:12.000000,2010-07-15 13:56:20.000000,L318,temperature,27.5
127.0.0.1,2010-08-25 14:56:12.000000,2010-07-15 13:56:22.000000,L318,temperature,27.5
127.0.0.1,2010-08-25 14:56:12.000000,2010-07-15 13:56:23.000000,L318,temperature,27.5
127.0.0.1,2010-08-25 14:56:12.000000,2010-07-15 13:56:24.000000,L318,temperature,27.5
127.0.0.1,2010-08-25 14:56:12.000000,2010-07-15 13:56:25.000000,L318,temperature,27.5
127.0.0.1,2010-08-25 14:56:12.000000,2010-07-15 13:56:26.000000,L318,temperature,27.5
127.0.0.1,2010-08-25 14:56:12.000000,2010-07-15 13:56:28.000000,L318,temperature,27.5
127.0.0.1,2010-08-25 14:56:12.000000,2010-07-15 13:56:29.000000,L318,temperature,27.5
127.0.0.1,2010-08-25 14:56:12.000000,2010-07-15 13:56:30.000000,L318,temperature,27.5
127.0.0.1,2010-08-25 14:56:12.000000,2010-07-15 13:56:31.000000,L318,temperature,27.5
127.0.0.1,2010-08-25 14:56:12.000000,2010-07-15 13:56:33.000000,L318,temperature,27.5
127.0.0.1,2010-08-25 14:56:12.000000,2010-07-15 13:56:34.000000,L318,temperature,27.5

SELECT location,
       CAST(SUBSTRING(emit_time, 0, 16) AS VARCHAR(16)) AS "time",
       MAX(CAST(value AS NUMERIC(5,2))) AS maxtemp,
       MIN(CAST(value AS NUMERIC(5,2))) AS mintemp
FROM sensor_readings
WHERE type LIKE 'temperature'
  AND emit_time BETWEEN '2010-07-10' AND '2010-07-20'
GROUP BY location,
         "time" HAVING MAX(CAST(value AS NUMERIC(5,2))) - MIN(CAST(value AS NUMERIC(5,2))) > 0.05;

DROP TABLE "sys"."sensor_readings";
