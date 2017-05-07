FROM imixs/wildfly:latest

# Imixs-Office-Workflow Version 1.0.0
MAINTAINER ralph.soika@imixs.com

USER root

# add configuration files
ADD configuration/imixsrealm.properties /opt/wildfly/standalone/configuration/
ADD configuration/standalone.xml /opt/wildfly/standalone/configuration/


# add deployments units
ADD deployments/ /opt/wildfly/standalone/deployments/


# create log directory
RUN mkdir /opt/wildfly/standalone/log/ 

# change owner of /opt/wildfly
RUN chown -R wildfly /opt/wildfly/standalone/
RUN chgrp -R wildfly /opt/wildfly/standalone/


# Specify the user which should be used to execute all commands below
USER wildfly

# mount volumes
VOLUME /opt/wildfly/standalone/configuration/
VOLUME /opt/wildfly/standalone/deployments/
VOLUME /opt/wildfly/standalone/log/
