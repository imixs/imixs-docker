#!/bin/bash

echo "========================================================================="
echo "Initalize backup service....."
echo "========================================================================="

# export all environment variables to be used by cron (starting with 'BACKUP_')
env | sed 's/^\(.*\)$/export \1/g' | grep -E "^export BACKUP_" > /backup.properties

# Run cron.....
cron -f