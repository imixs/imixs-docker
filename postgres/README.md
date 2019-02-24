# imixs/postgres


The imixs/postgres Docker image runs the [Postgres Database](https://www.postgresql.org/) service based on the [official postgres images](https://hub.docker.com/_/postgres). 

The image extends runs on the latest version and extends the image with additional backup and restore scripts. 


## Features
* inherit form officeal postgres image
* runs latest postgres version
* backup script to backup a database locally
* restore script to restore from a local backup
* remote backup script to create a remote rolling backup on a ftp space
* remote restore script to restore a remote backup from a ftp space




## 1. Install Docker
Follow the [Docker installation instructions](https://docs.docker.com/engine/installation/) for your host system.


## 2. Running and stopping a container
You can start an instance of the postgres service with the Docker run command:

    docker run --name="postgres" -d \
        -p 8080:8080 -p 9990:9990 \
        -e POSTGRES_PASSWORD="db_password" \
        -e POSTGRES_USER="postgres" \
        -e POSTGRES_DB="database" \
        imixs/postgres
 
## Execute PSQL

On a running instance of Imixs/postgres you can execute PSQL commands in two differnt ways

 * connect to the running container
 * issue a remote call
 

### Connecting to the running container

To connect with the running container into the PSQL shell run:

	docker exec -it  4c9b3cd89156 psql
       
### Issue a remote call




## Development

To build the image from the Dockerfile run: 

    docker build --tag=imixs/postgres .
    
To start the postgres service in interactive mode run: 


    docker run --name="postgres" -i --rm \
        -p 8080:8080 -p 9990:9990 \
        -e POSTGRES_PASSWORD="db_password" \
        -e POSTGRES_USER="postgres" \
        -e POSTGRES_DB="database" \
        imixs/postgres
    