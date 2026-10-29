-- Experiment 4 | Step 4 : ALTER TABLE ... CHANGE (rename a column / change data type)
USE exp4_db;

-- change data type: INT -> BIGINT (a widening, compatible change)
ALTER TABLE student_info CHANGE marks marks BIGINT;

-- rename a column (name -> student_name), keeping its type
ALTER TABLE student_info CHANGE name student_name STRING COMMENT 'full name';

-- change data type: BIGINT -> DOUBLE
ALTER TABLE student_info CHANGE marks marks DOUBLE COMMENT 'marks out of 100';

DESCRIBE student_info;
SELECT * FROM student_info;
