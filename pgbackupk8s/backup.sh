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

echo '******** start pgbackup  ********'
BACKUP_DATE="$(date +%Y-%m-%d_%H%M)" 
DB_FILE='/root/db.sql' 
BACKUP_FILE='/root/'$POSTGRES_DB'_'$BACKUP_DATE'_sql.gz'

# determine namespace.....
NAMESPACE=$(< /var/run/secrets/kubernetes.io/serviceaccount/namespace)
echo '...namespace='$NAMESPACE





# copy the ssh key for backup space if defined...
if [ -f $SSH_KEY ]
then
    echo "...copy ssh key "$SSH_KEY
	mkdir /root/.ssh/
	cp $SSH_KEY /root/.ssh/id_rsa
	chmod 600 /root/.ssh/id_rsa
	echo "# Custom ssh settings" > /root/.ssh/config
	echo "Host *" >> /root/.ssh/config
	echo "    StrictHostKeyChecking no" >> /root/.ssh/config
	chmod 400 /root/.ssh/config
else
    echo "...no ssh key provided"
fi

# Backup database...
echo "...database=$POSTGRES_DB ...." 
echo "...create .pgpass  "
echo "$POSTGRES_HOST:$POSTGRES_PORT:$POSTGRES_DB:$POSTGRES_USER:$POSTGRES_PASSWORD" > ~/.pgpass 
chmod 600 ~/.pgpass 
echo "...pg_dump database $POSTGRES_HOST:$POSTGRES_PORT:$POSTGRES_DB..." 
pg_dump -h$POSTGRES_HOST -p$POSTGRES_PORT -U$POSTGRES_USER -d$POSTGRES_DB -v -Fc > $BACKUP_FILE
ls -lah $BACKUP_FILE

	
# ****************************************************
# Copy Backup into the Backup Space
# ****************************************************
echo "...start ftp transfer..." 
if [ "$BACKUP_ROOT_DIR" == "" ]
  then
     # If the Backup root dir is not specified, it will use the default root /...
     echo "...Environment variable BACKUP_ROOT_DIR not set, using default / folder..."
     BACKUP_ROOT_DIR="/"
fi

if [ "$BACKUP_MAX_ROLLING" == "" ]
  then
     # set default
     BACKUP_MAX_ROLLING=5
     echo "...BACKUP_MAX_ROLLING="$BACKUP_MAX_ROLLING     
fi


if [ "$FTP_HOST" != "" ]
  then      
     echo "...ftp backup directory="$BACKUP_ROOT_DIR
     sftp $FTP_USER@$FTP_HOST > /dev/null << SFTPEOF 
       cd /$BACKUP_ROOT_DIR/$NAMESPACE/
       put $BACKUP_FILE 
       quit
SFTPEOF
  
  # ****************************************************
  # Remove deprecated backup files from backup space
  # ****************************************************
  echo "...clean up deprecated backups..."
  # first we count the existing backup files in the backup space
  BACKUPS_EXIST_SPACE=$(echo ls -l /$BACKUP_ROOT_DIR/$NAMESPACE/*_sql.gz | sftp $FTP_USER@$FTP_HOST | grep -v ^l | wc -l)
  # now we remove the files if we have more than defined BACKUP_MAX_ROLLING...
  if [ "$BACKUPS_EXIST_SPACE" -gt "$BACKUP_MAX_ROLLING" ] 
    then 
       echo "...clean deprecated backupfiles (max roling backups=$BACKUP_MAX_ROLLING)..."
       # get a list of all backup files (tricky command because ls -t does not work)...
       RESULT=`echo "ls /$BACKUP_ROOT_DIR/$NAMESPACE/*_sql.gz" | sftp $FTP_USER@$FTP_HOST | grep .gz | sort -Vr`
       # remove the deprecated backup files...
       i=0
       max=$BACKUP_MAX_ROLLING
       while read line; do
          (( i++ ))
          if (( i > max )); then
              echo "rm $line" | sftp $FTP_USER@$FTP_HOST
          fi
       done <<< "$RESULT"
  fi
else
   echo "...no ftp backup defined!"  
fi

echo '******** backup completed    ********'


