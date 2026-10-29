-- Experiment 3 | Step 4 : UPDATE rows in the ACID table
SET hive.support.concurrency=true;
SET hive.txn.manager=org.apache.hadoop.hive.ql.lockmgr.DbTxnManager;
USE exp3_db;

-- 10% raise for the IT department
UPDATE employee_acid SET salary = salary * 1.10 WHERE department = 'IT';

-- an employee moved city
UPDATE employee_acid SET city = 'Pune' WHERE emp_id = 107;

SELECT * FROM employee_acid ORDER BY emp_id;
