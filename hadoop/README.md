# imixs/hadoop

The Docker Image 'imixs/hadoop' provides a Docker image to setup a single node hadoop cluster. This container can be used to test the hadoop [HttpFS Rest API](https://hadoop.apache.org/docs/current/hadoop-hdfs-httpfs/index.html). The image is based on the [official openjdk:8 Docker image](https://hub.docker.com/r/_/openjdk/) and was inspired from [athlinks/hadoop](https://hub.docker.com/r/athlinks/hadoop/).

The Docker Image 'imixs/hadoop' provides the following features:

## Features
* inherit form official openJDK
* runs hadoop with OpenJDK 8
* starts a single node hadoop cluster
* support HttpFS and WebHDFS Rest API
* installation path: /opt/hadoop 
* linux user: hduser
* data volume /data/hdfs/

**NOTE:**
This Docker image is for test purpose only. The container should only run in a system environment protected from external access. For that reason no kerberos security module is part of this image.

## The Rest API

Apache Hadoop provides a high performance native protocol for accessing HDFS. While this is great for Hadoop applications running inside a Hadoop cluster, external applications typically need to connect to HDFS from the outside. Using the native HDFS protocol means installing Hadoop and a Java binding with those applications. To access the hadoop cluster without these libraries a standard RESTful mechanism can be used.

### WebHDFS 
As part of the hadoop standard REST API the WebHDFS takes advantages of the parallelism that a Hadoop cluster offers. 
Further, WebHDFS retains the security that the native Hadoop protocol offers. It also fits well into the overall strategy of providing web services access to all Hadoop components. Read also the official documentation of the Hadoop [WebHDFS REST API](https://hadoop.apache.org/docs/r2.8.0/hadoop-project-dist/hadoop-hdfs/WebHDFS.html).

The WebHDFS API is accessible through the default port 50075.

### HttpFS 
As the WebHDFS API need access to the namenode as also to all datanodes within a hadoop cluster, the HttpFS Rest API provides a REST HTTP gateway supporting all HDFS File System operations (read and write) from a dedicated proxy server. HttpFS is interoperable with the webhdfs REST HTTP API. The HttpFS API is accessible through the default port 14000. As HttpFS runs on a separate server, 

The HttpFS API is accessible through the default port 14000.

- HttpFS can be used to transfer data between clusters running different versions of Hadoop (overcoming RPC versioning issues), for example using Hadoop DistCP.

- HttpFS can be used to access data in HDFS on a cluster behind of a firewall as the HttpFS server acts as a gateway and may be the only system that is allowed to cross the firewall into the cluster.

- HttpFS can be used to access data in HDFS using HTTP utilities (such as curl and wget) and HTTP libraries Perl from other languages than Java.

- The webhdfs client FileSystem implementation can be used to access HttpFS using the Hadoop filesystem command (hadoop fs) line tool as well as from Java applications using the Hadoop FileSystem Java API.

- HttpFS has built-in security supporting Hadoop pseudo authentication and HTTP SPNEGO Kerberos and other pluggable authentication mechanisms. It also provides Hadoop proxy user support.


**Note:** {Imixs-Archive](https://github.com/imixs/imixs-archive) supports the HttpFS Rest API on port 14000 as well the Webhdfs API on port 50075. 

# 1. Install Docker
Follow the [Docker installation instructions](https://docs.docker.com/engine/installation/) for your host system.

# 2. Running and stopping a container
The container includes a start script running a namenode and a datanode. The container can be started with the following Docker run command:

    docker run --name="hadoop" -d -p 9000:9000 -p 50070:50070 -p 14000:14000  imixs/hadoop

The docker container can be access via the WebHDFS Rest API as also the Hadoop Web Client. 
When the container is started the first time, it automatically formats a Docker data volume for the hadoop filesystem HDFS. To restart an existing container run the command:

	docker start hadoop
    
**NOTE:** 
The option "-h hadoop.local" defines a host name for the running container. This hostname is important as the WebHDFS will redirect to the datanode with this host name. You should define this host name in your client test environment.


### Log Files

To show Logfiles from the running container run command:

    docker logs -f hadoop

### Stopping the container 
To stop and remove the Docker container run the Docker command:

    docker stop hadoop && docker rm hadoop



# 3. Testing 

You can access the hadoop Web Interface from your browser:

	http://localhost:50070/ 

<img src="screen_001.png" alt="Imixs-BPMN" width="640"/>

To test the hadoop file system, first start a bash in the running container:

	docker exec -it hadoop /bin/bash	

Now from the docker console you can create and read a test file:

	echo "Hello Hadoop :-)" > test.txt
	hdfs dfs -copyFromLocal test.txt /
	hdfs dfs -ls /

You will see the output in the hadoop log file and the new created file.

	Found 1 items
	-rw-r--r--   1 root supergroup         18 2017-06-28 21:45 /test.txt
	


## Testing the WebHDFS Rest API

To test the Rest API you can run the culr command from outside the container:


	curl -sS 'http://hadoop.local:14000/webhdfs/v1/test.txt?op=OPEN&user.name=root'
	>Hello Hadoop :-)



# Contribute
The source is available on [Github](https://github.com/imixs/imixs-docker). Please [report any issues](https://github.com/imixs/imixs-docker/issues).

Checkout the sources from GitHub:

	git clone https://github.com/imixs/imixs-docker.git 
	git checkout -b master origin/master

To build the image from the Dockerfile run: 

    docker build --tag=imixs/hadoop ./hadoop

To log into the container, start it and run:
    
    docker exec -it hadoop /bin/bash	

To remove the image run

	docker stop hadoop
	docker rmi imixs/hadoop

	
	
