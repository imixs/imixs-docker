#!/bin/bash

# *****************************************************************************************
# * This backup script backups  a given PSQL database from a remote host.                 *
# *                                                                                       *
# * The script automatically removes old backup files. With the environment variable      *
# * $BACKUP_LOCAL_ROLLING set the number of files to be hold can be specified.         *
# * The default value is 5                                                                *      
# *                                                                                       *
# * If a Backup Space is defined ($BACKUP_SPACE_HOST), the backup files will be moved     *
# * into a backup space.                                                                  *
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


# ****************************************************
# Backup PSQL database with the PSQL custom format
# ****************************************************
# We only backup one specified database here. In case you want to create a complete backup of all databases use
# pg_dumpall -c -h $BACKUP_POSTGRES_HOST -U $BACKUP_POSTGRES_USER > $BACKUP_FILE
echo "*** Backup PSQL database=$BACKUP_POSTGRES_DB"
pg_dump -h $BACKUP_POSTGRES_HOST -U $BACKUP_POSTGRES_USER -d $BACKUP_POSTGRES_DB -Fc > $BACKUP_FILE


# ****************************************************
# Remove deprecated backup files locally
# ****************************************************
# we remove the oldest backup files and keep only BACKUP_LOCAL_ROLLING files
if [ "$BACKUP_LOCAL_ROLLING" == "" ]
  then
    echo "*** set BACKUP_LOCAL_ROLLING = 5 (default)"
    BACKUP_LOCAL_ROLLING=5
fi
# first we count the existing backup files
BACKUPS_EXIST_LOCAL=$(ls -l /root/backups/*_pgdump.sql | grep -v ^l | wc -l)
# now we can remove the files if we have more than defined...
if [ "$BACKUPS_EXIST_LOCAL" -gt "$BACKUP_LOCAL_ROLLING" ] 
  then 
     # remove the deprecated backup files...
     echo "*** Backup rolling backup: keep only $BACKUP_LOCAL_ROLLING local files..."
     ls -F /root/backups/*_pgdump.sql | head -n -$BACKUP_LOCAL_ROLLING | xargs rm
fi


# ****************************************************
# Copy Backup Files into the Backup Space
# ****************************************************
if [ "$BACKUP_SPACE_HOST" != "" ]
  then 
     echo "*** Backup Space upload...."
     scp $BACKUP_FILE $BACKUP_SPACE_USER@$BACKUP_SPACE_HOST:/imixs-cloud/$BACKUP_SERVICE_NAME/
	 if [ $? -ne 0 ]
	   then 
	      echo "*** Upload into Backup Space failed"
	   else
          echo "*** Upload into Backup Space finished"
     fi
  
  
  # ****************************************************
  # Remove deprecated backup files from backup space
  # ****************************************************
  if [ "$BACKUP_SPACE_ROLLING" == "" ]
    then
     echo "*** set BACKUP_SPACE_ROLLING = 5 (default)"
      BACKUP_SPACE_ROLLING=5
  fi
  # first we count the existing backup files in the backup space
  BACKUPS_EXIST_SPACE=$(echo ls -l /imixs-cloud/$BACKUP_SERVICE_NAME/*_pgdump.sql | sftp $BACKUP_SPACE_USER@$BACKUP_SPACE_HOST | grep -v ^l | wc -l)
  # now we remove the files if we have more than defined BACKUP_SPACE_ROLLING...
  if [ "$BACKUPS_EXIST_SPACE" -gt "$BACKUP_SPACE_ROLLING" ] 
    then 
       # remove the deprecated backup files...
       echo "*** Backup Space rolling backup: keep only $BACKUP_SPACE_ROLLING files..."
       RESULT=`echo "ls -t /imixs-cloud/office-demo/*_pgdump.*" | sftp $BACKUP_SPACE_USER@$BACKUP_SPACE_HOST | grep .sql`
       
       i=0
       max=$BACKUP_SPACE_ROLLING
       while read -r line; do
          (( i++ ))
          if (( i > max )); then
              echo "DELETE $i...$line"
              echo "rm $line" | sftp $BACKUP_SPACE_USER@$BACKUP_SPACE_HOST
          fi
       done <<< "$RESULT"
  fi
else
   echo "*** No Backup Space defined - backup is only locally"  
fi

echo "*** Backup completed successfully."