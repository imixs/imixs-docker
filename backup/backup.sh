#!/bin/bash

# make environment variables visible to cron 
source /backup.properties

# Backup all PSQL databases
echo "========================================================================="
echo "Starting backup PSQL databases....."
echo "========================================================================="

pg_dumpall -c -v -h $BACKUP_POSTGRES_HOST -U $BACKUP_POSTGRES_USER > dumpfile.sql