#!/usr/bin/env bash
# BDT Lab - Experiment 1 : Create and Describe Tables in Hive   (8 screenshots)
# Usage (inside Ubuntu):   bash ~/bdt/exp1/run_exp1.sh        restart at part N:  bash ~/bdt/exp1/run_exp1.sh N
cd "$(dirname "$0")"; source ../common/lib.sh
EXP_TITLE="EXPERIMENT 1 : Create and Describe Tables in Hive (TEXTFILE / ORC / PARQUET)"
LOG="$LOGDIR/exp1.log"; FROM=${1:-1}

if [ "$FROM" -le 1 ]; then
  : > "$LOG"; echo "Resetting Experiment 1 objects (safe to re-run)..."
  bash ../tools/clear_hive_locks.sh
  timeout 300 hive -S -e "DROP DATABASE IF EXISTS exp1_db CASCADE;" 2>&1 | grep -v -E "^SLF4J|^Hive Session ID"
  hdfs dfs -rm -r -f -skipTrash /bdt/exp1 >/dev/null 2>&1
fi

screen 1 "Input dataset, upload to HDFS, create database and MANAGED tables" && {
  run cat data/employees.csv
  run hdfs dfs -mkdir -p /bdt/exp1/ext_text
  run hdfs dfs -put -f data/employees.csv /bdt/exp1/ext_text/
  hql sql/01_database_and_managed_tables.sql; pause; }
screen 2 "EXTERNAL tables: TEXTFILE, ORC, PARQUET" && {
  hql sql/03_external_tables.sql; pause; }
screen 3 "SHOW TABLES and DESCRIBE" && {
  hql sql/04_show_and_describe.sql; pause; }
screen 4 "DESCRIBE FORMATTED - managed ORC table" && {
  hql sql/05_describe_formatted_managed.sql; pause; }
screen 5 "DESCRIBE FORMATTED - external PARQUET table" && {
  hql sql/06_describe_formatted_external.sql; pause; }
screen 6 "Query the tables in every format" && {
  hql sql/07_query_all_tables.sql; pause; }
screen 7 "Data files in HDFS: managed (warehouse) vs external (own location)" && {
  run hdfs dfs -ls -R /user/hive/warehouse/exp1_db.db
  run hdfs dfs -ls -R /bdt/exp1; pause; }
screen 8 "Proof of file format: first bytes of each data file" && {
  for t in emp_text emp_orc emp_parquet; do
    f=$(hdfs dfs -ls -C /user/hive/warehouse/exp1_db.db/$t | grep -v '/\.' | head -1)
    sub "$t  ->  $f"
    run bash -c "hdfs dfs -cat $f | head -c 4; echo"
  done
  printf "\nTEXTFILE starts with plain text, ORC files start with 'ORC', Parquet files start with 'PAR1'.\n" | tee -a "$LOG"
  pause; }
clear; echo "Experiment 1 finished. Full log: $LOG"
