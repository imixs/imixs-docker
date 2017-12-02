# Applications

The /apps/ directory holds the configuraiton of applications running as services in the docker-swarm environment.
Each aplication has its own application direcotry holding a docker-compose.yml file to start the application.


	$ docker stack deploy -c apps/MY-APP/docker-compose.yml MY-APP

To test the environment you can deploy a simple test service /emilevauge/whoami . This docker container simply displays the location of itself.

	$ docker stack deploy -c apps/whomai/docker-compose.yml whomai

