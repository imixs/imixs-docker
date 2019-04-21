FROM openjdk:10


MAINTAINER Ralph Soika <ralph.soika@imixs.com>

# install packages: psql and slim down image
RUN apt-get update \
 && apt-get install --no-install-recommends -y \
  maven unzip tesseract-ocr tesseract-ocr-deu tesseract-ocr-eng \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/man/?? /usr/share/man/??_*


# setup tika server
RUN mkdir /setup
ADD install-tika.sh /setup/install-tika.sh
RUN chmod +x /setup/install-tika.sh
RUN /setup/install-tika.sh


ENTRYPOINT java -jar tika-server.jar -host 0.0.0.0

EXPOSE 9998