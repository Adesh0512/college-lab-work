-- Experiment 8 | Part 5 : FILTER and ORDER BY (sort)
student_details = LOAD '/bdt/exp8/student_details.txt' USING PigStorage(',')
    AS (id:int, firstname:chararray, lastname:chararray, age:int, phone:chararray, city:chararray);

-- students who belong to Chennai
filter_data = FILTER student_details BY city == 'Chennai';
DUMP filter_data;

-- sort all students by age (descending), then by first name
order_by_data = ORDER student_details BY age DESC, firstname ASC;
DUMP order_by_data;

-- filter + sort + limit together: the 3 youngest students older than 21
older   = FILTER student_details BY age > 21;
by_age  = ORDER older BY age ASC, id ASC;
top3    = LIMIT by_age 3;
DUMP top3;
