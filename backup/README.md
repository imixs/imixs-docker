# imixs/backup

This Docker image provides a backup service for an Imixs-Workflow instance. The backup service can backup the PSQL database and also Imixs-Workflow search index (lucen). The backups are organized in a backup directory and can be automatically transfered to a FTP server. 


## Features
* backup script PSQL and files system
* ftp feature to move backups to an external ftp service
* chron job
* restore feature.

### Environment

imixs/backup provides the following environment variables which need to be set during container startup:

* BACKUP\_POSTGRES\_USER - postres database user
* BACKUP\_POSTGRES\_PASSWORD - postgres user password
* BACKUP\_POSTGRES\_DATABASE - postgres database
* BACKUP\_WILDFLY\_INDEX - filepath for lucen index


## 1. Install Docker
Follow the [Docker installation instructions](https://docs.docker.com/engine/installation/) for your host system.


## 2. Running and stopping a container

The imixs/backup service is supposed to be run as part of a docker service stack. This means that the service is included in a docker-compose.yml file which already contains PQSL Database Server and a Wildfly Application Server. 
In this szenario the wildfly service access the PSQL server via the internal overlay network. In the same way the backup service can access the database. The integration of the backup service into a docker-compose.yml file looks like this:






The container can be started in background as an demon. You can start an instance with the command:
    
    docker run --name="backup" -it \
	-e POSTGRES_USER="my-user" \
	-e POSTGRES_PASSWORD="my password" \
	-e POSTGRES_HOST="myhost" \
	imixs/backup 


To stop and remove the Docker container run the Docker command: 

    docker stop backup


## 3. Testing

To follow the backup server log: 

    docker logs -f backup
    
To test your backup configuration, first log into the bash of your backup container:

	# log into bash
	docker exec -it backup /bin/bash	
	
  
  
# cron

imixs/backup starts a cron job.

See: https://ypereirareis.github.io/blog/2016/02/29/docker-crontab-environment-variables/
  
  
  

     
# Contribute
The source is available on [Github](https://github.com/imixs/imixs-docker). Please [report any issues](https://github.com/imixs/imixs-docker/issues).

To build the image from the Dockerfile run: 

    docker build --tag=imixs/backup .
 