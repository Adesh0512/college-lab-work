-- Experiment 4 | Step 5 : ALTER TABLE ... REPLACE COLUMNS
-- REPLACE COLUMNS swaps the whole column list (here it removes email and city)
USE exp4_db;

ALTER TABLE student_info REPLACE COLUMNS (
  id           INT,
  student_name STRING,
  marks        DOUBLE);

DESCRIBE student_info;
SELECT * FROM student_info;
