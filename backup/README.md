# imixs/backup

This Docker image provides a backup service for an Imixs-Workflow instance. The backup service can backup the PSQL database and also Imixs-Workflow search index (lucen). The backups are organized in a backup directory and can be automatically transfered to a FTP server. 


## Features
* backup script PSQL and files system
* ftp feature to move backups to an external ftp service
* chron job
* restore feature.

### Environment

imixs/backup provides the following environment variables

* POSTGRES_USER - postres database user
* POSTGRES_PASSWORD - postgres user password
* POSTGRES_DATABASE - postgres database
* WILDFLY_INDEX - filepath for lucen index


## 1. Install Docker
Follow the [Docker installation instructions](https://docs.docker.com/engine/installation/) for your host system.


## 2. Running and stopping a container
The container can be started in background as an demon. You can start an instance with the command:
    
    docker run --name="backup" -d \
	-e POSTGRES_USER="my-user" \
	-e POSTGRES_PASSWORD="my password" \
	imixs/backup 


To stop and remove the Docker container run the Docker command: 

    docker stop backup


## 3. Testing

To follow the backup server log: 

    docker logs -f backup
    
To test your backup configuration, first log into the bash of your backup container:

	# log into bash
	docker exec -it backup /bin/bash	
	
  

     
# Contribute
The source is available on [Github](https://github.com/imixs/imixs-docker). Please [report any issues](https://github.com/imixs/imixs-docker/issues).

To build the image from the Dockerfile run: 

    docker build --tag=imixs/smabackuprthost .
 