# imixs/wildfly


This imixs/wildfly Docker image runs the Java application server [WildFly](http://www.wildfly.org) in the latest version on OpenJDK 8. 
The image is based on the official OpenJDK Docker Image. 

In addition the imixs wildfly image adds the eclipselink.jar into the module configuration of wildfly and JDBC driver support for PostgreSQL. 

[![](https://images.microbadger.com/badges/image/imixs/wildfly.svg)](https://microbadger.com/images/imixs/wildfly "Get your own image badge on microbadger.com")

## Features
* inherit form officeal openJDK
* runs wildfly with OpenJDK 8
* starts wildfly in standalone mode with management console
* creates an admin user on first usage
* adds support of eclipselink
* provides JDBC PostgreSQL driver
* installation path: /opt/wildfly 
* linux user: imixs
* support debug mode

### Environment

imixs/wildfly provides the following environment variables

<div>
<ul>
	<li>JAVA_HOME</li>
	<li>WILDFLY_HOME (/opt/wildfly)</li>
	<li>WILDFLY_DEPLOYMENT ($WILDFLY_HOME/standalone/deployments)</li>
	<li>WILDFLY_CONFIG  ($WILDFLY_HOME/standalone/configuration)</li>
</ul>
</div>


## 1. Install Docker
Follow the [Docker installation instructions](https://docs.docker.com/engine/installation/) for your host system.


## 2. Running and stopping a container
The container includes a start script which allows to start Wildfly with an admin password to grant access to the web admin console. You can start an instance of wildfly with the Docker run command:

    docker run --name="wildfly" -d \
        -p 8080:8080 -p 9990:9990 \
        -e WILDFLY_PASS="admin_password" \
        imixs/wildfly

If you leave the environment parameter 'WILDFLY_PASS' empty, the start script will generate a random password. 
If you expose the ports 8080 and 9990 you can access Wildfly via [http://<host-ip>:8080/](http://localhost:8080) and [http://<host-ip>:9990/](http://localhost:9990)

To stop and remove the Docker container run the Docker command: 

    docker stop wildfly && docker rm wildfly

## 3. Access WildFly

After the server was started you can access the wildfly server from your browser:

    http://localhost:8080/

To follow the wildfly server log run: 

    docker logs -f wildfly

	
## How to bind external volumes

If you want to customize the configuration or deploy applications you can do so by defining external volumes at the following locations:

* /opt/wildfly/standalone/configuration/  => for custom configuration files like standalone.xml
* /opt/wildfly/standalone/deployments/ => to provide an external autodeploy directory. 

This is an example to run imixs/wildfly with external volumes:

     docker run --name="wildfly" -d \
			-p 8080:8080 -p 9990:9990 \
			-e WILDFLY_PASS="admin_password" \
			-v /path/to/deployments:/opt/wildfly/standalone/deployments/ \
			imixs/wildfly

You can now place a .war or .ear file into the deployments directory to be picked up by the wildfly deployment scanner.

Also an external configuration volume can be bound to the container:


     docker run --name="wildfly" -d \
			-p 8080:8080 -p 9990:9990 \
			-e WILDFLY_PASS="admin_password" \
			-v ~/git/imixs-office-workflow/src/docker/imixs/config/deployments:/opt/wildfly/standalone/deployments/ \
			-v ~/git/imixs-office-workflow/src/docker/imixs/config/configuration/:/opt/wildfly/standalone/configuration/ \
			imixs/wildfly


To start wildfly with a volumes shared from another application volume container (e.g. imixs/office) run:

     docker run --name="wildfly" -d \
			-p 8080:8080 -p 9990:9990 \
			-e WILDFLY_PASS="admin_password" \
           --volumes-from my_data_container \
           imixs/wildfly

### Permissions

The Imixs Wildfly container start the wildfly server with a system user having the uid and gid 901. 

If you share a volume from your host to container, make sure that the user 901 has write permissions for the corresponding host directories:

    chgrp -R 901 /path/to/deployments
    chmod 775 -R /path/to/deployments



## Linking containers
For Java enterprise applications you often need an additional database server. you can link the wildfly container to such an external container. The following example creates a link to a postgreSQL container with the name 'postgres', which is the host name to be used in a database-pool configuration:

     docker run --name="wildfly" -d \
			-p 8080:8080 -p 9990:9990 \
			-e WILDFLY_PASS="admin_password" \
			--link database-postgres:postgres \
			imixs/wildfly

# Debug Mode

To run the container in debug mode the environment parameter 'DEBUG' can be set to 'true'.
**Note:** You need to expose the port 8787 to attache a debugger tool.

	docker run --name="wildfly" 
			-p 8080:8080 -p 8787:8787 -p 9990:9990 \
			-e WILDFLY_PASS="admin_password" \
			-e DEBUG=true \
			imixs/wildfly



# Contribute
The source is available on [Github](https://github.com/imixs-docker/imixs-wildfly). Please [report any issues](https://github.com/imixs-docker/wildfly/issues).

To build the image from the Dockerfile run: 

    docker build --tag=imixs/wildfly .

To test the image run the container in an interactive mode:
    
	docker run --name="wildfly" -it \
			-p 8080:8080 -p 9990:9990 \
			-e WILDFLY_PASS="admin_password" \
			imixs/wildfly

You can also log into the running wildfly with a bash:

	docker exec -it wildfly /bin/bash	


