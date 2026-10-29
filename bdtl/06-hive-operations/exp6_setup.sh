#!/usr/bin/env bash
# =====================================================================
#  BDT Lab - Experiment 6 : one-time setup
#  Java 8 + Hadoop 3.3.6 (single node: HDFS + YARN) + Hive 3.1.2
#  Works on Ubuntu 22.04 / 24.04, Intel (amd64) or Apple Silicon (arm64)
#
#  Run INSIDE Ubuntu (e.g. multipass shell bigdata):
#       bash exp6_setup.sh
#  Safe to re-run: finished steps are skipped.
# =====================================================================
set -euo pipefail

HADOOP_VER=3.3.6
HIVE_VER=3.1.2
ARCH=$(dpkg --print-architecture)                 # amd64 or arm64
JAVA_HOME=/usr/lib/jvm/java-8-openjdk-$ARCH
HADOOP_HOME=$HOME/hadoop-$HADOOP_VER
HIVE_HOME=$HOME/apache-hive-$HIVE_VER-bin
HDATA=$HOME/hdata
APACHE=https://archive.apache.org/dist

step() { echo; echo "==================== $* ===================="; }

# ---------------------------------------------------------------------
step "1/9  Installing Java 8, SSH and tools"
sudo apt-get update -y
sudo apt-get install -y openjdk-8-jdk-headless openssh-server wget nano
"$JAVA_HOME/bin/java" -version

# ---------------------------------------------------------------------
step "2/9  Passwordless SSH to localhost (needed by start-dfs.sh)"
mkdir -p ~/.ssh && chmod 700 ~/.ssh
[ -f ~/.ssh/id_rsa ] || ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa -q
touch ~/.ssh/authorized_keys
grep -qF -f ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys || cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
sudo systemctl start ssh || sudo service ssh start
ssh-keyscan -H localhost 127.0.0.1 0.0.0.0 "$(hostname)" >> ~/.ssh/known_hosts 2>/dev/null
ssh -o BatchMode=yes localhost true && echo "SSH to localhost OK" || echo "WARNING: ssh localhost failed - see guide (Troubleshooting)"

# ---------------------------------------------------------------------
step "3/9  Downloading Hadoop $HADOOP_VER ($ARCH)"
cd ~
if [ ! -d "$HADOOP_HOME" ]; then
  if [ "$ARCH" = "arm64" ]; then HT=hadoop-$HADOOP_VER-aarch64.tar.gz; else HT=hadoop-$HADOOP_VER.tar.gz; fi
  # fast Apache CDN first, slow archive as backup (-c resumes a partial download)
  wget -c "https://dlcdn.apache.org/hadoop/common/hadoop-$HADOOP_VER/$HT" \
    || wget -c "$APACHE/hadoop/common/hadoop-$HADOOP_VER/$HT"
  tar -xzf "$HT"
fi
[ -d "$HADOOP_HOME" ] || { echo "Hadoop folder not found at $HADOOP_HOME"; exit 1; }

# ---------------------------------------------------------------------
step "4/9  Downloading Hive $HIVE_VER"
if [ ! -d "$HIVE_HOME" ]; then
  # fast mirror first (Apache CDN no longer hosts 3.1.2), slow archive as backup
  wget -c "https://repo.huaweicloud.com/apache/hive/hive-$HIVE_VER/apache-hive-$HIVE_VER-bin.tar.gz" \
    || wget -c "$APACHE/hive/hive-$HIVE_VER/apache-hive-$HIVE_VER-bin.tar.gz"
  tar -xzf "apache-hive-$HIVE_VER-bin.tar.gz"
fi
[ -d "$HIVE_HOME" ] || { echo "Hive folder not found at $HIVE_HOME"; exit 1; }

# ---------------------------------------------------------------------
step "5/9  Adding environment variables to ~/.bashrc"
if ! grep -q "BDT-LAB-ENV" ~/.bashrc; then
cat >> ~/.bashrc <<EOF

# >>> BDT-LAB-ENV >>>
export JAVA_HOME=$JAVA_HOME
export HADOOP_HOME=$HADOOP_HOME
export HADOOP_CONF_DIR=\$HADOOP_HOME/etc/hadoop
export HADOOP_MAPRED_HOME=\$HADOOP_HOME
export HADOOP_COMMON_HOME=\$HADOOP_HOME
export HADOOP_HDFS_HOME=\$HADOOP_HOME
export YARN_HOME=\$HADOOP_HOME
export HIVE_HOME=$HIVE_HOME
export PDSH_RCMD_TYPE=ssh
export PATH=\$PATH:\$JAVA_HOME/bin:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin:\$HIVE_HOME/bin
# <<< BDT-LAB-ENV <<<
EOF
fi
export JAVA_HOME HADOOP_HOME HIVE_HOME
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_COMMON_HOME=$HADOOP_HOME HADOOP_HDFS_HOME=$HADOOP_HOME YARN_HOME=$HADOOP_HOME
export PDSH_RCMD_TYPE=ssh
export PATH=$PATH:$JAVA_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$HIVE_HOME/bin

# ---------------------------------------------------------------------
step "6/9  Configuring Hadoop (core, hdfs, mapred, yarn)"
C=$HADOOP_HOME/etc/hadoop
grep -q "^export JAVA_HOME=$JAVA_HOME" $C/hadoop-env.sh || echo "export JAVA_HOME=$JAVA_HOME" >> $C/hadoop-env.sh
mkdir -p $HDATA/namenode $HDATA/datanode $HDATA/tmp

