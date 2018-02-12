# imixs/backup

This Docker image provides a backup service to backup a PSQL database. The service can be combinded with an Imixs-Workflow instance to backup the database periodically. 
All backup files are organized in a backup directory and will be automatically transfered to a backup space. 
The service is designed to backup only one database. In case you want to use this service to backup a complete PSQL server, than you should use the command "pg\_dumpall" instead of "pg\_dump". See the script backup.sh for details. 


## Features
* backup PSQL and files
* sftp/scp support to move backups to an external backup space
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
* BACKUP\_POSTGRES\_ROLLING - number of backup files to be kept locally
* BACKUP\_WILDFLY\_INDEX - filepath for lucen index
* BACKUP\_SPACE\_HOST - backup space connected via SFTP/SCP 
* BACKUP\_SPACE\_USER - backup space user 
* BACKUP\_SPACE\_ROLLING - number of backup files to be kept in the backup space


All backups are located in the following directory 

	/root/backups/
	
Each backup file has a time stamp prefix indicating the backup time:

	2018-01-07_03:00_pgdump.sql
 


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



## The Backup Space
In case the optional environment variable "BACKUP\_SPACE\_HOST" is provided, the service will push backup files automatically into a backup space via SFTP/SCP.
The backup directory on the backup space is

    /imixs-cloud/$BACKUP_SERVICE_NAME/....
    
The optional environment variable  "BACKUP\_SERVICE\_NAME" can be set to name the backup directory on the backup space. If no service name is set, the docker container ID will be used instead.  

#### Create a SSH Key

To transfers files to the backup space via SFTP/SCP. For this reason a RFC4716 Public Key need to be provided on the backup space. 

You can transfer your public key to RFC4716 format with the program "ssh-keygen" with the parameters "-e" and "-F < Input PubKey >". The important thing is that the automatically inserted comment line must be removed. You may have to manually create the. SSH directory on the backup space.


	server# ssh-keygen
	Generating public/private rsa key pair.
	Enter file in which to save the key (/root/.ssh/id_rsa):
	Enter passphrase (empty for no passphrase):
	Enter same passphrase again:
	Your identification has been saved in /root/.ssh/id_rsa.
	Your public key has been saved in /root/.ssh/id_rsa.pub.
	The key fingerprint is:
	cb:3c:a0:39:69:39:ec:35:d5:66:f3:c5:92:99:2f:e1 root@server
	The key's randomart image is:
	+--[ RSA 2048]----+
	|                 |
	|                 |
	|                 |
	|         .   =   |
	|      . S = * o  |
	|   . = = + + =   |
	|    X o =   E .  |
	|   o + . .   .   |
	|    .            |
	+-----------------+
	
	server# ssh-keygen -e -f .ssh/id_rsa.pub | grep -v "Comment:" > .ssh/id_rsa_rfc.pub
	
	server# cat .ssh/id_rsa_rfc.pub >> backup_authorized_keys



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

	docker exec -it 82526abbabfe /root/backup.sh

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
	
## Get a Backup File form the Backup Space

In case you need to pull a backup file from the backup space run the script backup_get.sh :

	backup_get.sh /imixs-cloud/SERVICE-ID/BACKUPFILE BACKUPFILE

You need to specify the source file located in your backup space. With SFTP you can print the directory content from the FTP Space:

	docker exec -it 82526abbabfe echo ls / | sftp $BACKUP_SPACE_USER@$BACKUP_SPACE_HOST



After the script is completed, the file is written into the directory /root/backups/. 
You can run a restore on this file.

     
     
# Contribute
The source is available on [Github](https://github.com/imixs/imixs-docker). Please [report any issues](https://github.com/imixs/imixs-docker/issues).

To build the image from the Dockerfile run: 

    docker build --tag=imixs/backup .
 