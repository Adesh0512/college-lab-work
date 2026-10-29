-- Experiment 3 | Step 1 : enable the transaction (ACID) properties in Hive
SET hive.support.concurrency=true;
SET hive.txn.manager=org.apache.hadoop.hive.ql.lockmgr.DbTxnManager;
SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.compactor.initiator.on=true;
SET hive.compactor.worker.threads=1;

-- print the values now in effect
SET hive.support.concurrency;
SET hive.txn.manager;
SET hive.exec.dynamic.partition.mode;
SET hive.compactor.initiator.on;
SET hive.compactor.worker.threads;
