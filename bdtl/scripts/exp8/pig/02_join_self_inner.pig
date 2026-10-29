-- Experiment 8 | Part 3 : JOIN - self join and inner (equi) join
customers1 = LOAD '/bdt/exp8/customers.txt' USING PigStorage(',')
    AS (id:int, name:chararray, age:int, address:chararray, salary:double);
customers2 = LOAD '/bdt/exp8/customers.txt' USING PigStorage(',')
    AS (id:int, name:chararray, age:int, address:chararray, salary:double);
orders     = LOAD '/bdt/exp8/orders.txt' USING PigStorage(',')
    AS (oid:int, date:chararray, customer_id:int, amount:int);

-- self join: the same data loaded under two aliases
customers3 = JOIN customers1 BY id, customers2 BY id;
DUMP customers3;

-- inner join: only customers that have orders
customer_orders = JOIN customers1 BY id, orders BY customer_id;
DESCRIBE customer_orders;
DUMP customer_orders;
