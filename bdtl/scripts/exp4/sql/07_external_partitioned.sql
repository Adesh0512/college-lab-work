-- Experiment 4 | Step 7 : EXTERNAL partitioned table over existing HDFS folders
USE exp4_db;

CREATE EXTERNAL TABLE IF NOT EXISTS sales (
  id      INT,
  product STRING,
  amount  DOUBLE)
PARTITIONED BY (year INT)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/bdt/exp4/sales';

-- the folders year=2023 and year=2024 exist in HDFS, but the metastore does not know them yet
SHOW PARTITIONS sales;
SELECT COUNT(*) AS rows_visible FROM sales;
