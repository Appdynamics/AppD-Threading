#!/bin/bash
#
# Deploy the machineagent inside a Docker Container or as Docker Service
#
# Maintainer: David Ryder, david.ryder@appdynamics.com
#
# Collects metrics for Docker containers on the same host, and server and machine metrics for the host itself.
# The Controller shows all monitored containers, for each host, and the container and host IDs, for each container.
# Reference https://docs.appdynamics.com/display/PRO45/Monitoring+Containers+with+Docker+Visibility
#
CMD=${1:-"help"} # All Commands
CONTAINER_NAME="appdmachineagent"
case "$CMD" in
  test)
    echo "Test"
    ;;
  container)
    docker run --rm -it -d -e APPDYNAMICS_CONTROLLER_HOST_NAME=$APPDYNAMICS_CONTROLLER_HOST_NAME \
    -e APPDYNAMICS_CONTROLLER_PORT=$APPDYNAMICS_CONTROLLER_PORT \
    -e APPDYNAMICS_CONTROLLER_SSL_ENABLED=$APPDYNAMICS_CONTROLLER_SSL_ENABLED \
    -e APPDYNAMICS_AGENT_ACCOUNT_NAME=$APPDYNAMICS_AGENT_ACCOUNT_NAME \
    -e APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY=$APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY \
    -e APPDYNAMICS_SIM_ENABLED="true" \
    -e APPDYNAMICS_DOCKER_ENABLED="true" \
    -v /:/hostroot:ro -v /var/run/docker.sock:/var/run/docker.sock \
    --name $CONTAINER_NAME appdynamics/machine-agent-analytics:latest /opt/appdynamics/startup.sh
    ;;
  service)
    docker service create --mode global \
      -e APPDYNAMICS_CONTROLLER_HOST_NAME=$APPDYNAMICS_CONTROLLER_HOST_NAME \
      -e APPDYNAMICS_CONTROLLER_PORT=$APPDYNAMICS_CONTROLLER_PORT \
      -e APPDYNAMICS_CONTROLLER_SSL_ENABLED=$APPDYNAMICS_CONTROLLER_SSL_ENABLED  \
      -e APPDYNAMICS_AGENT_ACCOUNT_NAME=$APPDYNAMICS_AGENT_ACCOUNT_NAME \
      -e APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY=$APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY\
      -e APPDYNAMICS_SIM_ENABLED="true" \
      -e APPDYNAMICS_DOCKER_ENABLED="true" \
      --mount type=bind,source=/,target=/hostroot,readonly \
      --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
      --name $CONTAINER_NAME appdynamics/machine-agent-analytics:latest
    ;;
  stop)
    # Stop the container
    ID=`docker inspect --format='{{ .Id }}' $CONTAINER_NAME`
    docker stop $ID

    # Stop the service
    ID=`docker service inspect --format='{{ .ID }}' $CONTAINER_NAME`
    docker service rm $ID
  ;;
  *)
    echo "Commands:"
    echo "container - start the AppDynamics Machine Agent in a Docker Container"
    echo "service   - start the AppDynamics Machine Agent as Docker Service"
    echo "stop      - stop AppDynamics Machine Agent"
    ;;
esac
