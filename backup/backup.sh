#!/bin/bash

echo "*** Backup PSQL started...."

# make environment variables visible to cron 
source /root/backup.properties

# Backup PSQL database with the PSQL custom format
# We only backup one specified database here. In case you want to create a complete backup of all databases use
# pg_dumpall -c -h $BACKUP_POSTGRES_HOST -U $BACKUP_POSTGRES_USER > backups/$(date +%Y-%m-%d_%H:%M)_pgdump.sql

echo "*** Backup PSQL database=$BACKUP_POSTGRES_DB"
pg_dump -h $BACKUP_POSTGRES_HOST -U $BACKUP_POSTGRES_USER -d $BACKUP_POSTGRES_DB -Fc > backups/$(date +%Y-%m-%d_%H:%M)_pgdump.sql
echo "*** Backup PSQL finished"