-- Experiment 4 | Step 8 : MSCK REPAIR TABLE registers the partitions found in HDFS
USE exp4_db;

MSCK REPAIR TABLE sales;

SHOW PARTITIONS sales;
SELECT * FROM sales;
