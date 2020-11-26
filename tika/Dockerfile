FROM openjdk:10

LABEL maintainer="Ralph Soika <ralph.soika@imixs.com>"

# install packages: tesseract-ocr and slim down image
RUN apt-get update \
 && apt-get install --no-install-recommends -y \
  maven unzip tesseract-ocr tesseract-ocr-deu tesseract-ocr-eng \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/man/?? /usr/share/man/??_*


# set environments 
ENV TIKKA_VERSION 1.24.1

# Download latest version
RUN wget https://www-eu.apache.org/dist/tika/tika-server-$TIKKA_VERSION.jar -o tika-server.jar

EXPOSE 9998

ENTRYPOINT java -jar tika-server-$TIKKA_VERSION.jar -host 0.0.0.0
