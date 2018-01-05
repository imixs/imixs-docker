#!/bin/bash

# make environment variables visible to cron 
source /root/backup.properties

# Backup all PSQL databases
echo "========================================================================="
echo "Starting backup PSQL databases....."
echo "========================================================================="

pg_dumpall -c -v -h $BACKUP_POSTGRES_HOST -U $BACKUP_POSTGRES_USER > backups/$(date +%Y-%m-%d_%H:%M)_pgdump.sql