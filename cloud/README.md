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
 
 
# How to Setup

[Docker-Swarm](https://docs.docker.com/engine/swarm/) is used to run a cluster of docker hosts serving business applications in docker-containers.

The the section [How to setup](setup/README.md) for further information.





  
# Contribute

Imixs-Docker-Cloud is open source and are sincerely invited to participate in it. 
If you want to contribute to this project please [report any issues here](https://github.com/imixs/imixs-docker/issues). 
All source are available on [Github](https://github.com/imixs/imixs-docker).

