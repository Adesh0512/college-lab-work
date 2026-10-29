-- Experiment 8 | Part 4 : JOIN - left, right and full outer joins
customers = LOAD '/bdt/exp8/customers.txt' USING PigStorage(',')
    AS (id:int, name:chararray, age:int, address:chararray, salary:double);
orders    = LOAD '/bdt/exp8/orders.txt' USING PigStorage(',')
    AS (oid:int, date:chararray, customer_id:int, amount:int);

outer_left  = JOIN customers BY id LEFT OUTER,  orders BY customer_id;
DUMP outer_left;

outer_right = JOIN customers BY id RIGHT OUTER, orders BY customer_id;
DUMP outer_right;

outer_full  = JOIN customers BY id FULL OUTER,  orders BY customer_id;
DUMP outer_full;
