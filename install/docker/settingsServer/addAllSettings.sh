#!/bin/bash
## Script to push Settings Constants to the VINO Server. Handles the authentication against keycloak
## Requires a valid username/password for accessing the VINO Server
##   Usage: $0 -u <username> -p <password> -h <host>

# STEP 1:  Set some variables that we need early
USERNAME=""
PASSWORD=""
VINO_HOST=""
ADD_ALL=false
dirname=`dirname $0`
SETTINGS_DIR=`realpath ${dirname}/constants`
################################################################################
###
###  Print the program usage followed by an optional error message (param 2)
###  exits using the exit code in parameter 1
###  PARAMS:
###     $1  : The value to use in the call to exit
###     $2  : An optional error message
###
printUsageAndExit()
{
   echo "Usage: $0 -h <hostname> [-u <user>] [-p <password>]"
   echo "       hostname :  The hostname or IP address of the VINO service"
   echo "       user     :  The username to use when accessing the VINO system"
   echo "       password   :  The password to use when accessing the VINO system"
   echo "       -a         :  (Optional) Adds all available settings without prompting"

   echo ""
   if [ -n "$2" ]
   then
      echo $2
   fi
   exit $1
}

##  Parse the parameters
while [ -n "$1" ]
do
   case "$1" in
      --help)
         printUsageAndExit 0
         ;;
      -help)
         printUsageAndExit 0
         ;;
      -h)
         shift
         VINO_HOST="$1"
         ;;
      --host)
         shift
         VINO_HOST="$1"
         ;;
      -p)
         shift
         PASSWORD="$1"
         ;;
      --password)
         shift
         PASSWORD="$1"
         ;;
      -u)
         shift
         USERNAME="$1"
         ;;
      --user)
         shift
         USERNAME="$1"
         ;;
      -a)
         shift
         ADD_ALL=true
         ;;
      *)
         printUsageAndExit 1 "Unknown parameter/switch: $1"
         ;;
   esac
   shift
done

if [ -z "$VINO_HOST" ]
then
   echo "Host not set.  -h switch is required"
   exit 1
fi
if [ -z "$USERNAME" ]
then
   echo "Username not set.  Use -u switch"
   exit 1
fi
if [ -z "$PASSWORD" ]
then
   echo "Password not set.  Use -p switch"
   exit 1
fi

# Inputs are valid.  Start the token request
# Fetch the keycloak.json file.  This has fields that we need to build a token request
KC_JSON=`curl -s http://$VINO_HOST/lib/abacus/user/keycloak.json`
if [ $? -ne 0 ]
then
   echo "Unable to fetch keycloak.json from $VINO_HOST"
   exit 1
fi

REALM=`echo $KC_JSON | jq '.realm?' | cut -f 2 -d '"'`
CLIENT_ID=`echo $KC_JSON | jq '.resource?' | cut -f 2 -d '"'`
SECRET=`echo $KC_JSON | jq '.credentials.secret?' | cut -f 2 -d '"'`
if [ -z "$SECRET" ]
then
   echo "No credentials/secret field in the keycloak.json file.  Unable to request token"
   echo ""
   echo "$KC_JSON"
   exit 1
fi

TOKEN_URI="auth/realms/$REALM/protocol/openid-connect/token"
URL="http://$VINO_HOST/$TOKEN_URI"
HDR_CONTENTTYPE="Content-Type: application/x-www-form-urlencoded"

RSP=`curl -s -H "Content-Type: application/x-www-form-urlencoded" -d "client_id=$CLIENT_ID&username=$USERNAME&password=$PASSWORD&client_secret=$SECRET&grant_type=password" -X POST "$URL"`
if [ $? -ne 0 ]
then
   echo "Unable to send token request"
   exit 1
fi
TOKEN=`echo $RSP | jq '.access_token' | cut -f 2 -d '"'`
TOKEN_TYPE=`echo $RSP | jq '.token_type' | cut -f 2 -d '"'`

if [ -z "$TOKEN" ]
then
   echo "Unable to retrieve token.  Incorrect username/password?"
   echo ""
   echo "$RSP"
   exit 1
fi

# Now that we have a token, we can push the settings up to the VINO system
TOKENHDR="Bearer $TOKEN"

pushd $SETTINGS_DIR > /dev/null
DEFAULT_FILES=( $(ls *.default.json) )
OVERRIDE_FILES=( $(ls -I "*.default.json") )
FILES=( "${DEFAULT_FILES[@]}" "${OVERRIDE_FILES[@]}" )
for fileName in "${FILES[@]}"
do
   echo
   while true; do
      yn=y
      if [ "$ADD_ALL" = false ] ; then
         read -p "Add $fileName? (y/n) " yn
      fi
      case $yn in
         [Yy]* )
            echo "Loading settings from file: $SETTINGS_DIR/$fileName"
            IS_DEFAULT=`echo $fileName | grep -v '.default.json$'`
            if [ -z "$IS_DEFAULT" ]
            then
               RET=`curl -s -o /dev/null -w '%{http_code}' -X POST -H "Content-Type: application/json" -H "Authorization: $TOKENHDR" -d @${fileName} http://${VINO_HOST}/rest/settings/defaults`
            else
               RET=`curl -s -o /dev/null -w '%{http_code}' -X POST -H "Content-Type: application/json" -H "Authorization: $TOKENHDR" -d @${fileName} http://${VINO_HOST}/rest/settings/group`
            fi
            echo "Response code = $RET"
            # returns the current settings
            echo $RET > /tmp/returned.json
            break;;
         [Nn]* )
            echo "$fileName skipped..."
            break;;
         * )
            echo "Please answer 'y' or 'n'.";;
      esac
   done
done
popd >/dev/null

exit $?
