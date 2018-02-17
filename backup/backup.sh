#!/bin/bash

# *****************************************************************************************
# * This backup script backups  a given PSQL database from a remote host.                 *
# *                                                                                       *
# * The script automatically removes old backup files. With the environment variable      *
# * $BACKUP_LOCAL_ROLLING set the number of files to be hold can be specified.            *
# * The default value is 5                                                                *      
# *                                                                                       *
# * If a Backup Space is defined ($BACKUP_SPACE_HOST), the backup files will be moved     *
# * into a backup space.  The environment variable $BACKUP_LOCAL_ROLLING defines how      *
# * many backup files will be hold on the backup space.                                   *
# *                                                                                       *
# * Find details here: https://github.com/imixs/imixs-docker/tree/master/backup           *
# *****************************************************************************************

echo "*** Backup started...."

# make environment variables visible to cron 
source /root/backup.properties

BACKUP_DATE="$(date +%Y-%m-%d_%H:%M)"
BACKUP_FILE="/root/backups/"$BACKUP_DATE"_pgdump.sql"

# Test if we have a service name, if not we default to the contaner id...
if [ "$BACKUP_SERVICE_NAME" == "" ]
  then
    CONTAINER_ID="$(cat /proc/self/cgroup | head -n 1 | cut -d '/' -f3)"
    echo "***        no service name set, default to container ID=$CONTAINER_ID"
    BACKUP_SERVICE_NAME=$CONTAINER_ID
fi
echo "***        BACKUP_SERVICE_NAME=$BACKUP_SERVICE_NAME"

# Test rolling backup..
if [ "$BACKUP_LOCAL_ROLLING" == "" ]
  then
    # set default
    BACKUP_LOCAL_ROLLING=5
fi
echo "***        BACKUP_LOCAL_ROLLING=$BACKUP_LOCAL_ROLLING"
if [ "$BACKUP_SPACE_ROLLING" == "" ]
  then
    BACKUP_SPACE_ROLLING=5
fi
echo "***        BACKUP_SPACE_ROLLING=$BACKUP_SPACE_ROLLING"
  


# ****************************************************
# Backup PSQL database with the PSQL custom format
# ****************************************************
# We only backup one specified database here. In case you want to create a complete backup of all databases use
# pg_dumpall -c -h $BACKUP_POSTGRES_HOST -U $BACKUP_POSTGRES_USER > $BACKUP_FILE
echo "***        database=$BACKUP_POSTGRES_DB"
echo "***        filename=$BACKUP_FILE"
echo "***        ...dump database"
pg_dump -h $BACKUP_POSTGRES_HOST -U $BACKUP_POSTGRES_USER -d $BACKUP_POSTGRES_DB -Fc > $BACKUP_FILE

BACKUP_FILESIZE=$(ls -l -h $BACKUP_FILE | cut -d " " -f5) 
echo "***        filesize = $BACKUP_FILESIZE bytes."


# ****************************************************
# Remove deprecated backup files locally
# ****************************************************
# we remove the oldest backup files and keep only BACKUP_LOCAL_ROLLING files

# first we count the existing backup files
BACKUPS_EXIST_LOCAL=$(ls -l /root/backups/*_pgdump.sql | grep -v ^l | wc -l)
# now we can remove the files if we have more than defined...
if [ "$BACKUPS_EXIST_LOCAL" -gt "$BACKUP_LOCAL_ROLLING" ] 
  then 
     # remove the deprecated backup files...
     echo "***        ...clean deprecated local backup files..."
     ls -F /root/backups/*_pgdump.sql | head -n -$BACKUP_LOCAL_ROLLING | xargs rm
fi


# ****************************************************
# Copy Backup Files into the Backup Space
# ****************************************************
if [ "$BACKUP_SPACE_HOST" != "" ]
  then 
     echo "***        ...upload to backup space..."
     scp $BACKUP_FILE $BACKUP_SPACE_USER@$BACKUP_SPACE_HOST:/imixs-cloud/$BACKUP_SERVICE_NAME/
	 if [ $? -ne 0 ]
	   then 
	      echo "***        ...upload into backup space failed!"
     fi
  
  
  # ****************************************************
  # Remove deprecated backup files from backup space
  # ****************************************************

  # first we count the existing backup files in the backup space
  BACKUPS_EXIST_SPACE=$(echo ls -l /imixs-cloud/$BACKUP_SERVICE_NAME/*_pgdump.sql | sftp $BACKUP_SPACE_USER@$BACKUP_SPACE_HOST | grep -v ^l | wc -l)
  # now we remove the files if we have more than defined BACKUP_SPACE_ROLLING...
  if [ "$BACKUPS_EXIST_SPACE" -gt "$BACKUP_SPACE_ROLLING" ] 
    then 
       # remove the deprecated backup files...
       RESULT=`echo "ls -t /imixs-cloud/office-demo/*_pgdump.*" | sftp $BACKUP_SPACE_USER@$BACKUP_SPACE_HOST | grep .sql`
       
       i=0
       max=$BACKUP_SPACE_ROLLING
       while read -r line; do
          (( i++ ))
          if (( i > max )); then
              echo "***        ...clean deprecated remote backup file $line..."
              echo "rm $line" | sftp $BACKUP_SPACE_USER@$BACKUP_SPACE_HOST
          fi
       done <<< "$RESULT"
  fi
else
   echo "***        no backup space defined - backup only locally."  
fi

echo "*** Backup completed successfully."