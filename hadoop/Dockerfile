FROM openjdk:8

# Imixs/Archive Version 1.0.0
MAINTAINER ralph.soika@imixs.com

USER root

ENV HADOOP_VERSION=3.0.0-beta1

# Create the 'hduser' user and group 'hadoop' used to launch processes
# The uid and gid will be set to 901 to avoid conflicts with offical users on the docker host.
RUN groupadd -r hadoop -g 901 && \
    useradd -u 901 -r -g hadoop -m -d /home/hduser -s /sbin/nologin -c "hduser user" hduser && \
    chmod 755 /opt       

# install packages: openssh-server openssh-client and slim down image
RUN apt-get update \
 && apt-get install --no-install-recommends -y \
 net-tools openssh-server openssh-client \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/man/?? /usr/share/man/??_*

# Set the working directory 
WORKDIR /opt

# Add the hadoop distribution to /opt, and make hduser the owner of the extracted tar content
# Make sure the distribution is available from a well-known place
RUN curl http://mirror.softaculous.com/apache/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz | tar zx \
 && ln -s /opt/hadoop-$HADOOP_VERSION/ /opt/hadoop 


# Setup passwordless ssh
ADD resources/ssh/* /etc/ssh/
RUN rm -f /etc/ssh/ssh_host_ecdsa_key && ssh-keygen -q -N "" -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key && \ 
	rm -f /etc/ssh/ssh_host_ed25519_key && ssh-keygen -q -N "" -t ed25519 -f /etc/ssh/ssh_host_ed25519_key && \
    rm -f /etc/ssh/ssh_host_dsa_key && ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key && \
    rm -f /etc/ssh/ssh_host_rsa_key && ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key && \
    rm -f /etc/ssh/id_rsa && ssh-keygen -q -N "" -t rsa -f /etc/ssh/id_rsa && \ 
	cp /etc/ssh/id_rsa.pub /etc/ssh/authorized_keys && \
    mkdir -p /root/.ssh && \
    cp /etc/ssh/ssh_config /root/.ssh/config && \
    cp /etc/ssh/authorized_keys /root/.ssh/authorized_keys && \
    cp /etc/ssh/id_rsa /root/.ssh/id_rsa && \
    chmod 700 /root/.ssh && \
    chmod 600 /root/.ssh/config && \
    chmod 600 /root/.ssh/id_rsa && \
    chmod 600 /root/.ssh/authorized_keys && \
    cp -a /root/.ssh /home/hduser/.ssh && \
    chown -R hduser:hadoop /home/hduser/.ssh


# Set Hadoop environment variables
ENV HADOOP_INSTALL=/opt/hadoop \
  HADOOP_HOME=/opt/hadoop \
  HADOOP_MAPRED_HOME=/opt/hadoop \
  HADOOP_COMMON_HOME=/opt/hadoop \
  HADOOP_HDFS_HOME=/opt/hadoop \
  HADOOP_YARN_HOME=/opt/hadoop \
  HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop
  
ENV PATH=$PATH:/opt/hadoop/bin 
ENV PATH=$PATH:/opt/hadoop/sbin    
      
# fix java_home env...
RUN sed -i '/^export JAVA_HOME/ s:.*:export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64:' $HADOOP_INSTALL/etc/hadoop/hadoop-env.sh


# issue plattform warning
# http://stackoverflow.com/questions/19943766/hadoop-unable-to-load-native-hadoop-library-for-your-platform-warning
ENV HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"

# add haddop configuration files
ADD resources/core-site.xml /opt/hadoop/etc/hadoop/
ADD resources/hdfs-site.xml /opt/hadoop/etc/hadoop/
ADD resources/mapred-site.xml /opt/hadoop/etc/hadoop/
ADD resources/yarn-site.xml /opt/hadoop/etc/hadoop/


# add bootstrap
ADD resources/bootstrap.sh /etc/bootstrap.sh

# Make hduser the owner of the hadoop process  
RUN chown -R hduser:hadoop $HADOOP_HOME && \
    chmod +x $HADOOP_HOME/etc/hadoop/*-env.sh && \
    mkdir -p /data/hdfs && \
    chown -R hduser:hadoop /data/hdfs && \
    rm -rf /tmp/*
    
RUN chown hduser:root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh

# TODO : try to start hadoop as user hduser 
USER hduser

WORKDIR $HADOOP_HOME

VOLUME /data/hdfs

# TODO: we can't yet start hadoop as user hduser
USER root

EXPOSE 9000 50070 50075 14000

CMD ["/etc/bootstrap.sh", "-d"]