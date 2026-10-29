#!/usr/bin/env bash
# BDT Lab - Experiment 7 : Word count in a text file using Apache Pig   (6 screenshots)
# Usage (inside Ubuntu):  bash ~/bdt/exp7/run_exp7.sh      restart at part N:  bash ~/bdt/exp7/run_exp7.sh N
cd "$(dirname "$0")"; source ../common/lib.sh; source ~/.bashrc 2>/dev/null
EXP_TITLE="EXPERIMENT 7 : Counting the number of words in a text file using Apache Pig"
LOG="$LOGDIR/exp7.log"; FROM=${1:-1}
[ "$FROM" -le 1 ] && : > "$LOG"

screen 1 "Environment check, input file and upload to HDFS" && {
  run pig -version
  run bash -c "hadoop version | head -1"
  run jps
  run cat data/input.txt
  run cat data/q4.txt
  hdfs dfs -rm -r -f -skipTrash /bdt/exp7 >/dev/null 2>&1
  run hdfs dfs -mkdir -p /bdt/exp7
  run hdfs dfs -put -f data/input.txt data/q4.txt /bdt/exp7/
  run hdfs dfs -ls /bdt/exp7; pause; }
screen 2 "LOAD the text file and display its contents (DESCRIBE + DUMP)" && {
  pigrun pig/01_load_display.pig; pause; }
screen 3 "Word frequency: TOKENIZE -> FLATTEN -> GROUP -> COUNT -> ORDER -> STORE" && {
  pigrun pig/02_word_count.pig; pause; }
screen 4 "Total number of words, distinct words and lines" && {
  pigrun pig/03_total_words.pig; pause; }
screen 5 "Case sensitivity and punctuation: 'Big Data is useful. Big Data is powerful.'" && {
  pigrun pig/04_case_punctuation.pig; pause; }
screen 6 "Verification of the Pig result with standard Linux tools" && {
  runsh "wc -l -w data/input.txt"
  runsh "tr -s ' ' '\n' < data/input.txt | sort | uniq -c | sort -k1,1nr -k2,2 | head -12"
  runsh "hdfs dfs -cat /bdt/exp7/output_wordcount/part* | head -12"
  pause; }
clear; echo "Experiment 7 finished. Full log: $LOG"
