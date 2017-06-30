#!/bin/bash

# start ssh demon 
/etc/init.d/ssh start

# Format HDFS....?
if [ ! -f /data/hdfs/runonce.lock ]; then
    if [ ! -d /data/hdfs/namenode ]; then
      touch /data/hdfs/runonce.lock
      echo "NO DATA IN /data/hdfs/namenode"
      echo "FORMATTING NAMENODE"
      $HADOOP_HOME/bin/hdfs namenode -format || { echo 'FORMATTING FAILED' ; exit 1; }
      chown -R hduser:hadoop /data/hdfs || { echo 'CHOWN FAILED' ; exit 1; }
    fi
fi


# start hadoop DFS
echo "Starting Hadoop DFS...."
$HADOOP_HOME/sbin/start-dfs.sh

echo "Hadoop Startup completed" 
# keep running in the foreground
tail -f $HADOOP_HOME/logs/*
#tail -f /dev/null 
