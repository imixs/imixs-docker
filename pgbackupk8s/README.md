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

All backups are located in the following local directory 

	/root/backups/


## Create a SSH Key


To transfers files to the backup space this service uses SFTP/SCP. For this reason a RFC4716 Public Key need to be provided in the pgbackupk8s  container. 

To create a configMap from a rsa private key 'keys/backupspace-key' for the namespace test-database run:


	$ kubectl create configmap rsa-key --from-file=keys/backupspace_rsa -n test-database

The mapping of the rsa-key within the Job yaml file looks like this:

    spec:
      containers:
      - name: backup
        image: imixs/pgbackupk8s:latest
         .......
         ...........
        volumeMounts:
        - name: rsa-key
          mountPath: /root/.ssh/id_rsa
          subPath: id_rsa
      # Add the ConfigMap as a volume 
      volumes:
      - name: rsa-key
        configMap:
          name: backupspace-key


     
     
     
# Contribute

The source is available on [Github](https://github.com/imixs/imixs-docker). Please [report any issues](https://github.com/imixs/imixs-docker/issues).


## Development

To build the image from the Dockerfile source file run: 

    docker build --tag=imixs/pgbackup .
 
### DockerHub

To push the image manually to Docker-Hub

	$ docker build -t imixs/pgbackup:X.X.X .
	$ docker push imixs/pgbackup:X.X.X 
	
	
	