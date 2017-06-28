#!/bin/bash

# start ssh demon 
/etc/init.d/ssh start

# start hadoop DFS
echo "Starting Hadoop DFS...."
/opt/hadoop/sbin/start-dfs.sh

echo "Hadoop Startup completed" 
# keep running in the foreground
tail -f /opt/hadoop/logs/*
