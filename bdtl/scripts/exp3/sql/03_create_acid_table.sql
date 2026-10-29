-- Experiment 3 | Step 3 : create an ACID (transactional) table
SET hive.support.concurrency=true;
SET hive.txn.manager=org.apache.hadoop.hive.ql.lockmgr.DbTxnManager;
USE exp3_db;

-- ACID tables must be MANAGED, stored as ORC and have transactional=true
CREATE TABLE IF NOT EXISTS employee_acid (
  emp_id     INT,
  name       STRING,
  department STRING,
  salary     DOUBLE,
  city       STRING)
CLUSTERED BY (emp_id) INTO 2 BUCKETS
STORED AS ORC
TBLPROPERTIES ('transactional'='true');

SHOW TBLPROPERTIES employee_acid;

-- load it from the plain table
INSERT INTO TABLE employee_acid SELECT * FROM employee_plain;
SELECT * FROM employee_acid ORDER BY emp_id;
