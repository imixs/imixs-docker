#!/bin/bash

# *****************************************************************************************
# * The Restore script restores a MYSQL/PSQL database and backup data from a              *
# * docker volume shared by the container.                                                *
# *                                                                                       *
# * The restore process depends on the envirionment configuration                         *
# * The process restores the last local backup if available. In case a timestamp is       *
# * provided, a specific backup can be restored.                                          *                                  
# *                                                                                       *
# * e.g                                                                                   *
# *        ./restore.sh 2018-01-05_03:00                                                  * 
# *                                                                                       *
# * Find details here: https://github.com/imixs/imixs-docker/tree/master/backup           *
# *****************************************************************************************

echo "========================================================================="
echo "Starting Restore...."
echo "========================================================================="
BACKUP_FILE=""

if [ $# -eq 0 ]
  then
    echo "*** no arguments supplied, restore last backup..."
    # determine last backup file
    BACKUP_FILE=$(ls -F /root/backups/*_dump.tar.gz | tail -n 1)
  else
    echo "*** restore timestamp: $1"
    BACKUP_FILE="/root/backups/$1_dump.tar.gz"
fi    
    
# First extract the backup file...
echo "*** extracting backupfile" $BACKUP_FILE "...."
tar -xzf $BACKUP_FILE -C /
  
# Test database type (MYSQL/POSTGRESQL)  
if [ "$BACKUP_DB_TYPE" == "MYSQL" ] || [ "$BACKUP_DB_TYPE" == "POSTGRESQL" ] ; then
    echo "*** starting database restore..."
    echo "***        BACKUP_DB_TYPE = $BACKUP_DB_TYPE"
    echo "***        BACKUP_DB = $BACKUP_DB"

        if [ "$BACKUP_DB_TYPE" == "POSTGRESQL" ] 
          then
                # ****************************************************
                # Backup PostgreSQL database with the PSQL custom format 
                # - password is provided by backup_init script
                # ****************************************************
                # We only backup one specified database here. In case you want to create a complete backup of all databases use
                # pg_dumpall -c -h $BACKUP_POSTGRES_HOST -U $BACKUP_POSTGRES_USER > $BACKUP_FILE
                #
                # Script:
                # pg_dump -h $BACKUP_DB_HOST -U $BACKUP_DB_USER -d $BACKUP_DB -Fc > $DB_FILE               
                pg_restore -c -h $BACKUP_DB_HOST -U $BACKUP_DB_USER -Fc -d $BACKUP_DB  /root/backups/db.sql
        fi
        
        if [ "$BACKUP_DB_TYPE" == "MYSQL" ] 
          then
                # ****************************************************
                # Restore MySQL database with the mysql
                # ****************************************************
                mysql -h $BACKUP_DB_HOST -u $BACKUP_DB_USER --password=$BACKUP_DB_PASSWORD $BACKUP_DB < /root/backups/db.sql;
        fi
        echo "***        ...database restore finished! "

else
    echo "***        WARNING: unsupported database type = $BACKUP_DB_TYPE"
fi

echo "*** Restore  finished"


