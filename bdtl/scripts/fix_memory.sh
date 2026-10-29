#!/usr/bin/env bash
# Makes Hadoop + Hive fit comfortably in a 4 GB VM.
# Cause of the hang: every Hadoop service defaulted to a ~1 GB Java heap, so
# 5 services + Hive + the MapReduce tasks needed more RAM than the VM has,
# and Linux killed the ResourceManager.  Safe to run more than once.
source ~/.bashrc 2>/dev/null
C=$HADOOP_HOME/etc/hadoop

echo "== Stopping Hadoop =="
stop-yarn.sh; stop-dfs.sh
pkill -f org.apache.hadoop.hive.cli.CliDriver 2>/dev/null

echo "== Smaller Java heaps for the Hadoop services and the Hive client =="
grep -q "HADOOP_HEAPSIZE_MAX" $C/hadoop-env.sh || echo "export HADOOP_HEAPSIZE_MAX=384m" >> $C/hadoop-env.sh
grep -q "HADOOP_HEAPSIZE" $HIVE_HOME/conf/hive-env.sh || echo "export HADOOP_HEAPSIZE=768" >> $HIVE_HOME/conf/hive-env.sh

echo "== YARN: 2 GB for tasks, 512 MB per task, max 2 map tasks at a time =="
set_prop() {  # set_prop file name value
  if grep -q "<name>$2</name>" "$1"; then
    sed -i "s#<name>$2</name><value>[^<]*</value>#<name>$2</name><value>$3</value>#" "$1"
  else
    sed -i "s#</configuration>#  <property><name>$2</name><value>$3</value></property>\n</configuration>#" "$1"
  fi
}
set_prop $C/yarn-site.xml   yarn.nodemanager.resource.memory-mb   2048
set_prop $C/yarn-site.xml   yarn.scheduler.maximum-allocation-mb  2048
set_prop $C/mapred-site.xml yarn.app.mapreduce.am.resource.mb     768
set_prop $C/mapred-site.xml yarn.app.mapreduce.am.command-opts    -Xmx600m
set_prop $C/mapred-site.xml mapreduce.job.running.map.limit       2

echo "== Starting Hadoop =="
start-dfs.sh; start-yarn.sh
hdfs dfsadmin -safemode wait
sleep 5
jps
free -m
yarn node -list
