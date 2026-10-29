#!/usr/bin/env bash
# One-time setup of Apache Pig 0.18.0 (Hadoop 3 build) on the existing Hadoop 3.3.6 VM.
# Usage (inside Ubuntu):  bash ~/bdt/pig/setup_pig.sh      (safe to re-run)
set -e
source ~/.bashrc 2>/dev/null || true
PIG_VER=0.18.0
PIG_HOME=$HOME/pig-$PIG_VER
cd ~
echo "== 1/4 Downloading Apache Pig $PIG_VER =="
if [ ! -d "$PIG_HOME" ]; then
  wget -c "https://dlcdn.apache.org/pig/pig-$PIG_VER/pig-$PIG_VER.tar.gz" \
   || wget -c "https://archive.apache.org/dist/pig/pig-$PIG_VER/pig-$PIG_VER.tar.gz"
  tar -xzf "pig-$PIG_VER.tar.gz"
fi
echo "== 2/4 Environment variables (PIG_HOME, PATH, PIG_CLASSPATH) =="
if ! grep -q "BDT-PIG-ENV" ~/.bashrc; then
cat >> ~/.bashrc <<EOT

# >>> BDT-PIG-ENV >>>
export PIG_HOME=$PIG_HOME
export PATH=\$PATH:\$PIG_HOME/bin
export PIG_CLASSPATH=\$HADOOP_HOME/etc/hadoop
export PIG_HEAPSIZE=512
# <<< BDT-PIG-ENV <<<
EOT
fi
export PIG_HOME PATH=$PATH:$PIG_HOME/bin PIG_CLASSPATH=$HADOOP_HOME/etc/hadoop PIG_HEAPSIZE=512
echo "== 3/4 Starting Hadoop (if needed) and the MapReduce JobHistory server =="
jps | grep -q " NameNode"        || start-dfs.sh
jps | grep -q " ResourceManager" || start-yarn.sh
# Pig asks the JobHistory server (port 10020) for job statistics after every job
jps | grep -q " JobHistoryServer" || mapred --daemon start historyserver
hdfs dfsadmin -safemode wait
sleep 3
jps
echo "== 4/4 Verifying Pig =="
pig -version
echo
echo "Pig setup complete. Run:  source ~/.bashrc"
