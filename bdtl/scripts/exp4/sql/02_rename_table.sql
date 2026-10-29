-- Experiment 4 | Step 2 : ALTER TABLE ... RENAME TO
USE exp4_db;
SHOW TABLES;

ALTER TABLE student RENAME TO student_info;

SHOW TABLES;
SELECT * FROM student_info;