cat > $C/core-site.xml <<EOF
<?xml version="1.0"?>
<configuration>
  <property><name>fs.defaultFS</name><value>hdfs://localhost:9000</value></property>
  <property><name>hadoop.tmp.dir</name><value>$HDATA/tmp</value></property>
  <property><name>hadoop.proxyuser.$USER.groups</name><value>*</value></property>
  <property><name>hadoop.proxyuser.$USER.hosts</name><value>*</value></property>
  <property><name>hadoop.proxyuser.server.hosts</name><value>*</value></property>
  <property><name>hadoop.proxyuser.server.groups</name><value>*</value></property>
</configuration>
EOF

cat > $C/hdfs-site.xml <<EOF
<?xml version="1.0"?>
<configuration>
  <property><name>dfs.replication</name><value>1</value></property>
  <property><name>dfs.namenode.name.dir</name><value>file://$HDATA/namenode</value></property>
  <property><name>dfs.datanode.data.dir</name><value>file://$HDATA/datanode</value></property>
  <property><name>dfs.namenode.http-address</name><value>0.0.0.0:9870</value></property>
</configuration>
EOF

cat > $C/mapred-site.xml <<EOF
<?xml version="1.0"?>
<configuration>
  <property><name>mapreduce.framework.name</name><value>yarn</value></property>
  <property><name>yarn.app.mapreduce.am.env</name><value>HADOOP_MAPRED_HOME=$HADOOP_HOME</value></property>
  <property><name>mapreduce.map.env</name><value>HADOOP_MAPRED_HOME=$HADOOP_HOME</value></property>
  <property><name>mapreduce.reduce.env</name><value>HADOOP_MAPRED_HOME=$HADOOP_HOME</value></property>
  <property><name>mapreduce.application.classpath</name>
    <value>$HADOOP_HOME/share/hadoop/mapreduce/*:$HADOOP_HOME/share/hadoop/mapreduce/lib/*</value></property>
  <property><name>yarn.app.mapreduce.am.resource.mb</name><value>1024</value></property>
  <property><name>yarn.app.mapreduce.am.command-opts</name><value>-Xmx800m</value></property>
  <property><name>mapreduce.map.memory.mb</name><value>512</value></property>
  <property><name>mapreduce.reduce.memory.mb</name><value>512</value></property>
  <property><name>mapreduce.map.java.opts</name><value>-Xmx400m</value></property>
  <property><name>mapreduce.reduce.java.opts</name><value>-Xmx400m</value></property>
</configuration>
EOF

cat > $C/yarn-site.xml <<EOF
<?xml version="1.0"?>
<configuration>
  <property><name>yarn.nodemanager.aux-services</name><value>mapreduce_shuffle</value></property>
  <property><name>yarn.nodemanager.env-whitelist</name>
    <value>JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_HOME,PATH,LANG,TZ,HADOOP_MAPRED_HOME</value></property>
  <property><name>yarn.nodemanager.resource.memory-mb</name><value>3072</value></property>
  <property><name>yarn.scheduler.minimum-allocation-mb</name><value>256</value></property>
  <property><name>yarn.scheduler.maximum-allocation-mb</name><value>3072</value></property>
  <property><name>yarn.nodemanager.vmem-check-enabled</name><value>false</value></property>
</configuration>
EOF

# ---------------------------------------------------------------------
step "7/9  Configuring Hive"
# Hive 3.1.2 ships guava-19 which clashes with Hadoop 3.3.x -> use Hadoop's guava
rm -f $HIVE_HOME/lib/guava-19.0.jar
cp $HADOOP_HOME/share/hadoop/common/lib/guava-*.jar $HIVE_HOME/lib/
echo "export HADOOP_HOME=$HADOOP_HOME" > $HIVE_HOME/conf/hive-env.sh

cat > $HIVE_HOME/conf/hive-site.xml <<EOF
<?xml version="1.0"?>
<configuration>
  <!-- Derby metastore at a fixed path, so Hive works from any folder -->
  <property><name>javax.jdo.option.ConnectionURL</name>
    <value>jdbc:derby:;databaseName=$HOME/metastore_db;create=true</value></property>
  <property><name>hive.metastore.warehouse.dir</name><value>/user/hive/warehouse</value></property>
  <property><name>hive.server2.enable.doAs</name><value>false</value></property>
  <!-- Show current database in the prompt:  hive (mydb)> -->
  <property><name>hive.cli.print.current.db</name><value>true</value></property>
  <!-- ACID / transactions: needed for UPDATE and DELETE -->
  <property><name>hive.support.concurrency</name><value>true</value></property>
  <property><name>hive.txn.manager</name><value>org.apache.hadoop.hive.ql.lockmgr.DbTxnManager</value></property>
  <property><name>hive.exec.dynamic.partition.mode</name><value>nonstrict</value></property>
  <property><name>hive.compactor.initiator.on</name><value>true</value></property>
  <property><name>hive.compactor.worker.threads</name><value>1</value></property>
</configuration>
EOF

# ---------------------------------------------------------------------
step "8/9  Formatting HDFS and starting Hadoop"
if [ ! -d $HDATA/namenode/current ]; then
  hdfs namenode -format -nonInteractive
fi
RUNNING=$(jps)
echo "$RUNNING" | grep -q " NameNode"        || start-dfs.sh
echo "$RUNNING" | grep -q " ResourceManager" || start-yarn.sh
hdfs dfsadmin -safemode wait
jps

# ---------------------------------------------------------------------
step "9/9  HDFS folders for Hive + Derby metastore"
hdfs dfs -mkdir -p /tmp /user/hive/warehouse
hdfs dfs -chmod g+w /tmp
hdfs dfs -chmod g+w /user/hive/warehouse
if [ ! -d $HOME/metastore_db ]; then
  schematool -dbType derby -initSchema
fi

echo
echo "=========================================================="
echo " Setup complete.  Now run:   source ~/.bashrc"
echo " Then start Hive with:       hive"
echo "=========================================================="
