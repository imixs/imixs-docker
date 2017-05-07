# imixs/smarthost

This Docker image provides a mail transfer agent (MTA) running as a smarthost. The container can be used to send out e-mails from other containers.

The MTA is based on [Exim4](http://www.exim.org/). The Image was inspired by the Docker Image from [greinacker/exim4](https://hub.docker.com/r/greinacker/exim4/).
The Docker image is based on debian:jessie. 


## Features
* inherit form debian:jessie
* provide a minimal smarthost configuration

### Environment

imixs/smarthost provides the following environment variables

 * EXIM_SMARTHOST - your mail server 
 * EXIM_PASSWORD - authenticating to a remote host as a client.


## 1. Install Docker
Follow the [Docker installation instructions](https://docs.docker.com/engine/installation/) for your host system.


## 2. Running and stopping a container
The container can be started in background as an demon. You can start an instance run command:
    
    docker run --name="smarthost" -d \
	-e EXIM_SMARTHOST="my-mailserver:25" \
	-e EXIM_PASSWORD="my-password" \
	imixs/smarthost 


To stop and remove the Docker container run the Docker command: 

    docker stop smarthost && docker rm smarthost


## 3. Testing

To follow the exim4 server log: 

    docker logs -f smarthost
    
To test your smarthost configuration, first log into the bash of your smarthost:

	# log into bash
	docker exec -it smarthost /bin/bash	
	
With the following command you can test sending out an email

    echo "This is the message" | mail -s "The subject" captain.kirk@myhost.com -aFrom:sender@myhost.com
    

    
 
# Contribute
The source is available on [Github](https://github.com/imixs/imixs-docker). Please [report any issues](https://github.com/imixs/imixs-docker/issues).

 