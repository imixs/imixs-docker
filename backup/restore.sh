#!/bin/bash

# *****************************************************************************************
# * The Restore script restores a MYSQL/PSQL database and backup data from a              *
# * docker volume shared by the container.                                             	  *
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
    echo "*** No arguments supplied, restore last backup..."
    # determine last backup file
    BACKUP_FILE=$(ls -F /root/backups/*_dump.tar.gz | tail -n 1)
  else
    echo "*** Restore dump.tar.gz from $1"
    BACKUP_FILE="/root/backups/$1_dump.tar.gz"
    
    
    # extract content into temp.....
    mkdir -p /root/backups/tmp
    
    
    echo " WE NEED TO FIX THIS ! - DB_TYPE! "
    #pg_restore -c -h $BACKUP_DB_HOST -U $BACKUP_DB_USER -Fc -d $BACKUP_DB_DB  /root/backups/$1_dump.tar.gz
    
    # clean up temp folder
    #rm -R /root/backups/tmp/*
    
    echo "*** Restore  finished"
     
fi

echo "backup file = " $BACKUP_FILE
