-- Experiment 4 | Step 1 : create the starting table
CREATE DATABASE IF NOT EXISTS exp4_db;
USE exp4_db;

CREATE TABLE IF NOT EXISTS student (
  id    INT,
  name  STRING,
  marks INT)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

LOAD DATA LOCAL INPATH '${hivevar:datadir}/students.csv' OVERWRITE INTO TABLE student;

DESCRIBE student;
SELECT * FROM student;
