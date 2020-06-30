#!/bin/bash

. utils.sh

if [ -f  $SETTINGS_FILE ];then
    .  $SETTINGS_FILE
fi

VINONAME_DEFAULT=vino
LOCALHOST=$(/opt/vino/vino-docker/getip.sh)
DEFAULT_HTTPS_PROXY="no"
DEFAULT_HTTPS_LOCAL="no"
DEFAULT_VINO_SECRET="unset"
DEFAULT_KEYCLOAK_CLIENT_ID="vino-api"
DEFAULT_KEYCLOAK_SECRET="unset"
DEFAULT_GENERATE_VINO_SECRET="no"
DEFAULT_KEYCLOAK_REALM="vino"
DEFAULT_VINO_ENCRYPTION_KEY=`/usr/bin/cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`

VINONAME_LAST="${VINONAME_LAST:-$VINONAME_DEFAULT}"
DEFAULT_ROUTE_LAST="${DEFAULT_ROUTE_LAST:-$LOCALHOST}"
HTTPS_PROXY_LAST="${HTTPS_PROXY_LAST:-$DEFAULT_HTTPS_PROXY}"
HTTPS_LOCAL_LAST="${HTTPS_LOCAL_LAST:-$DEFAULT_HTTPS_LOCAL}"
VINO_SECRET_LAST="${VINO_SECRET_LAST:-$DEFAULT_VINO_SECRET}"
KEYCLOAK_CLIENT_ID_LAST="${KEYCLOAK_CLIENT_ID_LAST:-$DEFAULT_KEYCLOAK_CLIENT_ID}"
KEYCLOAK_SECRET_LAST="${KEYCLOAK_SECRET_LAST:-$DEFAULT_KEYCLOAK_SECRET}"
KEYCLOAK_REALM_LAST="${KEYCLOAK_REALM_LAST:-$DEFAULT_KEYCLOAK_REALM}"
VINO_ENCRYPTION_KEY_LAST="${VINO_ENCRYPTION_KEY_LAST:-$DEFAULT_VINO_ENCRYPTION_KEY}"

read -p "Vino Name [$VINONAME_LAST]: " VINONAME
read -p "Default route [$DEFAULT_ROUTE_LAST]: " DEFAULT_ROUTE
DEFAULT_ROUTE="${DEFAULT_ROUTE:-$DEFAULT_ROUTE_LAST}"
KEYCLOAK_HOST_LAST="${KEYCLOAK_HOST_LAST:-$DEFAULT_ROUTE}"
read -p "Keycloak host [$KEYCLOAK_HOST_LAST]: " KEYCLOAK_HOST
read -p "Keycloak realm [$KEYCLOAK_REALM_LAST]: " KEYCLOAK_REALM
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

read -p "Are you going to use HTTPS locally (yes/no)? [$HTTPS_LOCAL_LAST]: " HTTPS_LOCAL
HTTPS_LOCAL="${HTTPS_LOCAL:-$HTTPS_LOCAL_LAST}"
while [[ "$HTTPS_LOCAL" != "yes" && "$HTTPS_LOCAL" != "no" ]]; do
  read -p "Are you going to use HTTPS locally (yes/no)? [$HTTPS_LOCAL_LAST]: " HTTPS_LOCAL
  HTTPS_LOCAL="${HTTPS_LOCAL:-$HTTPS_LOCAL_LAST}"
done

if [[ "$HTTPS_LOCAL" == "no" ]]; then
  read -p "Are you using an upstream HTTPS proxy (yes/no)? [$HTTPS_PROXY_LAST]: " HTTPS_PROXY
  HTTPS_PROXY="${HTTPS_PROXY:-$HTTPS_PROXY_LAST}"
  while [[ "$HTTPS_PROXY" != "yes" && "$HTTPS_PROXY" != "no" ]]; do
    read -p "Are you using an upstream HTTPS proxy (yes/no)? [$HTTPS_LAST]: " HTTPS_PROXY
    HTTPS_PROXY="${HTTPS_PROXY:-$HTTPS_PROXY_LAST}"
  done
else
  HTTPS_PROXY="no"
fi

GENERATE_VINO_SECRET="unset"
VINO_SECRET="${VINO_SECRET:-$VINO_SECRET_LAST}"
while [[ "$VINO_SECRET" != "unset" && "$GENERATE_VINO_SECRET" != "yes" && "$GENERATE_VINO_SECRET" != "no" ]]; do
  read -p "Generate new ViNO secret (yes/no)? [$DEFAULT_GENERATE_VINO_SECRET]: " GENERATE_VINO_SECRET
  GENERATE_VINO_SECRET="${GENERATE_VINO_SECRET:-$DEFAULT_GENERATE_VINO_SECRET}"
