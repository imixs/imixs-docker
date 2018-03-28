#!/bin/bash

echo "========================================================================="
echo "Initalize backup service....."
echo "cron = $SETUP_CRON"
echo "========================================================================="


# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
		exit 1
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(< "${!fileVar}")"
	fi
	export "$var"="$val"
	unset "$fileVar"
}

# get Docker secrets....
file_env 'BACKUP_DB_PASSWORD'


# export all environment variables starting with 'BACKUP_' to be used by cron 
env | sed 's/^\(.*\)$/export \1/g' | grep -E "^export BACKUP_" > /root/backup.properties
chmod +x /root/backup.properties


# create psql password file so pgdump runs without password prompt...
echo "$BACKUP_DB_HOST:*:*:$BACKUP_DB_USER:$BACKUP_DB_PASSWORD" >> ~/.pgpass 
chmod 0600 ~/.pgpass

# create MySQL password file so mysqldump runs without password prompt...
echo "[mysqldump]" >> ~/.my.cnf
echo "user=$BACKUP_DB_USER" >> ~/.my.cnf
echo "password=$BACKUP_DB_PASSWORD" >> ~/.my.cnf
chmod 0600 ~/.my.cnf


# copy the ssh key for backup space if defined...
if [ -f /run/secrets/backupspace_key ]
then
	mkdir /root/.ssh/
	cp /run/secrets/backupspace_key /root/.ssh/id_rsa
	chmod 600 /root/.ssh/id_rsa
	echo "# Custom ssh settings" > /root/.ssh/config
	echo "Host *" >> /root/.ssh/config
	echo "    StrictHostKeyChecking no" >> /root/.ssh/config
	chmod 400 /root/.ssh/config
	
	# create the target dir....
sftp $BACKUP_SPACE_USER@$BACKUP_SPACE_HOST << SFTPEOF 
          mkdir /imixs-cloud
          mkdir /imixs-cloud/$BACKUP_SERVICE_NAME/
          quit
SFTPEOF
	
fi


# create backup-cron file...
echo "$SETUP_CRON root /root/backup.sh > /proc/1/fd/1 2>/proc/1/fd/2" > /etc/cron.d/backup-cron
chmod 0644 /etc/cron.d/backup-cron

echo "Initalize backup service completed."
echo "Starting cron...."

# Run cron.....
cron -f