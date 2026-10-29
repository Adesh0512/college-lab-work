-- Experiment 1 | Step 4 : verify the tables with SHOW TABLES and DESCRIBE
USE exp1_db;

SHOW TABLES;
SHOW TABLES LIKE 'emp_ext*';

DESCRIBE emp_text;
DESCRIBE emp_orc;
DESCRIBE emp_ext_parquet;
