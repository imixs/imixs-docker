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

echo '******** start pgrestore  ********'


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


echo "..get backup file from ftp space...."
mkdir -p /root/backups/

if [ "$RESTORE_FILE" == "" ]
  then
    echo "...restore failed - 'RESTORE_FILE' is not specified!"
  else
    echo "...ftp get file= $RESTORE_FILE"
    scp $FTP_USER@$FTP_HOST:$RESTORE_FILE /root/backups/dump_sql.gz
    echo "...ftp get sucessfull"
fi

echo "....list files"
ls -lsh /root/backups/

# Create .pgpass
echo "...create .pgpass  "
echo "$POSTGRES_HOST:$POSTGRES_PORT:$POSTGRES_DB:$POSTGRES_USER:$POSTGRES_PASSWORD" > ~/.pgpass 
chmod 600 ~/.pgpass 

# Restore database...
echo "...restore database $POSTGRES_DB ..." 
pg_restore -v -c -h$POSTGRES_HOST -p$POSTGRES_PORT -U$POSTGRES_USER -d$POSTGRES_DB  /root/backups/dump_sql.gz

echo '******** restore completed    ********'


