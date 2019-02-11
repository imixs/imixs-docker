# imixs/exim4

This Docker image provides a mail transfer agent (MTA) running as a smarthost for Docker containers. The container can be used to send out e-mails from other containers.

The MTA is based on [Exim4](http://www.exim.org/). The Image was inspired by the Docker Image from [greinacker/exim4](https://hub.docker.com/r/greinacker/exim4/).
The Docker image is based on debian:jessie. 


## Features
* inherit form debian:jessie
* provide a minimal MTA Smarthost Configuration

### Environment

imixs/exim4 provides the following environment variables

* EXIM_SMARTHOST - your target mail server 
* EXIM_PASSWORD - authenticating to a remote host as a client.
* EXIM\_ALLOWED\_SENDERS - allowed sender IP/Network addresses (default=172.17.0.0/24:127.0.0.1)
* EXIM\_MESSAGE\_SIZE\_LIMIT - overwrites the default message_size_limit of 50m 



## 1. Install Docker
Follow the [Docker installation instructions](https://docs.docker.com/engine/installation/) for your host system.


## 2. Running and stopping a container
The container can be started in background as an demon. You can start an instance with the command:
    
    docker run --name="smarthost" -d \
	-e EXIM_SMARTHOST="target.mail.server.example:25" \
	-e EXIM_PASSWORD="target.mail.server.example:login:password" \
	imixs/exim4 

The environment parameter 'EXIM_SMARTHOST' points to the target mail sever used by exim4.
The environment parameter 'EXIM_PASSWORD' is written to the exim4/passwd file. This parameter contains the target mail server, user and login data.

To stop and remove the Docker container run the Docker command: 

    docker stop smarthost && docker rm smarthost


#### The MESSAGE\_SIZE\_LIMIT

Exim4 has a default MESSAGE\_SIZE\_LIMIT of 50M. Exim4 will reject emails with larger size to avoid spam mail. You can set different size here if you provide the environment variable named 'EXIM\_MESSAGE\_SIZE\_LIMIT'.

Example:

	-e EXIM_MESSAGE_SIZE_LIMIT="100M" 


## 3. Testing

To follow the exim4 server log: 

    docker logs -f smarthost
    
To test your smarthost configuration, first log into the bash of your smarthost:

	# log into bash
	docker exec -it smarthost /bin/bash	
	
With the following command you can test sending out an email

    echo "This is the message" | mail -s "The subject" captain.kirk@myhost.com -aFrom:sender@myhost.com
    


# Linking the Container

You can link the smarthost Docker container to other containers in your Docker network to allow them to send out mail via the smarthost.

Take care about the default environment setting: 


	EXIM_ALLOWED_SENDERS=172.17.0.0/24:127.0.0.1
	
This environment variable defines, if other docker containers running on your docker host, are allowed to use the MTA for sending out e-mails. The default setting is "172.17.0.0/24:127.0.0.1", which allows all linked containers to send mails. Customize this parameter if you have custom needs in your docker virtual network. If the setting is not set correct, you will typically see a log message like 

	...exim4 IP address .. relay not permitted...

     
# Contribute
The source is available on [Github](https://github.com/imixs/imixs-docker). Please [report any issues](https://github.com/imixs/imixs-docker/issues).

To build the image from the Dockerfile run: 

    docker build --tag=imixs/exim4 .

## Push manually to Docker repo (Docker-Hub)

To push the image to a docker repo: 


	docker build -t imixs/exim4:X.X.X .
	
	docker push imixs/exim4:X.X.X 