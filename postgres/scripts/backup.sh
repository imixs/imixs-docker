#!/bin/bash

# *****************************************************************************************
# * The backup script backups a given MYSQL/PSQL database from a docker container.       *
# * The script can also backup data from a docker volume shared by the container.         *
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

echo "========================================================================="
echo "Starting Backup...."
echo "========================================================================="

# make environment variables visible to cron 
source /root/backup.properties

BACKUP_DATE="$(date +%Y-%m-%d_%H:%M)"
BACKUP_FILE="/root/backups/"$BACKUP_DATE"_dump.tar.gz"
DB_FILE="/root/backups/db.sql"

echo "***        Backup filename=$BACKUP_FILE"


# Test if we have a service name, if not we default to the container id...
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

# Backup volume...
echo "***        BACKUP_VOLUME = $BACKUP_VOLUME"

# Test database type (MYSQL/POSTGRESQL)  
if [ "$BACKUP_DB_TYPE" == "MYSQL" ] || [ "$BACKUP_DB_TYPE" == "POSTGRESQL" ] ; then
    echo "***        BACKUP_DB_TYPE = $BACKUP_DB_TYPE"
    echo "***        BACKUP_DB = $BACKUP_DB"
	echo "***        starting database dump..."

	if [ "$BACKUP_DB_TYPE" == "POSTGRESQL" ] 
	  then
		# ****************************************************
		# Backup PostgreSQL database with the PSQL custom format 
		# - password is provided by backup_init script
		# ****************************************************
		# We only backup one specified database here. In case you want to create a complete backup of all databases use
		# pg_dumpall -c -h $BACKUP_POSTGRES_HOST -U $BACKUP_POSTGRES_USER > $BACKUP_FILE
		pg_dump -h $BACKUP_DB_HOST -U $BACKUP_DB_USER -d $BACKUP_DB -Fc > $DB_FILE
	fi
	
	if [ "$BACKUP_DB_TYPE" == "MYSQL" ] 
	  then
		# ****************************************************
		# Backup MySQL database with the PSQL custom format
		# - password is provided by backup_init script
		# ****************************************************
		mysqldump -h $BACKUP_DB_HOST -u $BACKUP_DB_USER $BACKUP_DB > $DB_FILE
	fi
	echo "***        ...database dump finished! "

else
    echo "***        WARNING: unsupported database type = $BACKUP_DB_TYPE"
fi



# ****************************************************
# Create tar ball......
# ****************************************************
if [ "$BACKUP_VOLUME" == "" ] 
  then
	# backup sql dump only
	tar -czf $BACKUP_FILE $DB_FILE
  else
	# backup db with volume
	tar -czf $BACKUP_FILE $DB_FILE $BACKUP_VOLUME
fi
# remove .sql tmp file
rm /root/backups/db.sql
BACKUP_FILESIZE=$(ls -l -h $BACKUP_FILE | cut -d " " -f5) 
echo "***        filesize = $BACKUP_FILESIZE bytes."




# ****************************************************
# Remove deprecated backup files locally
# ****************************************************
# we remove the oldest backup files and keep only BACKUP_LOCAL_ROLLING files

# first we count the existing backup files
BACKUPS_EXIST_LOCAL=$(ls -l /root/backups/*_dump.tar.gz | grep -v ^l | wc -l)
# now we can remove the files if we have more than defined...
if [ "$BACKUPS_EXIST_LOCAL" -gt "$BACKUP_LOCAL_ROLLING" ] 
  then 
     # remove the deprecated backup files...
     echo "***        ...clean deprecated local dumps..."
     ls -F /root/backups/*_dump.tar.gz | head -n -$BACKUP_LOCAL_ROLLING | xargs rm
fi


# ****************************************************
# Copy Backup Files into the Backup Space
# ****************************************************
if [ "$BACKUP_SPACE_HOST" != "" ]
  then 
     echo "***        ...upload to backup space..."
     
     sftp $BACKUP_SPACE_USER@$BACKUP_SPACE_HOST > /dev/null << SFTPEOF 
       cd /imixs-cloud/$BACKUP_SERVICE_NAME/
       put $BACKUP_FILE 
       quit
SFTPEOF
     
  
  # ****************************************************
  # Remove deprecated backup files from backup space
  # ****************************************************

  # first we count the existing backup files in the backup space
  BACKUPS_EXIST_SPACE=$(echo ls -l /imixs-cloud/$BACKUP_SERVICE_NAME/*_dump.tar.gz | sftp $BACKUP_SPACE_USER@$BACKUP_SPACE_HOST | grep -v ^l | wc -l)
  # now we remove the files if we have more than defined BACKUP_SPACE_ROLLING...
  if [ "$BACKUPS_EXIST_SPACE" -gt "$BACKUP_SPACE_ROLLING" ] 
    then 
       # get a list of all dump files (tricky command because ls -t does not work)...
       RESULT=`echo "ls /imixs-cloud/$BACKUP_SERVICE_NAME/*_dump.*" | sftp $BACKUP_SPACE_USER@$BACKUP_SPACE_HOST | grep .tar.gz | sort -Vr`
       
       # remove the deprecated backup files...
       i=0
       max=$BACKUP_SPACE_ROLLING
       while read line; do
          (( i++ ))
          if (( i > max )); then
              echo "***        ...clean deprecated remote dump $line..."
              echo "rm $line" | sftp $BACKUP_SPACE_USER@$BACKUP_SPACE_HOST
          fi
       done <<< "$RESULT"
  fi
else
   echo "***        no backup space defined - backup only locally."  
fi

echo "*** Backup completed successfully."