-- Experiment 8 | Part 6 : handwritten questions 1-3 executed on sample data
-- Q1: JOIN Student(RollNo, Name, DeptID) with Department(DeptID, DeptName)
students    = LOAD '/bdt/exp8/students.txt'    USING PigStorage(',') AS (rollno:int, name:chararray, deptid:chararray);
departments = LOAD '/bdt/exp8/departments.txt' USING PigStorage(',') AS (deptid:chararray, deptname:chararray);
stud_dept   = JOIN students BY deptid, departments BY deptid;
q1          = FOREACH stud_dept GENERATE students::rollno AS rollno, students::name AS name, departments::deptname AS deptname;
q1_sorted   = ORDER q1 BY rollno;
DUMP q1_sorted;

-- Q2: GROUP employees by department and total the salary of each department
employees = LOAD '/bdt/exp8/employees.txt' USING PigStorage(',') AS (empid:chararray, deptname:chararray, salary:int);
by_dept   = GROUP employees BY deptname;
q2        = FOREACH by_dept GENERATE group AS deptname, SUM(employees.salary) AS total_salary, COUNT(employees) AS employees;
DUMP q2;

-- Q3: FILTER employees with salary > 50000 and SORT by salary descending
high = FILTER employees BY salary > 50000;
q3   = ORDER high BY salary DESC;
DUMP q3;
