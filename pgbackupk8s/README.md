# PGbackupK8s


The Docker image `imixs/pgbackupk8s` provides a backup service for [Postgres Databases](https://www.postgresql.org/) running in a [Kubernetes cluster](https://kubernetes.io/). **PGbackupK8s** provides different scripts to backup and restore a postgres database  manually or scheduled. **PGbackupK8s** can be configured easily in a Kubernetes Job yaml file.

## Features
* inherit form official postgres image
* backup script to backup a database locally
* restore script to restore from a local backup
* remote backup script to create a remote rolling backup on a ftp space
* remote restore script to restore a remote backup from a ftp space


     
## Environment
The imixs/pgbackup image provides the following environment variables:

* POSTGRES\_HOST - database server
* POSTGRES\_USER - database user
* POSTGRES\_PASSWORD - database user password
* POSTGRES\_DB - the postgres  database name 

* BACKUP\_SPACE\_HOST - backup space connected via SFTP/SCP 
* BACKUP\_SPACE\_USER - backup space user 
* BACKUP\_SERVICE\_NAME - name of the backup service (defines the target folder on FTP space)
* BACKUP\_SPACE\_ROLLING - number of backup files to be kept in the backup space
* BACKUP\_ROOT\_DIR - backup root directory (e.g. "/imixs-cloud", default if not set will be "/imixs-cloud")
* BACKUP\_EMAIL\_SMARTHOST - the container name of Exim smarthost service, it can be an instance of the [imixs/exim4 service](https://github.com/imixs/imixs-docker/blob/master/exim4/README.md)
* BACKUP\_EMAIL\_FROM - the sender to use while sending the success job email
* BACKUP\_EMAIL\_TO - the recipient to use while sending the success job email

All backups are located in the following local directory 

	/root/backups/


## Create a SSH Key


?????????????????
To transfers files to the backup space this service uses SFTP/SCP. For this reason a RFC4716 Public Key need to be provided on the backup space.

The backup service expects that a private key file is provided by a docker secret. Docker secrets can be used only in docker swarm. So in this case you are forced to run the backup service in a docker swarm.

To copy a ssh key provided in the file/root/.ssh/backupspace_rsainto a docker secret run:

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
     
     
     
# Contribute

The source is available on [Github](https://github.com/imixs/imixs-docker). Please [report any issues](https://github.com/imixs/imixs-docker/issues).


## Development

To build the image from the Dockerfile source file run: 

    docker build --tag=imixs/pgbackup .
 
 