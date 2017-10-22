# The Imixs-Docker-Cloud

Imixs-Docker-Cloud is a conceptual project that describes a way to create a Docker infrastructure for business applications.
The main objective of this project is to focus on **simplicity** and **transparency**. The concept can be further developed. 

## General

The general idea is to setup a docker based infrastructure for Imixs-Workflow applications in a fast and easy way. We use Docker as the main infrastructure component. 

### Rule
Docker containers can be started and stopped independent from each other. 


# The Registry

Public docker images are basically available on [Docker Hub](hub.docker.com). For private docker images a Docker Registry is used. A private registry is on part of this cloud concept. The registry can be hosted on any server and need not be part of the cloud itself. 

The goal is to push locally build docker images to the docker registry, so that the cloud infrastructure can pull those images without the need to build the images from a Docker file. 


## How To Setup

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

###Access the Remote Registry form a local Client

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


























 

# The Proxy

To access applications running in the cloud from the Internet a Revers-Proxy is used. The core functionality of this component is to dispatch requests to appropriate docker containers running in the cloud.



  
# Contribute

Imixs-Docker-Cloud is open source and are sincerely invited to participate in it. 
If you want to contribute to this project please [report any issues here](https://github.com/imixs/imixs-docker/issues). 
All source are available on [Github](https://github.com/imixs/imixs-docker).

