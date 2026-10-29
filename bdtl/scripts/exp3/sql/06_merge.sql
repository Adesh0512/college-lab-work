-- Experiment 3 | Step 6 : MERGE (upsert) changes from a staging table
SET hive.support.concurrency=true;
SET hive.txn.manager=org.apache.hadoop.hive.ql.lockmgr.DbTxnManager;
USE exp3_db;

-- staging table with the day's changes: U = update, D = delete, I = insert
CREATE TABLE IF NOT EXISTS employee_updates (
  emp_id INT, name STRING, department STRING, salary DOUBLE, city STRING, action STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

LOAD DATA LOCAL INPATH '${hivevar:datadir}/employee_updates.csv' OVERWRITE INTO TABLE employee_updates;
SELECT * FROM employee_updates;

MERGE INTO employee_acid AS t
USING employee_updates AS s
ON t.emp_id = s.emp_id
WHEN MATCHED AND s.action = 'D' THEN DELETE
WHEN MATCHED THEN UPDATE SET salary = s.salary, city = s.city
WHEN NOT MATCHED AND s.action = 'I' THEN INSERT VALUES (s.emp_id, s.name, s.department, s.salary, s.city);

SELECT * FROM employee_acid ORDER BY emp_id;
