# imixs/backup

This Docker image provides a backup service for an Imixs-Workflow instance. The backup service backups the PSQL database and also Imixs-Workflow search index (lucene). The backups are organized in a backup directory and can be automatically transfered to a FTP server. 
The service is designed to backup only one database. In case you want to use this service to backup a complete PSQL server, than you should use the command "pg\_dumpall" instead of "pg\_dump". See the script backup.sh for details. 


## Features
* backup PSQL and files
* ftp feature to move backups to an external ftp service
* chron job
* restore feature.

## Environment
The imixs/backup image is based on the [official postgres image](https://hub.docker.com/_/postgres/).

imixs/backup provides the following environment variables which need to be set during container startup:

* SETUP\_CRON - the cron timer setting (e.g. "0 3 * * *")
* BACKUP\_SERVICE\_NAME - name of the backup service (defines the target folder on FTP space)
* BACKUP\_POSTGRES\_HOST - postgres server
* BACKUP\_POSTGRES\_USER - postres database user
* BACKUP\_POSTGRES\_PASSWORD - postgres user password
* BACKUP\_POSTGRES\_DB - postgres database 
* BACKUP\_POSTGRES\_ROLLING - number ob backup files to be kept locally
* BACKUP\_WILDFLY\_INDEX - filepath for lucen index
* BACKUP\_FTP\_HOST - ftp host 
* BACKUP\_FTP\_USER - ftp user 
* BACKUP\_FTP\_PASSWORD - ftp password 


All backups are located in the following directory 

	/root/backups/
	
Each backup file has a time stamp prefix indicating the backup time:

	2018-01-07_03:00_pgdump.sql
 
### FTP
In case the optional environment variable "BACKUP\_FTP\_HOST" is provided, the service will push backupfiles automatically into a FTP server.
The backup directory on the FTP server is

    /imixs-cloud/$BACKUP_SERVICE_NAME/....
    
The optional environment variable  "BACKUP\_SERVICE\_NAME" can be set to name the backup directory on the FTP space. If no service name is set, the docker container ID will be used instead.  


### Cron
Based on the cron settings provided in the environment variable "BACKUP\_CRON" the backup\_init script starts a cron job to schedule the backup.sh script.

Example:

     # Run every day at 03:00
     0 3 * * *   

See details [here](https://wiki.ubuntuusers.de/Cron/).

### Scripts
All backup scripts are located in the root home directory (/root/). 

 * backup_init.sh - initializes the backup service via cron
 * backup.sh - the backup script
 * restore.sh - the restore script

The scripts can be called manually:

    docker exec -it 2f4b2feaa412 /root/backup.sh

### Rolling Backup Files

The backup script automatically holds a number of backup files locally. The default number of files to be kepetd is set to 5. You can change this parameter with the environment variable "BACKUP\_POSTGRES\_ROLLING".

## Running the service

The imixs/backup service is supposed to be run as part of a docker service stack. This means that the service is included in a docker-compose.yml file which already contains PQSL Database Server and a Wildfly Application Server. 
In this scenario the wildfly service access the PSQL server via the internal overlay network. In the same way the backup service can access the database. The integration of the backup service into a docker-compose.yml file looks like this:

	...
	  backup:
	    image: imixs/backup
	    environment:
	      SETUP_CRON: "0 3 * * *"
	      BACKUP_POSTGRES_USER: "postgres"
	      BACKUP_POSTGRES_PASSWORD: "xxxxxxxxxx"
	      BACKUP_POSTGRES_HOST: "postgresoffice"
	      BACKUP_POSTGRES_ROLLING: "5"
	....


## Manual Backup

To start a backup manually from inside the container run:

	./backup.sh

You can start a manual backup from outside with the following command

	docker exec -it 82526abbabfe ls /root/backup.sh

(You need to replace the container ID with the id of your backup service.)

# Restore

All backup files are stored in the folder _/root/backups/_ and start with a time stamp in ISO format

You can verify the current available backups from outside with the command:

	docker exec -it 82526abbabfe ls -la /root/backups

(You need to replace the container ID with the id of your backup service.)

To restore a backup run the script _restore.sh_ followed by the timestamp

	./restore.sh 2018-01-05_03:00
	

**Note:** After a restore it is recommended to restart the wildfly container because wildfly uses JPA with a internal cache. To discard this cache a restore or a redeployment is needed. 


Also you can trigger a restore from outside with the command:

	docker exec -it 82526abbabfe ls -la /root/restore.sh 2018-01-05_03:00
	
## Get a Backup File form FTP

In case you need to pull a backup file from the FTP space run the ftpget.sh command:

	ftpget.sh /imixs-cloud/SERVICE-ID/BACKUPFILE BACKUPFILE

You need to specify the source file located in your ftp server. After the FTP get is completed, the file is written into the directory /root/backups/. 
You can run a restore on this file.

     
# Contribute
The source is available on [Github](https://github.com/imixs/imixs-docker). Please [report any issues](https://github.com/imixs/imixs-docker/issues).

To build the image from the Dockerfile run: 

    docker build --tag=imixs/backup .
 