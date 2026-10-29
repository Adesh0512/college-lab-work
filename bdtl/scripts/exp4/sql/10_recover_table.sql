-- Experiment 4 | Step 10 : RECOVER the dropped table: re-create the definition,
-- then MSCK REPAIR TABLE re-attaches every partition still in HDFS
-- (including year=2025, which was added directly to HDFS after the drop)
USE exp4_db;

CREATE EXTERNAL TABLE IF NOT EXISTS sales (
  id      INT,
  product STRING,
  amount  DOUBLE)
PARTITIONED BY (year INT)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/bdt/exp4/sales';

SHOW PARTITIONS sales;
MSCK REPAIR TABLE sales;
SHOW PARTITIONS sales;

SELECT * FROM sales;
SELECT year, COUNT(*) AS orders, SUM(amount) AS revenue FROM sales GROUP BY year;
