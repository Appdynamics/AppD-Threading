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

_validateEnvironmentVars() { echo "Validating environment variables for $1" ; shift 1 ; VAR_LIST=("$@") ; for i in "${VAR_LIST[@]}"; do echo "  $i=${!i}" ; if [ -z ${!i} ] || [[ "${!i}" == REQUIRED_* ]]; then echo "Environment variable not set: $i"; ERROR="1"; fi done ; [ "$ERROR" == "1" ] && { echo "Exiting"; exit 1; } }

case "$CMD" in
  test)
    echo "Test"
    ;;
  container)
   _validateEnvironmentVars "Docker Container " "APPDYNAMICS_CONTROLLER_HOST_NAME" "APPDYNAMICS_CONTROLLER_PORT" "APPDYNAMICS_CONTROLLER_SSL_ENABLED" "APPDYNAMICS_AGENT_ACCOUNT_NAME" "APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY"
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
    _validateEnvironmentVars "Docker Service " "APPDYNAMICS_CONTROLLER_HOST_NAME" "APPDYNAMICS_CONTROLLER_PORT" "APPDYNAMICS_CONTROLLER_SSL_ENABLED" "APPDYNAMICS_AGENT_ACCOUNT_NAME" "APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY"
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
  validate)
    _validateEnvironmentVars "Docker Container " "APPDYNAMICS_CONTROLLER_HOST_NAME" "APPDYNAMICS_CONTROLLER_PORT" "APPDYNAMICS_CONTROLLER_SSL_ENABLED" "APPDYNAMICS_AGENT_ACCOUNT_NAME" "APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY"
    if [ $APPDYNAMICS_CONTROLLER_SSL_ENABLED = "true" ||  $APPDYNAMICS_CONTROLLER_SSL_ENABLED = "TRUE" = ]; then
      APPD_CONTROLLER_PROTOCOL="https"
    else
      APPD_CONTROLLER_PROTOCOL="http"
    fi
    CONTROLLER_STATUS_URL="$APPD_CONTROLLER_PROTOCOL://$APPDYNAMICS_CONTROLLER_HOST_NAME:$APPDYNAMICS_CONTROLLER_PORT/controller/rest/serverstatus"
    echo $CONTROLLER_STATUS_URL
    curl $CONTROLLER_STATUS_URL
    if [ $? -ne 0 ]; then
        echo "Failed to connect to: $CONTROLLER_STATUS_URL"
        exit 0
    else
        echo "Connection succeeded: $CONTROLLER_STATUS_URL"
    fi
    ;;
  *)
    echo "Commands:"
    echo "container - start the AppDynamics Machine Agent in a Docker Container"
    echo "service   - start the AppDynamics Machine Agent as Docker Service"
    echo "stop      - stop AppDynamics Machine Agent"
    echo "validate  - validate connection to the AppDynamics Controller"
    ;;
esac
