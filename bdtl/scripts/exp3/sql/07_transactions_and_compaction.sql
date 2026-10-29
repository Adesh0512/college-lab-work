-- Experiment 3 | Step 7 : inspect transactions and compact the delta files
SET hive.support.concurrency=true;
SET hive.txn.manager=org.apache.hadoop.hive.ql.lockmgr.DbTxnManager;
USE exp3_db;

SHOW TRANSACTIONS;
ALTER TABLE employee_acid COMPACT 'major';
SHOW COMPACTIONS;
