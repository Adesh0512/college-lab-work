-- Experiment 1 | Step 6 : full metadata of an EXTERNAL table (PARQUET)
-- Look for: Table Type = EXTERNAL_TABLE, EXTERNAL = TRUE, Location = /bdt/exp1/ext_parquet,
--           InputFormat / SerDe = Parquet
USE exp1_db;
DESCRIBE FORMATTED emp_ext_parquet;
