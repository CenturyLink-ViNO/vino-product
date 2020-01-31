#!/bin/bash

. utils.sh

if [ -f  $SETTINGS_FILE ];then
    .  $SETTINGS_FILE
fi

getVinoName $1

export KEYCLOAK_HOST=$KEYCLOAK_HOST_LAST
if [ "$HTTPS_LAST" == "true" ]; then
  export KEYCLOAK_PROTOCOL=https
  export NODE_TLS_REJECT_UNAUTHORIZED=0 # Comment out if the upstream is not using an self-signed or otherwise unrecognixzed certificate (browser recognized)
else
  export KEYCLOAK_PROTOCOL=http
fi
# export KEYCLOAK_PORT=8080 # Not needed in the default environment
export KEYCLOAK_REALM=vino
export KEYCLOAK_CLIENT_ID=$KEYCLOAK_CLIENT_ID_LAST
# The following should be re-generated in the authentication management UI and updated in this script (/auth/)
export KEYCLOAK_CLIENT_SECRET=$KEYCLOAK_SECRET_LAST
export NODE_RED_URL=$(echo "${KEYCLOAK_PROTOCOL}://${KEYCLOAK_HOST_LAST}/service-manager")
export NODE_OPTIONS="--max-old-space-size=8192"
export VINO_SECRET=$VINO_SECRET_LAST

if [ -f "/var/lib/docker/volumes/${VINONAME}_ViNO-Common/_data/ca-bundle.crt" ]; then
  export NODE_EXTRA_CA_CERTS=/opt/vino/common/ca-bundle.crt
fi;

docker-compose -p $VINONAME up -d
