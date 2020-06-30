#!/bin/bash

. utils.sh

if [ -f  $SETTINGS_FILE ];then
    .  $SETTINGS_FILE
fi

getVinoName $1

export KEYCLOAK_HOST=$KEYCLOAK_HOST_LAST
if [[ "$HTTPS_LOCAL_LAST" == "yes" || "$HTTPS_PROXY_LAST" == "yes" ]]; then
  export KEYCLOAK_PROTOCOL=https
  export VINO_PORT=3443
  export NGINX_DIR="nginx"
  if [ "$HTTPS_LOCAL_LAST" == "yes" ]; then
    export KEYCLOAK_PRE_START_SCRIPT="keycloak_docker_entrypoint_ssl.sh"
    export NGINX_DIR="nginx.ssl"
    export VINO_HTTPS="true"
  fi
  # export NODE_TLS_REJECT_UNAUTHORIZED=0 # Uncomment if the upstream, or local containers are using a cert not signed by a trusted CA
else
  export NGINX_DIR="nginx"
  export KEYCLOAK_PROTOCOL=http
  export KEYCLOAK_PRE_START_SCRIPT="keycloak_docker_entrypoint.sh"
  export VINO_PORT=3000
fi
if [[ "$CA_BUNDLE_ADDED_LAST" == "true" ]]; then
  export X509_CA_BUNDLE=/var/lib/docker/volumes/${VINONAME}_ViNO-Common/_data/ca-bundle.crt
fi

# export KEYCLOAK_PORT=8080 # Not needed in the default environment
export KEYCLOAK_REALM=$KEYCLOAK_REALM_LAST
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
