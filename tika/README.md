# imixs/tika

The Docker Image 'imixs/tika' provides a Tika Server. This server can be used for OCR via a Rest API provided by the [Apache Tika Project](https://tika.apache.org/)

## Features

* inherit form official openJDK
* runs tika and tesseract with OpenJDK 10
* supported languages: de, en


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
	
PDF File with embedded image

	$ curl -T test/Dokument01.pdf http://localhost:9998/tika --header "X-Tika-PDFOcrStrategy: ocr_only"



# Running and stopping a container

You can start an instance of the postgres service with the Docker run command:

	docker run -it --rm --name="tika" \
	    -p 9998:9998 \
	    imixs/tika

To run tika in a docker-compose or docker swarm environment just use the following setup:

	  tika: 
	    image: imixs/tika
	    ports:
	      - "9998:9998"  



## Docker Swarm and Kubernetes

The imixs/tiker image can perfectly be used in a docker swarm environment or in a kubernetes cluster. So you have a single service providing OCR functionallity via a Rest API.

## Imixs-Archive
 
The [Imixs-Archive Project](https://github.com/imixs/imixs-archive/tree/master/imixs-archive-documents) provides a Imixs-Workflow plugin to be used for OCR. 



# Configuration

Out of the box, Apache Tika will start with the default configuration. Setting the environment Variable *TIKA_CONFIG* you can specify a custom tika configuration file to be used by the tika server. 

Through a custom Tika Config xml file, it is possible to have a high degree of control over which detectors are or aren't used, in what order of preferences etc. It is also possible to override just certain parts, to (for example) have "default except for no POIFS Container Detction".
You will find more about the configuration details [here](https://tika.apache.org/1.24.1/configuring.html).

This is an example how you can set a custom tika-config.xml file in a docker-compose.yaml defintion:

	  tika: 
	    image: imixs/tika
	    environment:
	      TIKA_CONFIG: "/tika-config.xml"
	    ...
	    volumes:
	      - ~/my-config/tika-config.xml:/tika-config.xml
	    ....
	  ...


This is an example for a tika configuration with higher OCR resolution:

	<?xml version="1.0" encoding="UTF-8"?>
	<properties>
	  <parsers>
	    <parser class="org.apache.tika.parser.DefaultParser"></parser>
	    <parser class="org.apache.tika.parser.pdf.PDFParser">
	            <params>
	            	<!-- OCR_ONLY  |  OCR_AND_TEXT_EXTRACTION  -->
	                <param name="ocrStrategy" type="string">OCR_AND_TEXT_EXTRACTION</param>
	                <!-- GRAY | RGB  -->
	                <param name="ocrImageType" type="string">RGB</param>
	                <param name="ocrDPI" type="int">400</param>
	            </params>
	    </parser>
	  </parsers>
	</properties>

## OCR Tesseract

You can also confgure the OCR feature based on Tesseract. Find details [here](https://cwiki.apache.org/confluence/display/TIKA/TikaOCR).


# Contribute
The source is available on [Github](https://github.com/imixs/imixs-docker). Please [report any issues](https://github.com/imixs/imixs-docker/issues).

Checkout the sources from GitHub:

	git clone https://github.com/imixs/imixs-docker.git 
	git checkout -b master origin/master

To build the image from the Dockerfile run: 

    $ docker build --tag=imixs/tika ./tika

## Push manually to Docker repo (Docker-Hub)

To push the image to a docker repo: 


	$ docker build -t imixs/tika:X.X.X .
	$ docker push imixs/tika:X.X.X 
	
	
