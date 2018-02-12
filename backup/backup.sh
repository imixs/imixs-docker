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
BACKUP_FILE="/root/backups/"$BACKUP_DATE"_pgdump.sql"

# Test if we have a service name, if not we default to the contaner id...
if [ "$BACKUP_SERVICE_NAME" == "" ]
  then
    CONTAINER_ID="$(cat /proc/self/cgroup | head -n 1 | cut -d '/' -f3)"
    echo "*** Backup Service Name not set - default to container ID $CONTAINER_ID"
    BACKUP_SERVICE_NAME=$CONTAINER_ID
fi


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


# Transfer to Backup Space.....
if [ "$BACKUP_SPACE_HOST" != "" ]
  then 
     echo "*** Backup Space upload...."
     
     # scp foobar.txt your_username@remotehost.edu:/some/remote/directory
     scp $BACKUP_FILE $BACKUP_SPACE_USER@$BACKUP_SPACE_HOST:/imixs-cloud/$BACKUP_SERVICE_NAME/
     # ncftpput -u "$BACKUP_SPACE_USER" -p "$BACKUP_FTP_PASSWORD" -m $BACKUP_SPACE_HOST /imixs-cloud/$BACKUP_SERVICE_NAME/ $BACKUP_FILE
	 if [ $? -ne 0 ]
	   then 
	      echo "*** Upload into Backup Space failed"
	   else
          echo "*** Upload into Backup Space finished"
     fi
fi



echo "*** Backup PSQL finished"