-- Experiment 1 | Step 1 : create a database for this experiment
CREATE DATABASE IF NOT EXISTS exp1_db
COMMENT 'BDT Lab Experiment 1 - create and describe tables';

SHOW DATABASES;
DESCRIBE DATABASE exp1_db;

-- Experiment 1 | Step 2 : MANAGED (internal) tables in three file formats
USE exp1_db;

-- 2a. Managed table stored as TEXTFILE (comma-delimited)
CREATE TABLE IF NOT EXISTS emp_text (
  emp_id     INT,
  name       STRING,
  department STRING,
  salary     DOUBLE,
  city       STRING)
COMMENT 'Managed table - TEXTFILE'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

LOAD DATA LOCAL INPATH '${hivevar:datadir}/employees.csv' OVERWRITE INTO TABLE emp_text;

-- 2b. Managed table stored as ORC (columnar, compressed)
CREATE TABLE IF NOT EXISTS emp_orc (
  emp_id INT, name STRING, department STRING, salary DOUBLE, city STRING)
COMMENT 'Managed table - ORC'
STORED AS ORC;

INSERT OVERWRITE TABLE emp_orc SELECT * FROM emp_text;

-- 2c. Managed table stored as PARQUET (columnar)
CREATE TABLE IF NOT EXISTS emp_parquet (
  emp_id INT, name STRING, department STRING, salary DOUBLE, city STRING)
COMMENT 'Managed table - PARQUET'
STORED AS PARQUET;

INSERT OVERWRITE TABLE emp_parquet SELECT * FROM emp_text;
