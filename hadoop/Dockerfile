FROM openjdk:8

# Imixs/Archive Version 1.0.0
MAINTAINER ralph.soika@imixs.com

# version 2.7.3
ENV HADOOP_VERSION=2.8.0

USER root

# Create the 'imixs' user and group used to launch processes
# The uid and gid will be set to 901 to avoid conflicts with offical users on the docker host.
RUN groupadd -r imixs -g 901 && \
    useradd -u 901 -r -g imixs -m -d /home/imixs -s /sbin/nologin -c "imixs user" imixs && \
    chmod 755 /opt     

# install packages: openssh-server openssh-client and slim down image
RUN apt-get update \
 && apt-get install --no-install-recommends -y \
 net-tools openssh-server openssh-client \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/man/?? /usr/share/man/??_*

# Set the working directory 
WORKDIR /opt

# Add the hadoop distribution to /opt, and make imixs the owner of the extracted tar content
# Make sure the distribution is available from a well-known place
RUN curl http://mirror.softaculous.com/apache/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz | tar zx \
 && ln -s /opt/hadoop-$HADOOP_VERSION/ /opt/hadoop 

# SSH keygen Passwordless
RUN cd /root \
 && ssh-keygen -t rsa -P '' -f "/root/.ssh/id_rsa" \
 && cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys \
 && chmod 644 /root/.ssh/authorized_keys

# disable ssh strict host key check
RUN sed -i '/StrictHostKeyChecking/s/#//g' /etc/ssh/ssh_config \
    && sed -i '/StrictHostKeyChecking/s/ask/no/g' /etc/ssh/ssh_config

# Set Hadoop environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/ \
  HADOOP_INSTALL=/opt/hadoop \
  PATH=$PATH:/opt/hadoop/bin \
  PATH=$PATH:/opt/hadoop/sbin \
  HADOOP_HOME=/opt/hadoop \
  HADOOP_MAPRED_HOME=/opt/hadoop \
  HADOOP_COMMON_HOME=/opt/hadoop \
  HADOOP_HDFS_HOME=/opt/hadoop \
  HADOOP_YARN_HOME=/opt/hadoop \
  HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop

# issue plattform warning
# http://stackoverflow.com/questions/19943766/hadoop-unable-to-load-native-hadoop-library-for-your-platform-warning
ENV HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"

# add haddop configuration files
ADD resources/core-site.xml /opt/hadoop/etc/hadoop/
ADD resources/hdfs-site.xml /opt/hadoop/etc/hadoop/
ADD resources/mapred-site.xml /opt/hadoop/etc/hadoop/
ADD resources/yarn-site.xml /opt/hadoop/etc/hadoop/

# fix java_home env...
RUN sed -i '/^export JAVA_HOME/ s:.*:export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64:' $HADOOP_INSTALL/etc/hadoop/hadoop-env.sh

# format hadoop fs
RUN /opt/hadoop/bin/hdfs namenode -format

# add bootstrap
ADD resources/bootstrap.sh /etc/bootstrap.sh
RUN chown root:root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh

EXPOSE 9000 50070 50075 

CMD ["/etc/bootstrap.sh", "-d"]