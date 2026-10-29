-- Experiment 3 | Step 5 : DELETE rows from the ACID table
SET hive.support.concurrency=true;
SET hive.txn.manager=org.apache.hadoop.hive.ql.lockmgr.DbTxnManager;
USE exp3_db;

DELETE FROM employee_acid WHERE emp_id = 106;
DELETE FROM employee_acid WHERE department = 'Marketing' OR salary < 40000;

SELECT * FROM employee_acid ORDER BY emp_id;
