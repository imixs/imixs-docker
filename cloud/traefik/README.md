# Traefik Configuration

Traefik can be started by docker-compose:

    docker-compose up

The docker-compose.yml file includes the port mapping, the external network and the mounted configuration files.


The traefik.toml file includes the configuration settings as is mounted by the docker-compose.yml file into the container directory /etc/traefik/

## Configuration

### Network Configuration

It is important that the Traefik container and all containers which should by proxied by traefik are started within the same network. This means for the docker run command:

	docker run --network=<NETWORK> .....

and for docker-compose.yml files the corresponding networks entry:

	...
	networks:
	  default:
	    external:
	      name: imixs_cloud_nw


### Web Frontend Configuration

The Traefik web front-end listens internally on port 8080 and is secured by basic authentication:


	[web]
	  address = ":8080"
		[web.auth.basic]
		usersFile = "/etc/traefik/.htpasswd" 

	  
The password can be created from a linux console with the following command:

	htpasswd -c .htpasswd admin

This will create the corresponding user/password entry in the a file named '.htpasswd'. The file will be created if not exists.
The .htpasswd file must be mounted into the container directory /etc/traefik/

Find details about the web configuration [here](http://docs.traefik.io/configuration/backends/web/).

**Note:** The Traefik web frontend is usually mapped to port 8080. As this port is also used by wildfly we map the port 8080 from Traefik to the port 8100. 
Run the frontend from your web browser via:

[http://localhost:8100/](http://localhost:8100/)




