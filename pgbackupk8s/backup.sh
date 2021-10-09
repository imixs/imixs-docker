#!/bin/bash

# *****************************************************************************************
# * The backup script backups a given PSQL database within a Kubernetes deployment.       *
# *                                                                                       *
# * If a Backup Space is defined ($FTP_HOST), the backup files will be moved     *
# * into a backup space.  The environment variable $BACKUP_LOCAL_ROLLING defines how      *
# * many backup files will be hold on the backup space.                                   *
# *                                                                                       *
# * Find details here: https://github.com/imixs/imixs-docker/tree/master/backup           *
# *****************************************************************************************


BACKUP_DATE="$(date +%Y-%m-%d_%H%M)" 
DB_FILE='~/db.sql' 
BACKUP_FILE='~/'$POSTGRES_DB'_'$BACKUP_DATE'.tar.gz'

# Backup database...
echo '******** start pgbackup  ********'
echo ...database=$POSTGRES_DB .... 
echo ...create .pgpass  
echo "$POSTGRES_HOST:5432:$POSTGRES_DB:$POSTGRES_USER:$POSTGRES_PASSWORD" > ~/.pgpass 
chmod 600 ~/.pgpass 
echo "...pg_dump..." 
pg_dump -h$POSTGRES_HOST -U$POSTGRES_USER $POSTGRES_DB -Fc > $DB_FILE 
echo "...pg_dump finished" 
ls -lah $DB_FILE

# tar backup file
echo "...tar backup...."
tar -czf $BACKUP_FILE $DB_FILE
rm $DB_FILE
ls -lah $BACKUP_FILE

	
# ****************************************************
# Copy Backup into the Backup Space
# ****************************************************
echo "...start ftp transfer..." 
if [ "$BACKUP_ROOT_DIR" == "" ]
  then
     # If the Backup root dir is not specified, it will use the default root /...
     echo "***        ...Environment variable BACKUP_ROOT_DIR not set, using default / folder..."
     BACKUP_ROOT_DIR="/"
fi

if [ "$FTP_HOST" != "" ]
  then 
     echo "***        ...upload to backup space..."
     
     sftp $FTP_USER@$FTP_HOST > /dev/null << SFTPEOF 
       cd /$BACKUP_ROOT_DIR/$BACKUP_SERVICE_NAME/
       put $BACKUP_FILE 
       quit
SFTPEOF
  

  
  # ****************************************************
  # Remove deprecated backup files from backup space
  # ****************************************************

  # first we count the existing backup files in the backup space
  BACKUPS_EXIST_SPACE=$(echo ls -l /$BACKUP_ROOT_DIR/$BACKUP_SERVICE_NAME/*_dump.tar.gz | sftp $FTP_USER@$FTP_HOST | grep -v ^l | wc -l)
  # now we remove the files if we have more than defined BACKUP_SPACE_ROLLING...
  if [ "$BACKUPS_EXIST_SPACE" -gt "$BACKUP_SPACE_ROLLING" ] 
    then 
       # get a list of all dump files (tricky command because ls -t does not work)...
       RESULT=`echo "ls /$BACKUP_ROOT_DIR/$BACKUP_SERVICE_NAME/*_dump.*" | sftp $FTP_USER@$FTP_HOST | grep .tar.gz | sort -Vr`
       
       # remove the deprecated backup files...
       i=0
       max=$BACKUP_SPACE_ROLLING
       while read line; do
          (( i++ ))
          if (( i > max )); then
              echo "***        ...clean deprecated remote dump $line..."
              echo "rm $line" | sftp $FTP_USER@$FTP_HOST
          fi
       done <<< "$RESULT"
  fi
else
   echo "***        no backup space defined - backup only locally."  
fi

echo '******** backup completed    ********'


