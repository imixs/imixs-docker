# imixs/backup

This Docker image provides a backup service for an Imixs-Workflow instance. The backup service can backup the PSQL database and also Imixs-Workflow search index (lucene). The backups are organized in a backup directory and can be automatically transfered to a FTP server. 


## Features
* backup PSQL and files
* ftp feature to move backups to an external ftp service
* chron job
* restore feature.

## Environment
The imixs/backup image is based on the office [postgres image](https://hub.docker.com/_/postgres/).

imixs/backup provides the following environment variables which need to be set during container startup:

* BACKUP\_CRON - the cron timer setting (e.g. "0 3 * * *")
* BACKUP\_POSTGRES\_USER - postres database user
* BACKUP\_POSTGRES\_PASSWORD - postgres user password
* BACKUP\_POSTGRES\_HOST - postgres database server
* BACKUP\_WILDFLY\_INDEX - filepath for lucen index


### Backup Scripts
All backup scripts are located in the root home directory (/root/). 

 * backup_init.sh - initializes the backup service via cron
 * backup.sh - the backup script

### Cron
Based on the cron settings provided in the environment variable "BACKUP\_CRON" the backup\_init script adds a cron job to run the backu.sh script.

Example:

     # Run every day at 03:00
     0 3 * * *   

See details [here](https://wiki.ubuntuusers.de/Cron/).


## Running the service

The imixs/backup service is supposed to be run as part of a docker service stack. This means that the service is included in a docker-compose.yml file which already contains PQSL Database Server and a Wildfly Application Server. 
In this scenario the wildfly service access the PSQL server via the internal overlay network. In the same way the backup service can access the database. The integration of the backup service into a docker-compose.yml file looks like this:

	...
	  backup:
	    image: imixs/backup
	    environment:
	      BACKUP_CRON: "0 3 * * *"
	      BACKUP_POSTGRES_USER: "postgres"
	      BACKUP_POSTGRES_PASSWORD: "adminadmin"
	      BACKUP_POSTGRES_HOST: "postgresoffice"
	....

# Restore

All backup files are stored in the folder _backups/_ and start with a time stamp in ISO format
To restore a backup run the script _restore.sh_ with the timestamp

	./restore.sh 2018-01-05_03:00exti

     
# Contribute
The source is available on [Github](https://github.com/imixs/imixs-docker). Please [report any issues](https://github.com/imixs/imixs-docker/issues).

To build the image from the Dockerfile run: 

    docker build --tag=imixs/backup .
 