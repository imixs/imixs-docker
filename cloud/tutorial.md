# Imixs-Cloud Tutorial

This is an tutorial explaining how to setup a Imixs-Cloud.
The cloud will consist of Docker-Swarm with two docker-nodes. Imixs-Office-Worklfow is deployed as a service.
Traefik.io is running as the reverse proxy. 

## Setup with Docker-Machine

This step is only needed for setting up a test environment. In real world you would need two machines running as a docker host. 
So you can skip this if you have already two hosts or VMs with docker running.


### 1. Install Docker-Machine
   
   Follow the official [Install Guide for Docker-Machine](https://docs.docker.com/machine/install-machine/).
   
### 2. Create two new machines

   Run the following commands to setup two machines. This commands can take several minutes if running the first time:
   
    docker-machine create --driver virtualbox machine1
    docker-machine create --driver virtualbox machine2  
   
   verify the machines with the command:
   
    docker-machine ls

   to get detailed information about a machine run 
   
    docker-machine inspect machine1

   to get only the IP address run
   
    docker-machine inspect --format "{{.Driver.IPAddress}}" machine1
 
   or use the subcommand
   
    docker-machine ip machine1

### 3. Set the active machine

   Docker commands usually target the current host. If you have created different machines with Docker-Machine you can configure docker to 'speak' with one of the newly created machines
   
    docker-machine env machine1

Now all docker commands will target the 'machine1'.

To reset docker back to your local default environment, you can exit your current shell session or run 

    eval $(docker-machine env --unset)

### 4. How to remove the machines
   
   If you want to remove the machines - because it was for testing only run
   
    docker-machine rm machine1 machine2


# Staring Docker-Swarm

Now lets run docker-swarm in the new environment by starting the first node:

    docker swarm init --advertise-addr 192.168.99.100
    

## Run portainer on machine1

To see what is going on we can now run the docker container portainer on machine1. 

	docker run -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v /opt/portainer:/data portainer/portainer

You can open the UI from the ip address of machine1

    http://192.168.99.100:9000

You will see that swarm is running on machine1    


## Join machine2 to the swarm

To join machine2 you first run the following swarm command on machine1:

	docker swarm join-token worker
 
 This will print the command for a worker node to join the existing swarm
 
Now you an switch into machine2 and runn the command printed by teh join-token command:


	docker swarm join --token SWMTKN-1-51628r9tk5352345z96dgu1xxsff9vwxlx09csv544n1bw-ekhwxm345icizd4a950c2an2i 192.168.99.100:2377
 
If you now check again the portainer web UI you will see both machines.
