-- Experiment 1 | Step 5 : full metadata of a MANAGED table (ORC)
-- Look for: Table Type = MANAGED_TABLE, Location under /user/hive/warehouse,
--           InputFormat / SerDe = ORC
USE exp1_db;
DESCRIBE FORMATTED emp_orc;
