#!/bin/bash

. utils.sh

if [ -f  $SETTINGS_FILE ];then
    .  $SETTINGS_FILE
fi

VINONAME_DEFAULT=vino
LOCALHOST=$(/opt/vino/vino-docker/getip.sh)
DEFAULT_HTTPS="false"
DEFAULT_VINO_SECRET="unset"
DEFAULT_KEYCLOAK_CLIENT_ID="vino-api"
DEFAULT_KEYCLOAK_SECRET="unset"
DEFAULT_GENERATE_VINO_SECRET="no"

VINONAME_LAST="${VINONAME_LAST:-$VINONAME_DEFAULT}"
DEFAULT_ROUTE_LAST="${DEFAULT_ROUTE_LAST:-$LOCALHOST}"
HTTPS_LAST="${HTTPS_LAST:-$DEFAULT_HTTPS}"
VINO_SECRET_LAST="${VINO_SECRET_LAST:-$DEFAULT_VINO_SECRET}"
KEYCLOAK_CLIENT_ID_LAST="${KEYCLOAK_CLIENT_ID_LAST:-$DEFAULT_KEYCLOAK_CLIENT_ID}"
KEYCLOAK_SECRET_LAST="${KEYCLOAK_SECRET_LAST:-$DEFAULT_KEYCLOAK_SECRET}"

read -p "Vino Name [$VINONAME_LAST]: " VINONAME
read -p "Default route [$DEFAULT_ROUTE_LAST]: " DEFAULT_ROUTE
DEFAULT_ROUTE="${DEFAULT_ROUTE:-$DEFAULT_ROUTE_LAST}"
KEYCLOAK_HOST_LAST="${KEYCLOAK_HOST_LAST:-$DEFAULT_ROUTE}"
read -p "Keycloak host [$KEYCLOAK_HOST_LAST]: " KEYCLOAK_HOST
read -p "Keycloak client ID [$KEYCLOAK_CLIENT_ID_LAST]: " KEYCLOAK_CLIENT_ID
KEYCLOAK_SECRET="${KEYCLOAK_SECRET:-$KEYCLOAK_SECRET_LAST}"
if [[ "$KEYCLOAK_SECRET" == "unset" ]]; then
   while [[ "$KEYCLOAK_SECRET" == "unset" || "$KEYCLOAK_SECRET" == "" ]]; do
     read -p "Keycloak client secret: " KEYCLOAK_SECRET
     KEYCLOAK_SECRET="${KEYCLOAK_SECRET:-$KEYCLOAK_SECRET_LAST}"
   done
else
   read -p "Keycloak client secret (leave blank to use previous secret): " KEYCLOAK_SECRET
   KEYCLOAK_SECRET="${KEYCLOAK_SECRET:-$KEYCLOAK_SECRET_LAST}"
fi
read -p "Using upstream HTTPS proxy (true/false)? [$HTTPS_LAST]: " HTTPS
HTTPS="${HTTPS:-$HTTPS_LAST}"
while [[ "$HTTPS" != "true" && "$HTTPS" != "false" ]]; do
  read -p "Using upstream HTTPS proxy (true/false)? [$HTTPS_LAST]: " HTTPS
  HTTPS="${HTTPS:-$HTTPS_LAST}"
done
GENERATE_VINO_SECRET="unset"
VINO_SECRET="${VINO_SECRET:-$VINO_SECRET_LAST}"
while [[ "$VINO_SECRET" != "unset" && "$GENERATE_VINO_SECRET" != "yes" && "$GENERATE_VINO_SECRET" != "no" ]]; do
  read -p "Generate new ViNO secret (yes/no)? [$DEFAULT_GENERATE_VINO_SECRET]: " GENERATE_VINO_SECRET
  GENERATE_VINO_SECRET="${GENERATE_VINO_SECRET:-$DEFAULT_GENERATE_VINO_SECRET}"
done
if [[ "$VINO_SECRET" == "unset" || "$GENERATE_VINO_SECRET" == "yes" ]]; then
   VINO_SECRET=$(uuidgen)
fi
VINONAME="${VINONAME:-$VINONAME_LAST}"
KEYCLOAK_HOST="${KEYCLOAK_HOST:-$KEYCLOAK_HOST_LAST}"
KEYCLOAK_CLIENT_ID="${KEYCLOAK_CLIENT_ID:-$KEYCLOAK_CLIENT_ID_LAST}"
HTTPS="${HTTPS:-$HTTPS_LAST}"

