-- Experiment 3 | Step 2 : a normal (non-transactional) table CANNOT be updated
CREATE DATABASE IF NOT EXISTS exp3_db;
USE exp3_db;

CREATE TABLE IF NOT EXISTS employee_plain (
  emp_id INT, name STRING, department STRING, salary DOUBLE, city STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

LOAD DATA LOCAL INPATH '${hivevar:datadir}/employees.csv' OVERWRITE INTO TABLE employee_plain;
SELECT * FROM employee_plain;

-- expected to FAIL with Error 10297 (table is not transactional)
UPDATE employee_plain SET salary = 50000 WHERE emp_id = 102;
