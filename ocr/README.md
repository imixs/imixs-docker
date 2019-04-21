# imixs/ocr

The Docker Image 'imixs/ocr' provides a Tika / Tesseract installation

## Features

* inherit form official openJDK
* runs tika and tesseract with OpenJDK 10
* suported languages: de, en


## The Rest API

The Rest API is provided by the [Apache Tika Project](https://tika.apache.org/). You will find details about the API [here](https://wiki.apache.org/tika/TikaJAXRS).

### Get the Text of a Document

	$ curl -X PUT --data-binary @GeoSPARQL.pdf http://localhost:9998/tika --header "Content-type: application/pdf"
	$ curl -T price.xls http://localhost:9998/tika --header "Accept: text/html"
	$ curl -T price.xls http://localhost:9998/tika --header "Accept: text/plain"

Examples:


	$ curl -T test/IMG_20190421_132434.jpg http://localhost:9998/tika
	$ curl -T test/imixs-workflow.pdf http://localhost:9998/tika
	$ curl -T test/zugferd_invoice.pdf http://localhost:9998/tika
	$ curl -T test/IMG_20190421_133732.jpg http://localhost:9998/tika
	
	


# 2. Running and stopping a container

You can start an instance of the postgres service with the Docker run command:

	docker run --name="ocr" \
	    -p 9998:9998 \
	    imixs/ocr


# Contribute
The source is available on [Github](https://github.com/imixs/imixs-docker). Please [report any issues](https://github.com/imixs/imixs-docker/issues).

Checkout the sources from GitHub:

	git clone https://github.com/imixs/imixs-docker.git 
	git checkout -b master origin/master

To build the image from the Dockerfile run: 

    docker build --tag=imixs/ocr ./ocr


	
	
