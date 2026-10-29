#!/usr/bin/env bash
# BDT Lab - Experiment 8 : JOIN, GROUP, SORT and FILTER in Apache Pig   (6 screenshots, more if output is long)
# Usage (inside Ubuntu):  bash ~/bdt/exp8/run_exp8.sh      restart at part N:  bash ~/bdt/exp8/run_exp8.sh N
cd "$(dirname "$0")"; source ../common/lib.sh; source ~/.bashrc 2>/dev/null
EXP_TITLE="EXPERIMENT 8 : Pig script to join, group, sort and filter data"
LOG="$LOGDIR/exp8.log"; FROM=${1:-1}
[ "$FROM" -le 1 ] && : > "$LOG"

screen 1 "Input datasets and upload to HDFS" && {
  run head -n 20 data/student_details.txt data/customers.txt data/orders.txt
  run head -n 20 data/students.txt data/departments.txt data/employees.txt
  hdfs dfs -rm -r -f -skipTrash /bdt/exp8 >/dev/null 2>&1
  run hdfs dfs -mkdir -p /bdt/exp8
  run hdfs dfs -put -f data/*.txt /bdt/exp8/
  run hdfs dfs -ls /bdt/exp8; pause; }
screen 2 "GROUP: by one column, by multiple columns, with COUNT, and GROUP ALL" && {
  pigrun pig/01_group.pig; pause; }
screen 3 "JOIN: self join and inner (equi) join" && {
  pigrun pig/02_join_self_inner.pig; pause; }
screen 4 "JOIN: left, right and full outer joins" && {
  pigrun pig/03_outer_joins.pig; pause; }
screen 5 "FILTER and ORDER BY (sort), LIMIT" && {
  pigrun pig/04_filter_sort.pig; pause; }
screen 6 "Handwritten questions 1-3: student-department JOIN, salary per department, salary > 50000 sorted" && {
  pigrun pig/05_handwritten.pig; pause; }
clear; echo "Experiment 8 finished. Full log: $LOG"
