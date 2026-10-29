#!/usr/bin/env bash
# BDT Lab - Experiment 10 : Word Count in Spark with Unit Tests   (5 screenshots, more if output is long)
# Requires Experiment 9 (Spark installed).  Usage:  bash ~/bdt/exp10/run_exp10.sh      restart at part N: ... N
cd "$(dirname "$0")"; source ../common/lib.sh
EXP_TITLE="EXPERIMENT 10 : Word Count in Apache Spark with Unit Tests"
LOG="$LOGDIR/exp10.log"; FROM=${1:-1}
[ "$FROM" -le 1 ] && : > "$LOG"
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-$(dpkg --print-architecture)
export SPARK_HOME=$HOME/spark-3.5.8-bin-hadoop3
export PATH=$PATH:$JAVA_HOME/bin:$SPARK_HOME/bin
IN=hdfs://localhost:9000/bdt/exp10/input.txt; OUT=hdfs://localhost:9000/bdt/exp10/wordcount_output

screen 1 "Input file and upload to HDFS" && {
  run cat data/input.txt
  hdfs dfs -rm -r -f -skipTrash /bdt/exp10 >/dev/null 2>&1
  run hdfs dfs -mkdir -p /bdt/exp10
  run hdfs dfs -put -f data/input.txt /bdt/exp10/
  run hdfs dfs -ls /bdt/exp10
  run hdfs dfs -cat /bdt/exp10/input.txt; pause; }
screen 2 "WordCount.scala - the Spark Word Count application" && {
  show_code scala/WordCount.scala; pause; }
screen 3 "WordCountTest.scala - unit tests (normal, repeated, empty, multi-line input)" && {
  show_code scala/WordCountTest.scala; pause; }
screen 4 "Starting the Spark CLI: load WordCount, run the unit tests, run the job on HDFS" && {
  hdfs dfs -rm -r -f -skipTrash /bdt/exp10/wordcount_output >/dev/null 2>&1
  mkdir -p build
  { cat scala/WordCount.scala; echo; cat scala/WordCountTest.scala; echo
    echo "WordCount.main(Array(\"$IN\", \"$OUT\"))"; echo "System.exit(0)"; } > build/run_all.scala
  run spark-shell -i build/run_all.scala; pause; }
screen 5 "Hadoop output screen: result files in HDFS and verification" && {
  run hdfs dfs -ls /bdt/exp10/wordcount_output
  runsh "hdfs dfs -cat /bdt/exp10/wordcount_output/part-*"
  runsh "tr -s ' ' '\n' < data/input.txt | sort | uniq -c | sort -k1,1nr -k2,2 | head -8"
  pause; }
clear; echo "Experiment 10 finished. Full log: $LOG"
