# The Imixs-Docker-Cloud

Imixs-Docker-Cloud is a conceptual project that describes a way to create a Docker infrastructure for business applications.
The main objective of this project is to focus on **simplicity** and **transparency**. The concept can be further developed. 

The general idea is to setup a docker based infrastructure for Imixs-Workflow applications in a fast and easy way. We use Docker as the main infrastructure component and name these infrastructure 'Imixs-Docker-Cloud'. 

## Rules
 1. _A Imixs-Docker-Cloud can be setup on any hardware_
 2. _All applications running in the cloud can be accessed through a proxy server which is part of the cloud._
 3. _Busness applications can be started and stopped independent from each other by separate Docker containers._
 4. _A Docker-Registry and a Databaseserver is not part of the cloud._  
 
# User-Defined-Networks

Imixs-Docker-Cloud uses [User-Defined-Networks](https://docs.docker.com/engine/userguide/networking/#user-defined-networks)

It is recommended to use user-defined bridge networks to control which containers can communicate with each other, and also to enable automatic DNS resolution of container names to IP addresses. 

The Imixs-Cloud network can be created with the following command on the docker host:

	$ docker network create --driver bridge imixs_cloud_nw

To see the current configuration of the network run:

	$ docker network inspect imixs_cloud_nw
	
List all networks: 

	$ docker network ls

After you create the network, you can launch containers on it using the docker option:

	docker run --network=<NETWORK> 
	
The containers launched into this network must reside on the same Docker host. Each container in the network can immediately communicate with other containers in the network. Though, the network itself isolates the containers from external networks.
Within a user-defined bridge network, linking is not supported and so not necessary. 
Exposing ports of published containers is necessary only if a service must be available to an outside network which is not the case for the imixs-docker-cloud. 
So in Imixs-Docker-Cloud only the port 80 for the proxy service is exposed. Inter-Container configuration works without additional configuration.




## Compose 
By default Docker Compose sets up a single network for each app. Each container for a service joins the default network and is both reachable by other containers on that network, and discoverable by them at a hostname identical to the container name.
To tell compose to use the imixs-cloud network the following additional entry need to be added into the docker-compose.yml file


	version: '3'
	
	services:
	....
	
    networks:
	  default:
	    external:
	      name: imixs_cloud_nw

In this configuration the external network 'imixs\_cloud\_nw' must exist before the services defined in the compose file are started. 

# The Proxy

To access business applications running in the cloud from the Internet a Reverse-Proxy is used. The core functionality of this component is to dispatch requests to appropriate docker containers running in the cloud.  The reverse proxy  redirects the requests to the respective Wildfly container. 

The proxy service can be realized with a nginx oir traefik.io. 

## Nginx
Nginx is a web server which alos can operate as a reverse proxy. It can be launched in its own Docker container which is reachable via port 80.

The Github Project [jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy) provides a docker image with nginx and automatically generates reverse proxy configs for nginx and reloads nginx when containers are started and stopped.

## traefik.io
Træfik is a pure HTTP reverse proxy and load balancer. It  manages it configuration automatically and dynamically by scanning events from the backend services like "Docker", "Docker Swarm" and also "Rancher". 

The folder /trafik contains a docker-compose.yml file to start trafik with the following command:

	docker-compose up

The trafik container is using the network 'imixs\_cloud\_nw', which need to be created first (see above)

All docker containers started in the same network as the trafik container are accessable via port 80 by trafik. 

## Rules: 





# Databases

We use mysql or posgres as RDMS to provide databases. 

## Rules:

 * The database container includes a FTP Backup Cron job
 * The database container provides scripts to restore from regular or snapshot backups


See: https://github.com/yloeffler/mysql-backup



# The Docker-Registry

Public docker images are basically available on [Docker Hub](hub.docker.com). For private docker images a Docker Registry is used. A private registry is not a mandatory part of this cloud concept. The registry can be hosted on any server outside of the cloud itself. 

The goal is to push locally build docker images to the docker registry, so that the cloud infrastructure can pull those images without the need to build the images from a Docker file. 

## Rules:

 * _A registry is not running in the cloud and can be installed anywhere. The registry is a repository like a code repository and should be handled like this._ 


## How to Connect a Registry

So the final question is how to connect a private Docker Registry?. This can be done with TLS (see the section 'How to Setup a Private Docker Registry'). 

To allow the cloud to pull images from a private registry, the cloud need the domain certificate. There for the certificate file “domain.cert” must be located on the cloud infrastructure  in a file

	@local:$ /etc/docker/certs.d/<registry_address>/ca.cert

Where <registry_address> is the server host name of the private registry including the port number. For example:

	/etc/docker/certs.d/dock01:5000/ca.cert

After the certificate was updated you need to restart the local docker daemon:

	@local:$ mkdir -p /etc/docker/certs.d/dock01:5000 
	@local:$ cp domain.cert /etc/docker/certs.d/dock01:5000/ca.crt
	@local:$ service docker restart

Now the private registry is available to the cloud.




## How to Setup a Private Docker Registry

A docker registry can easily be started with the official Docker image ‘registry:2’. 

	@dock01:$ docker run -d -p 5000:5000 registry:2

To make a docker registry available to remote clients (e.g. the cloud) or developers providing new images, the registry must be started with a valid TLS (Transport Layer Security).

### Create a Self Signed Certificate

A new certificate can be created with the OpenSSL-Tool:

	@dock01:$ mkdir registry_certs
	@dock01:$ openssl req -newkey rsa:4096 -nodes -sha256 \
	                -keyout registry_certs/domain.key -x509 -days 356 \
	                -out registry_certs/domain.cert
	Generating a 4096 bit RSA private key
	.......................++
	...............................................................................................................................................++
	writing new private key to 'registry_certs/domain.key'
	-----
	You are about to be asked to enter information that will be incorporated
	into your certificate request.
	What you are about to enter is what is called a Distinguished Name or a DN.
	There are quite a few fields but you can leave some blank
	For some fields there will be a default value,
	If you enter '.', the field will be left blank.
	-----
	Country Name (2 letter code) [AU]:DE
	State or Province Name (full name) [Some-State]:
	Locality Name (eg, city) []: 
	Organization Name (eg, company) [Internet Widgits Pty Ltd]: 
	Organizational Unit Name (eg, section) []:
	Common Name (e.g. server FQDN or YOUR name) []:dock01
	Email Address []:
	imixs@dock01:~$ ls registry_certs/
	domain.cert domain.key

The ‘Common Name’  is important here as this is the server host name.
In this example a x509 certificate and a private RSA key are created: 

 * domain.cert – this file can be handled to the client using the private registry
 * domain.key – this is the private key which is necessary to run the private registry with TLS
 
### Running the Private Docker Registry with TLS

To start the registry with the local domain certificate and key file:

	@dock01:$ docker run -d -p 5000:5000 \
	 -v $(pwd)/registry_certs:/certs \
	 -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.cert \
	 -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
	 --restart=always --name registry registry:2


The folder /registry_certs is mapped as an volume into the docker registry container. Environment variables are pointing to the certificate and key file.

Now again you can push your local image into the new registry:

	@dock01:$ docker push localhost:5000/proxy:1.0.0

### Access the Remote Registry form a local Client

Now as the private registry is started with TLS Support you can access the registry from any client which has the domain certificate.

There for the certificate file “domain.cert” must be located on the client in a file

	@local:$ /etc/docker/certs.d/<registry_address>/ca.cert

Where <registry_address> is the server host name including the port number. After the certificate was updated you need to restart the local docker daemon:

	@local:$ mkdir -p /etc/docker/certs.d/dock01:5000 
	@local:$ cp domain.cert /etc/docker/certs.d/dock01:5000/ca.crt
	@local:$ service docker restart

Now finally you can push you images into the new private registry:

	@local:$ docker tag imixs/proxy dock01:5000/proxy:dock01
	@local:$ docker push dock01:5000/proxy:dock01

Note: In all the examples I used here you need to replace the hostname ‘dock01’ with your remote server domain name!

You can verify you remote registry also via web browser:

https://yourserver.com:5000/v2/_catalog























  
# Contribute

Imixs-Docker-Cloud is open source and are sincerely invited to participate in it. 
If you want to contribute to this project please [report any issues here](https://github.com/imixs/imixs-docker/issues). 
All source are available on [Github](https://github.com/imixs/imixs-docker).

