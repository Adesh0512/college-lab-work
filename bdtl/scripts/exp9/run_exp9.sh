#!/usr/bin/env bash
# BDT Lab - Experiment 9 : Installation of Apache Spark   (6 screenshots)
# Usage (inside Ubuntu):  bash ~/bdt/exp9/run_exp9.sh      restart at part N:  bash ~/bdt/exp9/run_exp9.sh N
cd "$(dirname "$0")"; source ../common/lib.sh
EXP_TITLE="EXPERIMENT 9 : Installation of Apache Spark"
LOG="$LOGDIR/exp9.log"; FROM=${1:-1}
[ "$FROM" -le 1 ] && : > "$LOG"
SPARK_VER=3.5.8; SPARK_PKG=spark-$SPARK_VER-bin-hadoop3
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-$(dpkg --print-architecture)
export SPARK_HOME=$HOME/$SPARK_PKG
export PATH=$PATH:$JAVA_HOME/bin:$SPARK_HOME/bin:$SPARK_HOME/sbin

screen 1 "Step 1 : Update the system and check Java" && {
  run sudo apt-get update
  run java -version
  run bash -c 'echo JAVA_HOME=$JAVA_HOME'; pause; }
screen 2 "Step 2 : Download Apache Spark $SPARK_VER (pre-built for Hadoop 3)" && {
  cd ~
  run wget -c --progress=bar:force:noscroll "https://dlcdn.apache.org/spark/spark-$SPARK_VER/$SPARK_PKG.tgz" \
   || run wget -c --progress=bar:force:noscroll "https://archive.apache.org/dist/spark/spark-$SPARK_VER/$SPARK_PKG.tgz"
  run ls -lh "$HOME/$SPARK_PKG.tgz"
  cd - >/dev/null; pause; }
screen 3 "Step 3/4 : Extract the Apache Spark file" && {
  cd ~
  run tar -xzf "$SPARK_PKG.tgz"
  runsh "ls -l ~ | grep spark"
  run ls "$SPARK_HOME"
  run ls "$SPARK_HOME/bin"
  cd - >/dev/null; pause; }
screen 4 "Step 5 : Set environment variables (~/.bashrc) and Spark defaults" && {
  if ! grep -q "BDT-SPARK-ENV" ~/.bashrc; then
    printf '\n# >>> BDT-SPARK-ENV >>>\nexport SPARK_HOME=%s\nexport PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin\nexport PYSPARK_PYTHON=python3\n# <<< BDT-SPARK-ENV <<<\n' "$SPARK_HOME" >> ~/.bashrc
  fi
  printf 'spark.driver.memory    768m\nspark.ui.showConsoleProgress  true\n' > "$SPARK_HOME/conf/spark-defaults.conf"
  run tail -6 ~/.bashrc
  run cat "$SPARK_HOME/conf/spark-defaults.conf"; pause; }
screen 5 "Step 6 : Load the file and verify the installation" && {
  run bash -ic 'source ~/.bashrc; echo SPARK_HOME=$SPARK_HOME; which spark-shell spark-submit pyspark'
  run spark-submit --version; pause; }
screen 6 "Output : Spark Shell running a basic application (sum of numbers)" && {
  show_code scala/SumApp.scala
  run spark-shell -i scala/SumApp.scala; pause; }
clear; echo "Experiment 9 finished. Full log: $LOG"
