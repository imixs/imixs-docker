# imixs/backup

This Docker image provides a backup service for an Imixs-Workflow instance. The backup service backups the PSQL database and also Imixs-Workflow search index (lucene). The backups are organized in a backup directory and can be automatically transfered to a FTP server. 
The service is designed to backup only one database. In case you want to use this service to backup a complete PSQL server, than you should use the command "pg\_dumpall" instead of "pg\_dump". See the script backup.sh for details. 


## Features
* backup PSQL and files
* ftp feature to move backups to an external ftp service
* chron job
* restore feature.

## Environment
The imixs/backup image is based on the office [postgres image](https://hub.docker.com/_/postgres/).

imixs/backup provides the following environment variables which need to be set during container startup:

* SETUP\_CRON - the cron timer setting (e.g. "0 3 * * *")
* BACKUP\_SERVICE\_NAME - name of the backup service (defines the target folder on FTP space)
* BACKUP\_POSTGRES\_USER - postres database user
* BACKUP\_POSTGRES\_PASSWORD - postgres user password
* BACKUP\_POSTGRES\_HOST - postgres database server
* BACKUP\_POSTGRES\_ROLLING - number ob backup files to be kept locally
* BACKUP\_WILDFLY\_INDEX - filepath for lucen index
* BACKUP\_FTP\_HOST - ftp host 
* BACKUP\_FTP\_USER - ftp user 
* BACKUP\_FTP\_PASSWORD - ftp password 



All backups are located in the follwoing directory 

	/root/backups/
	
### FTP
In case a FTP Host is provided, the service will push backupfiles into a FTP server.
The backup directory on the FTP server is

    /imixs-cloud/$BACKUP_SERVICE_NAME/....
    
The $BACKUP\_SERVICE\_NAME can be provided as an environment variable. If not service name is set, the docker container ID is used instead.      	



### Cron
Based on the cron settings provided in the environment variable "BACKUP\_CRON" the backup\_init script adds a cron job to run the backu.sh script.

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

The backup script automatically holds a number of backup files locally. The default number of files to be keped is set to 5. You can cange this parameter with the environment variable "BACKUP\_POSTGRES\_ROLLING". 

## Running the service

The imixs/backup service is supposed to be run as part of a docker service stack. This means that the service is included in a docker-compose.yml file which already contains PQSL Database Server and a Wildfly Application Server. 
In this scenario the wildfly service access the PSQL server via the internal overlay network. In the same way the backup service can access the database. The integration of the backup service into a docker-compose.yml file looks like this:

	...
	  backup:
	    image: imixs/backup
	    environment:
	      SETUP_CRON: "0 3 * * *"
	      BACKUP_POSTGRES_USER: "postgres"
	      BACKUP_POSTGRES_PASSWORD: "adminadmin"
	      BACKUP_POSTGRES_HOST: "postgresoffice"
	      BACKUP_POSTGRES_ROLLING: "5"
	....

# Restore

All backup files are stored in the folder _backups/_ and start with a time stamp in ISO format
To restore a backup run the script _restore.sh_ with the timestamp

	./restore.sh 2018-01-05_03:00

**Note:** After a restore it is recommended to restart the wildfly container because wildfly uses JPA with a internal cache. To discard this cache a restore or a redeployment is needed. 
     
# Contribute
The source is available on [Github](https://github.com/imixs/imixs-docker). Please [report any issues](https://github.com/imixs/imixs-docker/issues).

To build the image from the Dockerfile run: 

    docker build --tag=imixs/backup .
 