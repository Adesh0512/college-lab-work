#!/usr/bin/env bash
# BDT Lab - Experiment 3 : Update and Delete Records in Hive   (7 screenshots)
# Usage (inside Ubuntu):   bash ~/bdt/exp3/run_exp3.sh        restart at part N:  bash ~/bdt/exp3/run_exp3.sh N
cd "$(dirname "$0")"; source ../common/lib.sh
EXP_TITLE="EXPERIMENT 3 : Update and Delete Records in Hive (ACID: UPDATE / DELETE / MERGE)"
LOG="$LOGDIR/exp3.log"; FROM=${1:-1}

if [ "$FROM" -le 1 ]; then
  : > "$LOG"; echo "Resetting Experiment 3 objects (safe to re-run)..."
  bash ../tools/clear_hive_locks.sh
  timeout 300 hive -S -e "DROP DATABASE IF EXISTS exp3_db CASCADE;" 2>&1 | grep -v -E "^SLF4J|^Hive Session ID"
fi

screen 1 "Datasets, transaction settings in hive-site.xml, and enabling them in the session" && {
  run cat data/employees.csv
  run cat data/employee_updates.csv
  run grep -E -A1 "support.concurrency|txn.manager|compactor" "$HIVE_HOME/conf/hive-site.xml"
  hql sql/01_enable_transactions.sql; pause; }
screen 2 "UPDATE on a normal (non-transactional) table fails" && {
  hql sql/02_non_acid_table.sql; pause; }
screen 3 "Create the ACID table and load it" && {
  hql sql/03_create_acid_table.sql; pause; }
screen 4 "UPDATE records" && {
  hql sql/04_update.sql; pause; }
screen 5 "DELETE records" && {
  hql sql/05_delete.sql; pause; }
screen 6 "MERGE (update + delete + insert in one statement)" && {
  hql sql/06_merge.sql; pause; }
screen 7 "ORC delta / delete_delta files in HDFS, transactions and compaction" && {
  run hdfs dfs -ls -R /user/hive/warehouse/exp3_db.db/employee_acid
  hql sql/07_transactions_and_compaction.sql; pause; }
clear; echo "Experiment 3 finished. Full log: $LOG"
