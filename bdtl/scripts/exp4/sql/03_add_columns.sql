-- Experiment 4 | Step 3 : ALTER TABLE ... ADD COLUMNS (schema evolution)
USE exp4_db;

ALTER TABLE student_info ADD COLUMNS (
  email STRING COMMENT 'student e-mail id',
  city  STRING COMMENT 'home city');

DESCRIBE student_info;
-- existing rows show NULL for the new columns
SELECT * FROM student_info;
