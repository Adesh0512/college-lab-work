-- Experiment 8 | Part 2 : GROUP operator
student_details = LOAD '/bdt/exp8/student_details.txt' USING PigStorage(',')
    AS (id:int, firstname:chararray, lastname:chararray, age:int, phone:chararray, city:chararray);

-- group by one column
group_data = GROUP student_details BY age;
DESCRIBE group_data;
DUMP group_data;

-- group by multiple columns
group_multiple = GROUP student_details BY (age, city);
DUMP group_multiple;

-- aggregate on the groups: number of students of each age
age_count = FOREACH group_data GENERATE group AS age, COUNT(student_details) AS students;
DUMP age_count;

-- group all records into a single group
group_all = GROUP student_details ALL;
DUMP group_all;
