#!/bin/bash

# *****************************************************************************************
# * This backup script backups  a given PSQL database from a remote host.                 *
# *                                                                                       *
# * The script automatically removes old backup files. With the env $BACKUP_POSTGRES_ROLLING  *
# * the number of files to be hold can be specified. The default value is 5               *      
# *                                                                                       *
# * Find details here: https://github.com/imixs/imixs-docker/tree/master/backup           *
# *****************************************************************************************

echo "*** Backup PSQL started...."

# make environment variables visible to cron 
source /root/backup.properties

BACKUP_DATE="$(date +%Y-%m-%d_%H:%M)"
BACKUP_FILE="backups/"$BACKUP_DATE"_pgdump.sql"
CONTAINER_ID="$(cat /proc/self/cgroup | head -n 1 | cut -d '/' -f3)"

# Backup PSQL database with the PSQL custom format
# We only backup one specified database here. In case you want to create a complete backup of all databases use
# pg_dumpall -c -h $BACKUP_POSTGRES_HOST -U $BACKUP_POSTGRES_USER > $BACKUP_FILE
echo "*** Backup PSQL database=$BACKUP_POSTGRES_DB"
pg_dump -h $BACKUP_POSTGRES_HOST -U $BACKUP_POSTGRES_USER -d $BACKUP_POSTGRES_DB -Fc > $BACKUP_FILE


# now lets remove the oldest backup files 
if [ "$BACKUP_POSTGRES_ROLLING" == "" ]
  then
    echo "*** Backup PSQL set BACKUP_POSTGRES_ROLLING = 5 (default)"
    BACKUP_POSTGRES_ROLLING=5
fi
# first we count the existing backup files
BACKUPS_EXIST=$(ls -l /root/backups/*_pgdump.sql | grep -v ^l | wc -l)
# now we remove if we have more files than defined...
if [ "$BACKUPS_EXIST" -gt "$BACKUP_POSTGRES_ROLLING" ] 
  then 
     # remove the deprecated backup files...
     echo "*** Backup PSQL rolling backup (keep $BACKUP_POSTGRES_ROLLING files)..."
     ls -F /root/backups/*_pgdump.sql | head -n -$BACKUP_POSTGRES_ROLLING | xargs rm
fi


# FTP.....
if [ "$BACKUP_FTP_HOST" != "" ]
  then 
     echo "*** Backup FTP upload...."
     ncftpput -u $BACKUP_FTP_USER -p $BACKUP_FTP_PASSWORD $BACKUP_FTP_HOST /imixs-cloud/$CONTAINER_ID/ $BACKUP_FILE
	 if [ $? -ne 0 ]
	   then 
	      echo "*** Backup FTP Upload failed"
	   else
          echo "*** Backup FTP upload finished"
     fi
fi



echo "*** Backup PSQL finished"