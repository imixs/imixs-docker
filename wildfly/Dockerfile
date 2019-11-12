FROM openjdk:10

MAINTAINER Ralph Soika <ralph.soika@imixs.com>

USER root

# Create the 'imixs' user and group used to launch processes
# The uid and gid will be set to 901 to avoid conflicts with offical users on the docker host.
RUN groupadd -r imixs -g 901 && \
    useradd -u 901 -r -g imixs -m -d /home/imixs -s /sbin/nologin -c "imixs user" imixs && \
    chmod 755 /opt     

# Set the working directory
WORKDIR /opt

# set environments 
ENV WILDFLY_VERSION 18.0.0.Final
ENV WILDFLY_HOME=/opt/wildfly
ENV WILDFLY_DEPLOYMENT=$WILDFLY_HOME/standalone/deployments
ENV WILDFLY_CONFIG=$WILDFLY_HOME/standalone/configuration
ENV DEBUG=false


# Add the WildFly distribution to /opt, and make wildfly the owner of the extracted tar content
# Make sure the distribution is available from a well-known place
RUN curl -L http://download.jboss.org/wildfly/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz | tar zx \
 && ln -s $WILDFLY_HOME-$WILDFLY_VERSION/ $WILDFLY_HOME  
	
# Add the Wildfly start script 
ADD wildfly_start.sh $WILDFLY_HOME/
ADD wildfly_add_admin_user.sh $WILDFLY_HOME/       
RUN chmod +x $WILDFLY_HOME/wildfly_add_admin_user.sh $WILDFLY_HOME/wildfly_start.sh

# add eclipsliknk configuration 
COPY modules/ $WILDFLY_HOME/modules/

# change owner of /opt/wildfly
RUN chown -R imixs:imixs $WILDFLY_HOME/

VOLUME /home/imixs

# Set home directory
WORKDIR /home/imixs
USER imixs

# Expose the ports we're interested in
EXPOSE 8080 9990

CMD ["/opt/wildfly/wildfly_start.sh"]