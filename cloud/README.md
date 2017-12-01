# The Imixs-Docker-Cloud

Imixs-Docker-Cloud is a conceptual infrastructure project, describing a way to create a Docker based server environment for business applications.
One of the main objectives of this project is to focus on **simplicity** and **transparency**. 

Imixs-Docker-Cloud is developed as part of the Open Source project [Imixs-Workflow](http://www.imixs.org) and continuous under development. 

The general idea is to setup an [Docker](https://www.docker.com/) based infrastructure with docker swarm. Within this infrastructure business applications like [Imixs-Office-Workflow](http://www.office-workflow.de) can be deployed in a fast and easy way. 

## Rules
The main objectives of this project can be itemized under the following rules:

 1. _A Imixs-Docker-Cloud can be setup easily and run on commodity hardware._
 2. _All services and infrastructure components are running on docker swarm._
 3. _The docker command line interface (CLI) is used to setup and manage nodes and services._ 
 4. _Business applications are deployed to a central Docker-Registry and started as services._
 5. _All services are isolated and accessible only through a central proxy server._
 6. _Scalabillity and configuration is managed by docker-compose._
 7. _Docker UI Front-End components are used to monitor the infrastructure._
 
 
## Basic Architecture

The basic architecture of the Imixs-Docker-Cloud consists of the following components:

 * A Docker-Swarm Cluster running on virtual or hardware nodes. 
 * A Management node providing a registry and a proxy server.
 * One ore many worker nodes to run services. 
 * A central Reverse-Proxy service to dispatch requests (listening on port 80) to applications.
 * A management UI running on the management node.
 
 
# Docker-Swarm

[Docker-Swarm](https://docs.docker.com/engine/swarm/) is used to run a cluster of docker hosts serving business applications in docker-containers.

The the section [How to setup](setup/README.md) for further information.







 See the [Swarm mode key concepts](https://docs.docker.com/engine/swarm/key-concepts/) for details. 

With Docker-Swarm containers will be distributed on the available nodes in the swarm cluster and tries to mostly get an even distribution of containers on all available nodes.
Docker swarm does not check the resources (memory, cpu ...) available on the nodes before deploying a container on it. The distribution of containers is balanced per nodes, without taking into account the availability of resources on each node. 

However its possible to build a strategy of distributing containers on the nodes. You can use [placement constraints](https://docs.docker.com/compose/compose-file/#placement) were you can restrict where a container can be deployed. You can label nodes having a lot of resources and restrict some heavy containers to only run on specific nodes.
If a container crashes, docker swarm will ensure that a new container is started. Again, the decision of what node to deploy the new container on cannot be predetermined.

See the following tutorial how to setup a Docker-Swarm:

* [Docker-Swarm tutorial](https://docs.docker.com/engine/swarm/swarm-tutorial/)
* [Lightweight Docker Swarm Environment by Ralph Soika](http://ralph.soika.com/lightweight-docker-swarm-environment/)

## Rules

 1. All containers are started as services to run in the swarm.
 2. Use the Docker CLI to create a swarm, deploy application services to a swarm, and manage swarm behavior.
 3. The Proxy Container is configured to run  exclusively on the manager-only nodes.   Or the proxy can be run as a  global service, which 
 means, that swarm runs one task for this service on every available node in the cluster.
 
 
----------------------- IN BLOG ÜBERTRAGEN START -----------------------------------------
 
# The Docker-Registry

Public docker images are basically available on [Docker Hub](hub.docker.com). For private docker images a Docker Registry is used. A private registry is a mandatory part of this cloud concept. The registry is hosted on the docker-swarm manager. 

The goal is to push locally build docker images to the docker registry, so that the cloud infrastructure can pull and start those services without the need to build the images from a Docker file. 

## How to Setup
The following section will show how to setup the private registry with TLS (Transport Layer Security).



### Create a Self Signed Certificate

To secure the registry we create a self signed certificate on the manager1 server to be used for the private Docker Registry.

First you can easily create a certificate with the OpenSSL-Tool locally.


	$ mkdir ./registry && cd ./registry
	$ openssl req -newkey rsa:4096 -nodes -sha256 \
                -keyout domain.key -x509 -days 356 \
                -out domain.cert
                Generating a 4096 bit RSA private key
	................................................++
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
	Common Name (e.g. server FQDN or YOUR name) []:192.168.99.100
	Email Address []:
	


Here I created a x509 certificate and a private RSA key. The ‘Common Name’ here is important as this is the server host name. In this example I use the IP address of machine 'manager1' (192.168.99.100), but in production you would use a internet domain name. 

Finally you have two files:

    domain.cert – this file can be handled to the client using the private registry
    domain.key – this is the private key which is necessary to run the private registry with TLS



Next you can copy the certificate files to the manager1 into the folder 'registry_certs':

	$ docker-machine ssh manager1 "mkdir ./registry/certs"
	$ docker-machine scp domain.cert manager1:./registry/certs/
	$ docker-machine scp domain.key manager1:./registry/certs/


Create a docker-compose.yml file with the following content:

	version: '3'
	
	services:
	 app:
	   image: registry:2
	   environment:
	     REGISTRY_HTTP_TLS_CERTIFICATE: /certs/domain.cert 
	     REGISTRY_HTTP_TLS_KEY: /certs/domain.key
	   volumes:
         - ~/registry/certs:/certs   
	   ports:
	     - 5000:5000
	   networks:
	     - net
	   deploy:
	     placement:
	       constraints:
	         - node.role == manager
	networks:
	   net:
	     driver: overlay


copy the docker-compose.yml file into manager1

	$ docker-machine scp docker-compose.yml manager1:./registry/

Now you can start the registry with :

	docker-machine ssh manager1 "docker stack deploy -c registry/docker-compose.yml registry"
	
The local registry is now available under the address:

	https://192.168.99.100:5000	
	
You can check the registry API via:

	https://192.168.99.100:5000/v2/


### Push a local image

After the registry was started you can push a local image into the registry. The following example pushes the traefik image:


	$ docker tag traefik:latest 192.168.99.100:5000/traefik:latest
	$ docker push 192.168.99.100:5000/traefik:latest
	The push refers to a repository [192.168.99.100:5000/traefik]
	Get https://192.168.99.100:5000/v2/: x509: cannot validate certificate for 192.168.99.100 because it doesn't contain any IP SANs

As you can see in the error message, the push failed because of the missing certificate installed on your local machine. 
To fix this copy the certificate into the docker certs.d directory and restart your local docker service


	$ mkdir -p /etc/docker/certs.d/192.168.99.100:5000 
	$ cp domain.cert /etc/docker/certs.d/192.168.99.100:5000/ca.crt
	$ service docker restart

Note: it can be that the certificate is not accepted because it's based on IP only. In this case you should create a certificate for a local existing domain name (e.g. local.manager1). 



----------------------- IN BLOG ÜBERTRAGEN ENDE -----------------------------------------



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






 
 
[traefik](traefik/README.md)
 










# Deprecated Sections









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
See also the [Boxboat Blog](https://boxboat.com/2017/10/10/managing-multiple-microservices-with-traefik-in-docker-swarm/) for additional information how to run traefik in docker swarm mode. 

## Rules: 





# Databases

We use mysql or posgres as RDMS to provide databases. 

## Rules:

 * The database container includes a FTP Backup Cron job
 * The database container provides scripts to restore from regular or snapshot backups


See: https://github.com/yloeffler/mysql-backup


# Wildfly

See: 

!!!

Clustering

Our WildFly image uses the standalone.xml configuration file which is great, but not for the clustering purposes. Let's switch to standalone-ha.xml. This will enable the clustering features.
* https://eldermoraes.wordpress.com/2017/01/10/building-a-wildfly-cluster-using-docker/


* https://blog.couchbase.com/microservice-using-docker-stack-deploy-wildfly-javaee-couchbase/
* https://goldmann.pl/blog/2013/10/07/wildfly-cluster-using-docker-on-fedora/

















  
# Contribute

Imixs-Docker-Cloud is open source and are sincerely invited to participate in it. 
If you want to contribute to this project please [report any issues here](https://github.com/imixs/imixs-docker/issues). 
All source are available on [Github](https://github.com/imixs/imixs-docker).

