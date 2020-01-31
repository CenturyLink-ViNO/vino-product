#!/bin/bash

. utils.sh

if [ -f  $SETTINGS_FILE ];then
    .  $SETTINGS_FILE
fi

getVinoName $1

#This is an arbitrary limit for now
MAX_SERVICE_MANAGERS=50
CURRENT_SERVICE_MANAGER_COUNT=$(docker ps | grep service-manager | wc -l)
NEXT_SERVICE_MANAGER_IDX=$((CURRENT_SERVICE_MANAGER_COUNT + 1))

if [ $NEXT_SERVICE_MANAGER_IDX -gt $MAX_SERVICE_MANAGERS ]; then
   echo "Exceeded maxiumum number of allowed service manager instances"
   exit 1
fi


export KEYCLOAK_HOST=$(./getip.sh)
# export KEYCLOAK_PORT=8080 # Not needed in the default environment
export KEYCLOAK_REALM=vino
export KEYCLOAK_CLIENT_ID=$KEYCLOAK_CLIENT_ID_LAST
# The following should be re-generated in the authentication management UI and updated in this script (/auth/)
export KEYCLOAK_CLIENT_SECRET=$KEYCLOAK_SECRET_LAST
export NODE_RED_URL=$(echo "http://${KEYCLOAK_HOST}/service-manager${NEXT_SERVICE_MANAGER_IDX}")
export SERVICE_MANAGER_INSTANCE=${NEXT_SERVICE_MANAGER_IDX}

docker-compose -p $VINONAME run -d --name service-manager_${NEXT_SERVICE_MANAGER_IDX} service-manager

secs=120
echo
echo "Waiting ${secs} seconds for containers to initialize..."
while [ $secs -gt 0 ]; do
   echo -ne "Time remaining: $secs\033[0K\r"
   sleep 1
   : $((secs--))
done

APICONTAINER=$(getContainerIDFromImageName vino-api)

echo
echo
echo "Whitelisting service-manager_${NEXT_SERVICE_MANAGER_IDX}..."
docker exec -it $APICONTAINER curl -kv 'http://127.0.0.1:8034/auth/networkaccess' -H 'Content-Type: application/json' --request POST --data-binary  "{ \"address\":\"service-manager_${NEXT_SERVICE_MANAGER_IDX}\" }"
