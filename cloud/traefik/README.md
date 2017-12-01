# The HTTP Reverse Proxy – traefik.io

A HTTP reverse proxy is used to hide our services from the internet. In addition the proxy also acts as a load balancer to be used if you need to scale your application over several nodes.

[traefik.io](traefik.io) is a reverse proxy with a nice UI. To deploy traefik into the environment first create an overlay network for traefik to use.

	docker-machine ssh manager1 "docker network create --driver=overlay traefik-net"

This network will be later used to start new services to be reached through the traefik proxy service.

To start traefil in this network run:

	docker-machine ssh manager1 "docker service create \
	    --name traefik \
	    --constraint=node.role==manager \
	    --publish 80:80 \
	    --publish 8080:8080 \
	    --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
	    --network traefik-net \
	    traefik:v1.4.4 \
	    -l DEBUG \
	    --docker \
	    --docker.swarmmode \
	    --docker.domain=traefik \
	    --docker.watch \
	    --web"

After traefik is stared you can access the web UI via port 8080

	http://192.168.99.100:8080

Now you can start deploying web applications into the swarm within the network traefik-net. Those applications will be accessible via the traefik proxy server. To test the proxy you can deploy a simple test service /emilevauge/whoami . This docker container simply displays the location of itself.

	docker-machine ssh manager1 "docker service create \
	    --name whoami1 \
	    --label traefik.port=80 \
	    --network traefik-net \
	    --label traefik.frontend.rule=Host:whoami.local\
	    emilevauge/whoami"

In this example the label traefik.frontend.rule=Host:whoami.local is a local dns name under which the application can be accessed. When you open the traefik frontend, the new service will be listed:

	http://192.168.99.100:8080

If you have added the DNS entry into your local hosts file pointing to the machine manager1 (192.168.99.100), the web application can be opend from this URL:

	http://whoami.local/
	
## HTTPS with Let’s encrypt

Traefik will automatically detect new containers starting in the swarm and provides a front end domain on HTTP port 80 or HTTPS 443. For HTTPS you can easily install certificates with Let’s encrypt.

 