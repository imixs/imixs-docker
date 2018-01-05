#!/bin/bash

echo "========================================================================="
echo "Initalize backup service....."
echo "cron = $BACKUP_CRON"
echo "========================================================================="

# export all environment variables to be used by cron (starting with 'BACKUP_')
env | sed 's/^\(.*\)$/export \1/g' | grep -E "^export BACKUP_" > /root/backup.properties

# create psql  password file...
echo "$BACKUP_POSTGRES_HOST:*:*:$BACKUP_POSTGRES_USER:$BACKUP_POSTGRES_PASSWORD" >> ~/.pgpass 
chmod 0600 ~/.pgpass

# create backup-cron file...
echo "$BACKUP_CRON root /root/backup.sh > /proc/1/fd/1 2>/proc/1/fd/2" > /etc/cron.d/backup-cron
chmod 0644 /etc/cron.d/backup-cron

# Run cron.....
cron -f