done
if [[ "$VINO_SECRET" == "unset" || "$GENERATE_VINO_SECRET" == "yes" ]]; then
   VINO_SECRET=$(uuidgen)
fi

read -p "Enter a 32 character string to use as the key for encrypting input parameters in the database: [$VINO_ENCRYPTION_KEY_LAST]: " VINO_ENCRYPTION_KEY
VINO_ENCRYPTION_KEY=${VINO_ENCRYPTION_KEY:-$VINO_ENCRYPTION_KEY_LAST}
while [[ ${#VINO_ENCRYPTION_KEY} -ne 32 ]]; do
  read -p "Enter a 32 character string to use as the key for encrypting input parameters in the database: [$VINO_ENCRYPTION_KEY_LAST]: " VINO_ENCRYPTION_KEY
done

VINONAME="${VINONAME:-$VINONAME_LAST}"
KEYCLOAK_HOST="${KEYCLOAK_HOST:-$KEYCLOAK_HOST_LAST}"
KEYCLOAK_CLIENT_ID="${KEYCLOAK_CLIENT_ID:-$KEYCLOAK_CLIENT_ID_LAST}"
HTTPS_LOCAL="${HTTPS_LOCAL:-$HTTPS_LOCAL_LAST}"
HTTPS_PROXY="${HTTPS_PROXY:-$HTTPS_PROXY_LAST}"
KEYCLOAK_REALM="${KEYCLOAK_REALM:-$KEYCLOAK_REALM_LAST}"
VINO_ENCRYPTION_KEY="${VINO_ENCRYPTION_KEY:-$VINO_ENCRYPTION_KEY_LAST}"

echo VINONAME_LAST=$VINONAME > $SETTINGS_FILE
echo DEFAULT_ROUTE_LAST=$DEFAULT_ROUTE >> $SETTINGS_FILE
echo HTTPS_LOCAL_LAST=$HTTPS_LOCAL >> $SETTINGS_FILE
echo HTTPS_PROXY_LAST=$HTTPS_PROXY >> $SETTINGS_FILE
echo KEYCLOAK_HOST_LAST=$KEYCLOAK_HOST >> $SETTINGS_FILE
echo VINO_SECRET_LAST=$VINO_SECRET >> $SETTINGS_FILE
echo KEYCLOAK_REALM_LAST=$KEYCLOAK_REALM >> $SETTINGS_FILE
echo KEYCLOAK_CLIENT_ID_LAST=$KEYCLOAK_CLIENT_ID >> $SETTINGS_FILE
echo KEYCLOAK_SECRET_LAST=$KEYCLOAK_SECRET >> $SETTINGS_FILE
echo VINO_ENCRYPTION_KEY_LAST=$VINO_ENCRYPTION_KEY >> $SETTINGS_FILE
echo HTTPS_LOCAL_LAST=$HTTPS_LOCAL >> $SETTINGS_FILE

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
CA_BUNDLE_ADDED="${CA_BUNDLE_ADDED_LAST:-false}"
while [[ $ADD_MORE_CERTS != "No" && $ADD_MORE_CERTS != "no" && $ADD_MORE_CERTS != "NO" ]]; do
  read -p "Would you like to add an additional Root CA Certificate to the ViNO Node Runtime? (yes/no): " ADD_MORE_CERTS
  if [[ $ADD_MORE_CERTS != "No" && $ADD_MORE_CERTS != "no" && $ADD_MORE_CERTS != "NO" ]]; then
    CERT_PATH=/some/path/that/doesnt/exist.pem
    while [[ ! -f $CERT_PATH && $CERT_PATH != "cancel" && $CERT_PATH != "Cancel" ]]; do
      read -p "Enter the path to the certificate file you would like to add (path|cancel): " CERT_PATH
    done;
    if [[ $CERT_PATH != "cancel" && $CERT_PATH != "Cancel" ]]; then
      CA_BUNDLE_ADDED="true"
      openssl x509 -in $CERT_PATH -text >> /var/lib/docker/volumes/${VINONAME}_ViNO-Common/_data/ca-bundle.crt
      export X509_CA_BUNDLE=/var/lib/docker/volumes/${VINONAME}_ViNO-Common/_data/ca-bundle.crt
    else
      ADD_MORE_CERTS="No"
    fi
  fi
done;
echo CA_BUNDLE_ADDED_LAST=$CA_BUNDLE_ADDED >> $SETTINGS_FILE

if [ -f "/var/lib/docker/volumes/${VINONAME}_ViNO-Common/_data/ca-bundle.crt" ]; then
  export NODE_EXTRA_CA_CERTS=/opt/vino/common/ca-bundle.crt
fi;

export KEYCLOAK_HOST=$KEYCLOAK_HOST
if [[ "$HTTPS_LOCAL" == "yes" || "$HTTPS_PROXY" == "yes" ]]; then
  export KEYCLOAK_PROTOCOL=https
  export VINO_PORT=3443
  export NGINX_DIR="nginx"
  if [ "$HTTPS_LOCAL" == "yes" ]; then
    if [ "$VINO_CERTIFICATE_LOADED_LAST" == "true" ]; then
      read -p "Would you like to load a new certificate and key pair for SSL? (yes|no): " LOAD_CERTS
      while [[ "$LOAD_CERTS" != "yes" && "$LOAD_CERTS" != "no" ]]; do
        read -p "Would you like to load a new certificate and key pair for SSL? (yes|no): " LOAD_CERTS
      done
    else
      LOAD_CERTS="yes"
    fi
    if [ "$LOAD_CERTS" == "yes" ]; then
      CERT_PATH=/some/path/that/doesnt/exist.pem
      while [[ ! -f $CERT_PATH && $CERT_PATH != "cancel" && $CERT_PATH != "Cancel" ]]; do
        read -p "Enter the path to the certificate file you would like to use to enable SSL (path|cancel): " CERT_PATH
      done;
      if [[ $CERT_PATH != "cancel" && $CERT_PATH != "Cancel" ]]; then
        /usr/bin/cp $CERT_PATH /var/lib/docker/volumes/${VINONAME}_ViNO-Common/_data/server.cert
        /usr/bin/chmod 600 /var/lib/docker/volumes/${VINONAME}_ViNO-Common/_data/server.cert
        KEY_PATH=/some/path/that/doesnt/exist.key
        while [[ ! -f $KEY_PATH && $KEY_PATH != "cancel" && $KEY_PATH != "Cancel" ]]; do
          read -p "Enter the path to the key file you would like to use to enable SSL (path|cancel): " KEY_PATH
        done;
        if [[ $KEY_PATH && $KEY_PATH != "cancel" && $KEY_PATH != "Cancel" ]]; then
          /usr/bin/cp $KEY_PATH /var/lib/docker/volumes/${VINONAME}_ViNO-Common/_data/server.key
          /usr/bin/chmod 600 /var/lib/docker/volumes/${VINONAME}_ViNO-Common/_data/server.key
          export KEYCLOAK_PRE_START_SCRIPT="keycloak_docker_entrypoint_ssl.sh"
          export NGINX_DIR="nginx.ssl"
          export VINO_HTTPS="true"
          SSL_CERTS_LOADED="true"
        else
          SSL_CERTS_LOADED="false"
        fi
      else
        SSL_CERTS_LOADED="false"
      fi
    fi
  fi
  # export NODE_TLS_REJECT_UNAUTHORIZED=0 # Uncomment if the upstream, or local containers are using a cert not signed by a trusted CA
else
  export KEYCLOAK_PROTOCOL=http
  export KEYCLOAK_PRE_START_SCRIPT="keycloak_docker_entrypoint.sh"
  export VINO_PORT=3000
  export NGINX_DIR="nginx"
fi
echo VINO_CERTIFICATE_LOADED_LAST=$SSL_CERTS_LOADED >> $SETTINGS_FILE
# export KEYCLOAK_PORT=8080 # Not needed in the default environment
export KEYCLOAK_REALM=$KEYCLOAK_REALM_LAST
export KEYCLOAK_CLIENT_ID=$KEYCLOAK_CLIENT_ID
# The following should be re-generated in the authentication management UI and updated in this script (/auth/)
export KEYCLOAK_CLIENT_SECRET=$KEYCLOAK_SECRET
export NODE_RED_URL=$(echo "${KEYCLOAK_PROTOCOL}://${KEYCLOAK_HOST}/service-manager")
export NODE_OPTIONS="--max-old-space-size=8192"
export VINO_SECRET=$VINO_SECRET
export VINO_ENCRYPTION_KEY=$VINO_ENCRYPTION_KEY

docker-compose -p $VINONAME up -d

secs=120
echo
echo "Waiting ${secs} seconds for containers to initialize..."
while [ $secs -gt 0 ]; do
   echo -ne "Time remaining: $secs\033[0K\r"
   sleep 1
   : $((secs--))
done
