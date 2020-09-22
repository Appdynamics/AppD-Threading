FROM appdynamics/machine-agent-analytics:latest

# Turn on Debugging
RUN sed -i 's/level="info"/level="debug"/g' /opt/appdynamics/conf/logging/log4j.xml

ENTRYPOINT sleep 3600
