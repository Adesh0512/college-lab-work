-- Experiment 1 | Step 3 : EXTERNAL tables in three file formats
-- (data lives at the LOCATION we give; Hive only keeps the metadata)
USE exp1_db;

-- 3a. External TEXTFILE table over a CSV already uploaded to HDFS
CREATE EXTERNAL TABLE IF NOT EXISTS emp_ext_text (
  emp_id INT, name STRING, department STRING, salary DOUBLE, city STRING)
COMMENT 'External table - TEXTFILE'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/bdt/exp1/ext_text';

-- 3b. External ORC table
CREATE EXTERNAL TABLE IF NOT EXISTS emp_ext_orc (
  emp_id INT, name STRING, department STRING, salary DOUBLE, city STRING)
COMMENT 'External table - ORC'
STORED AS ORC
LOCATION '/bdt/exp1/ext_orc';

INSERT OVERWRITE TABLE emp_ext_orc SELECT * FROM emp_ext_text;

-- 3c. External PARQUET table
CREATE EXTERNAL TABLE IF NOT EXISTS emp_ext_parquet (
  emp_id INT, name STRING, department STRING, salary DOUBLE, city STRING)
COMMENT 'External table - PARQUET'
STORED AS PARQUET
LOCATION '/bdt/exp1/ext_parquet';

INSERT OVERWRITE TABLE emp_ext_parquet SELECT * FROM emp_ext_text;
