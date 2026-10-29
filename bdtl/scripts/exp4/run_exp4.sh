#!/usr/bin/env bash
# BDT Lab - Experiment 4 : Alter and Drop Table Operations   (8 screenshots)
# Usage (inside Ubuntu):   bash ~/bdt/exp4/run_exp4.sh        restart at part N:  bash ~/bdt/exp4/run_exp4.sh N
cd "$(dirname "$0")"; source ../common/lib.sh
EXP_TITLE="EXPERIMENT 4 : Alter and Drop Table Operations (ALTER / DROP / MSCK REPAIR TABLE)"
LOG="$LOGDIR/exp4.log"; FROM=${1:-1}
WH=/user/hive/warehouse/exp4_db.db

if [ "$FROM" -le 1 ]; then
  : > "$LOG"; echo "Resetting Experiment 4 objects (safe to re-run)..."
  bash ../tools/clear_hive_locks.sh
  timeout 300 hive -S -e "DROP DATABASE IF EXISTS exp4_db CASCADE;" 2>&1 | grep -v -E "^SLF4J|^Hive Session ID"
  hdfs dfs -rm -r -f -skipTrash /bdt/exp4 >/dev/null 2>&1
fi

screen 1 "Input data and the starting table" && {
  run cat data/students.csv
  hql sql/01_create_table.sql
  run hdfs dfs -ls -R $WH; pause; }
screen 2 "ALTER TABLE ... RENAME TO" && {
  hql sql/02_rename_table.sql
  run hdfs dfs -ls -R $WH; pause; }
screen 3 "ALTER TABLE ... ADD COLUMNS and CHANGE (rename column / change data type)" && {
  hql sql/03_add_columns.sql
  hql sql/04_change_column.sql; pause; }
screen 4 "ALTER TABLE ... REPLACE COLUMNS, then DROP the managed table" && {
  hql sql/05_replace_columns.sql
  hql sql/06_drop_managed.sql
  run hdfs dfs -ls -R $WH; pause; }
screen 5 "Partition folders created directly in HDFS + EXTERNAL partitioned table" && {
  run head data/sales_2023.csv data/sales_2024.csv
  run hdfs dfs -mkdir -p /bdt/exp4/sales/year=2023 /bdt/exp4/sales/year=2024
  run hdfs dfs -put -f data/sales_2023.csv /bdt/exp4/sales/year=2023/
  run hdfs dfs -put -f data/sales_2024.csv /bdt/exp4/sales/year=2024/
  run hdfs dfs -ls -R /bdt/exp4/sales
  hql sql/07_external_partitioned.sql; pause; }
screen 6 "MSCK REPAIR TABLE registers the partitions" && {
  hql sql/08_msck_repair.sql; pause; }
screen 7 "DROP the external table (data stays) + new data arrives in HDFS" && {
  hql sql/09_drop_external.sql
  run hdfs dfs -mkdir -p /bdt/exp4/sales/year=2025
  run hdfs dfs -put -f data/sales_2025.csv /bdt/exp4/sales/year=2025/
  run hdfs dfs -ls -R /bdt/exp4/sales; pause; }
screen 8 "RECOVER the table with MSCK REPAIR TABLE" && {
  hql sql/10_recover_table.sql; pause; }
clear; echo "Experiment 4 finished. Full log: $LOG"