echo VINONAME_LAST=$VINONAME > $SETTINGS_FILE
echo DEFAULT_ROUTE_LAST=$DEFAULT_ROUTE >> $SETTINGS_FILE
echo HTTPS_LAST=$HTTPS >> $SETTINGS_FILE
echo KEYCLOAK_HOST_LAST=$KEYCLOAK_HOST >> $SETTINGS_FILE
echo VINO_SECRET_LAST=$VINO_SECRET >> $SETTINGS_FILE
echo KEYCLOAK_CLIENT_ID_LAST=$KEYCLOAK_CLIENT_ID >> $SETTINGS_FILE
echo KEYCLOAK_SECRET_LAST=$KEYCLOAK_SECRET >> $SETTINGS_FILE

# configure docker logs
mkdir -p /etc/docker/
cat > /etc/docker/daemon.json <<- "EOF"
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF

docker-compose -p $VINONAME up -d
bridgename=$(ip add | grep $(docker network inspect ${VINONAME}_default | grep Subnet | sed -n 's/.*Subnet.*"\(.*\).0\(\/.*\)".*/\1.1\2/p') | awk 'NF>1{print $NF}')
if [ -e /usr/bin/nmcli ] && [ -e /usr/bin/firewall-cmd ]; then
   systemctl start firewalld
   systemctl stop NetworkManager
   firewall-cmd --zone=trusted --change-interface=$bridgename --permanent
   systemctl start NetworkManager
   firewall-cmd --reload
   systemctl restart docker.service
else
   echo "Firewalld and/or NetworkManager not found."
   echo "WARNING: This system is not fully supported, and issues may arise when running ViNO on it!"
fi

ADD_MORE_CERTS="Yes"
while [[ $ADD_MORE_CERTS != "No" && $ADD_MORE_CERTS != "no" && $ADD_MORE_CERTS != "NO" ]]; do
  read -p "Would you like to add an additional Root CA Certificate to the ViNO Node Runtime? (Yes/No)" ADD_MORE_CERTS
  if [[ $ADD_MORE_CERTS != "No" && $ADD_MORE_CERTS != "no" && $ADD_MORE_CERTS != "NO" ]]; then
    CERT_PATH=/some/path/that/doesnt/exist.pem
    while [[ ! -f $CERT_PATH && $CERT_PATH != "cancel" && $CERT_PATH != "Cancel" ]]; do
      read -p "Enter the path to the certificate file you would like to add: (Path|cancel)" CERT_PATH
    done;
    if [[ $CERT_PATH != "cancel" && $CERT_PATH != "Cancel" ]]; then
      openssl x509 -in $CERT_PATH -text >> /var/lib/docker/volumes/${VINONAME}_ViNO-Common/_data/ca-bundle.crt
    else
      ADD_MORE_CERTS="No"
    fi
  fi
done;

if [ -f "/var/lib/docker/volumes/${VINONAME}_ViNO-Common/_data/ca-bundle.crt" ]; then
  export NODE_EXTRA_CA_CERTS=/opt/vino/common/ca-bundle.crt
fi;

export KEYCLOAK_HOST=$KEYCLOAK_HOST
if [ "$HTTPS" == "true" ]; then
  export KEYCLOAK_PROTOCOL=https
  export NODE_TLS_REJECT_UNAUTHORIZED=0 # Comment out if the upstream is not using an self-signed or otherwise unrecognixzed certificate (browser recognized)
else
  export KEYCLOAK_PROTOCOL=http
fi
# export KEYCLOAK_PORT=8080 # Not needed in the default environment
export KEYCLOAK_REALM=vino
export KEYCLOAK_CLIENT_ID=$KEYCLOAK_CLIENT_ID
# The following should be re-generated in the authentication management UI and updated in this script (/auth/)
export KEYCLOAK_CLIENT_SECRET=$KEYCLOAK_SECRET
export NODE_RED_URL=$(echo "${KEYCLOAK_PROTOCOL}://${KEYCLOAK_HOST}/service-manager")
export NODE_OPTIONS="--max-old-space-size=8192"
export VINO_SECRET=$VINO_SECRET

docker-compose -p $VINONAME up -d

secs=120
echo
echo "Waiting ${secs} seconds for containers to initialize..."
while [ $secs -gt 0 ]; do
   echo -ne "Time remaining: $secs\033[0K\r"
   sleep 1
   : $((secs--))
done
