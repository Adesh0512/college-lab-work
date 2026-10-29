-- Experiment 1 | Step 7 : the same data can be read from every format
USE exp1_db;

SELECT * FROM emp_text;
SELECT * FROM emp_orc WHERE department = 'IT';
SELECT * FROM emp_ext_parquet WHERE salary > 55000;
SELECT department, COUNT(*) AS employees, AVG(salary) AS avg_salary
FROM emp_ext_orc GROUP BY department;
