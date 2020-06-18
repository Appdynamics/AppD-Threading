FROM tomcat:9.0
# https://hub.docker.com/_/tomcat

ENV TOMCAT_BASE_DIR=/usr/local/tomcat

# Configurator
COPY ctl.sh /
COPY envvars.* /

# Configure /mangager/html
RUN mv webapps webapps.orig ; mv webapps.dist webapps


# Copy the App In
# Test at http://localhost:8888/App1-0.0.1-SNAPSHOT/test1
COPY JavaApp1/target/App1-0.0.1-SNAPSHOT.war ${TOMCAT_BASE_DIR}/webapps

COPY load1.sh /


# COPY AppServerAgent-20.5.0.30113.zip /AppDynamics/app/

# https://hub.docker.com/r/appdynamics/java-agent/tags
# --chown=${USER}:${USER}
COPY --from=appdynamics/java-agent:20.5.0 /opt/appdynamics /AppDynamics/app/

RUN cd /; /ctl.sh configure-tomcat ; /ctl.sh configure-tomcat-appd-appagent

EXPOSE 8080
#CMD [ "sleep", "3600" ]

CMD [ "/ctl.sh", "start-tomcat" ]
