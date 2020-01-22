# imixs/backup

This Docker image provides a backup service to backup a PostgreSQL or MySQL database of a docker volume. 
The service can be added into a docker stack with an PSQL or MySQL instance to backup the database periodically. 
The service also backups optional files from a mounted docker volume. 

All backup files are organized in a backup directory and can optional be transfered into a backup space. 
The service is designed to backup only one database. In case you want to use this service to backup a complete PSQL or MySQL server, than you should use the command "pg\_dumpall" instead of "pg\_dump". See the script backup.sh for details. 


## Features
* backup PostgreSQL or MySQL database
* backup file content from a docker volume
* sftp/scp support to move backups to an external backup space
* chron job
* restore feature.

## Environment
The imixs/backup image is based on the [official postgres image](https://hub.docker.com/_/postgres/) with additional mariadb-client support.

imixs/backup provides the following environment variables which need to be set during container startup:

* SETUP\_CRON - the cron timer setting (e.g. "0 3 * * *")
* BACKUP\_SERVICE\_NAME - name of the backup service (defines the target folder on FTP space)
* BACKUP\_DB\_HOST - datbase server
* BACKUP\_DB\_USER - database user
* BACKUP\_DB\_PASSWORD - database user password
* BACKUP\_DB\_TYPE - set to 'MYSQL' or 'POSTGRESQL' 
* BACKUP\_DB - the postgres or mysql database name 
* BACKUP\_VOLUME - optional file directory from a mapped docker volume  
* BACKUP\_SPACE\_HOST - backup space connected via SFTP/SCP 
* BACKUP\_SPACE\_USER - backup space user 
* BACKUP\_LOCAL\_ROLLING - number of backup files to be kept locally
* BACKUP\_SPACE\_ROLLING - number of backup files to be kept in the backup space
* BACKUP\_ROOT\_DIR - backup root directory (e.g. "/imixs-cloud", default if not set will be "/imixs-cloud")

All backups are located in the following local directory 

	/root/backups/

In the backup space, the files are located at:

	/$BACKUP_ROOT_DIR/$BACKUP_SERVICE_NAME/
	
Each backup file has a time stamp prefix indicating the backup time:

	2018-01-07_03:00_dump.tar.gz
 


### Cron
Based on the _cron_ settings provided in the environment variable "BACKUP\_CRON" the backup\_init script starts a cron job to schedule the backup.sh script.

Example:

     # Run every day at 03:00
     0 3 * * *   

See details [here](https://wiki.ubuntuusers.de/Cron/).

### Scripts
All backup scripts are located in the root home directory (/root/). 

 * backup_init.sh - initializes the backup service via cron
 * backup.sh - the backup script
 * restore.sh - the restore script
 * backup_get.sh - to get a file form the remote backup space

The scripts can be called manually:

	$ docker exec -it 2f4b2feaa412 /root/backup.sh

### Rolling Backup Files

The backup script automatically holds a number of backup files locally. The default number of files to keep is set to 5. You can change this parameter with the environment variable "BACKUP\_LOCAL\_ROLLING".



## The Backup Space
In case the optional environment variable "BACKUP\_SPACE\_HOST" is provided, the service will push backup files automatically into a backup space via SFTP/SCP.
The backup directory on the backup space is

    /$BACKUP_ROOT_DIR/$BACKUP_SERVICE_NAME/....
    
The optional environment variable  "BACKUP\_SERVICE\_NAME" can be set to name the backup directory on the backup space. If no service name is set, the docker container ID will be used instead.  

In case the optional environment variable "BACKUP\_SPACE\_HOST" is provided, the environment variable  "BACKUP\_ROOT\_DIR" can be set to name the backup directory on the backup space, otherwise it will be used the default "/imixs-cloud" folder.  

#### Create a SSH Key

To transfers files to the backup space this service uses SFTP/SCP. For this reason a RFC4716 Public Key need to be provided on the backup space. 

The backup service expects that a private key file is provided by a [docker secret](https://docs.docker.com/engine/swarm/secrets/). Docker secrets can be used only in docker swarm. So in this case you are forced to run the backup service in a docker swarm. 

To copy a ssh key provided in the file _/root/.ssh/backupspace_rsa_ into a docker secret run:

	docker secret create backupspace_key /root/.ssh/backupspace_rsa


You can add the key as an environment variable to the stack definition:

	version: '3.1'
	
	services:
	....
	   backup:
	    image: imixs/backup:latest
	    environment:
	     .....
	     BACKUP_SPACE_KEY_FILE: "/run/secrets/backupspace_key"
       secrets:
         ...
         - backupspace_key
	....
	 secrets:
	   backupspace_key:
	     external: true
	....

	     


## How to Deploy the Service

The imixs/backup service is supposed to be run as part of a docker service stack. This means that the service is included in a docker-compose.yml file which already contains PQSL or MYSQL Database Server and optional a mounted volume. The database service is typically bound using an internal network.
 
The following example shows a service definition of the backup service to backup a Wordpress Service with a MySQL database and a volume named 'wp-content' containing the wordpress content. 



	...
	  backup:
	    image: imixs/backup:1.2.1
	    environment:
	      SETUP_CRON: "0 4 * * *"
	      BACKUP_SERVICE_NAME: "my-service"
	      BACKUP_DB_USER: "wordpress_dms"
	      BACKUP_DB_PASSWORD: "xxxxxxxxxxx"
	      BACKUP_DB_HOST: "db"
	      BACKUP_DB_TYPE: "MYSQL"
	      BACKUP_DB: "wordpress"
	      BACKUP_VOLUME: "/var/www/html/wp-content"
	      BACKUP_LOCAL_ROLLING: "5"
	    volumes: 
	      - wp-content:/var/www/html/wp-content
	    networks:
	      - backend
	    volumes: 
	      - wp-content:/var/www/html/wp-content
      	....

If you add a backup space the following optional environment settings are needed:


	....
	      BACKUP_SERVICE_NAME: "my-app"
	      BACKUP_SPACE_HOST: "my-backup.org"
	      BACKUP_SPACE_USER: "yyyy"
	      BACKUP_SPACE_KEY_FILE: "/run/secrets/backupspace_key"
	      BACKUP_ROOT_DIR: "/imixs-cloud"
	....

If you want to backup file directories form a mounted volume:


	....
	      BACKUP_VOLUME: "/home/imixs" 
	    volumes: 
         - appdata:/home/imixs
    ....
    
    
## Manual Backup

A backup can be started manually by the backup script. The backup script can be run either from outside the container: 

	$ docker exec -it 82526abbabfe /root/backup.sh

(You need to replace the container ID with the id of your backup service.)

or you can first log into the backup container with: 

	$ docker exec -it 82526abbabfe bash

(You need to replace the container ID with the id of your backup service.)

and than start the backup script directly:  

	root@82526abbabfe:/# /root/backup.sh

To list all locally available backups run:

	ls -la /root/backups


# Restore

The Backup Service provides scripts to restore and load backup files. All scripts can be started either from outside the container: 

	docker exec -it 82526abbabfe [SCRIPT]

(You need to replace the container ID with the id of your backup service.)

or you can first log into the backup container with: 

	docker exec -it 82526abbabfe bash

(You need to replace the container ID with the id of your backup service.)

and than start the scripts directly.

## Restore Local Backup Files:

All backup files are stored in the folder _/root/backups/_. The files include a time stamp in ISO format indicating the backup time. 

To list all locally available backups run:

	ls -la /root/backups

To restore the latest backup run:

	/root/restore.sh

To restore a specific backup run the script _restore.sh_ followed by the timestamp of the backupfile: 

	/root/restore.sh 2018-01-05_03:00


	
## Restore Remote Backup Files:

In case you have no local backup files available, you can pull a backup file first from the backup space.

Run the following command to get a list of all backup files available on the backupspace:

	echo ls -la /$BACKUP_ROOT_DIR/$BACKUP_SERVICE_NAME | sftp $BACKUP_SPACE_USER@$BACKUP_SPACE_HOST

You can pull a specific backup file with the script backup_get.sh followed by the filename:

	/root/backup_get.sh /$BACKUP_ROOT_DIR/$BACKUP_SERVICE_NAME/[BACKUPFILE]


The remote backupfile will be written to the directory /root/backups/.  Now you can restore the backup as explained before. 

     
     
# Contribute
The source is available on [Github](https://github.com/imixs/imixs-docker). Please [report any issues](https://github.com/imixs/imixs-docker/issues).

To build the image from the Dockerfile run: 

    docker build --tag=imixs/backup .
 