#!/bin/bash

. ../utils.sh

getVinoName $1

STR=$(yq -r '.services | keys | .[]' ../docker-compose.yml)
#echo $STR
for i in $STR
do
   PREFIX=${VINONAME}_${i}
   CONTAINERID=$(getContainerIDFromContainerName $PREFIX)
   echo stopping $PREFIX with ID ${CONTAINERID}...
   docker stop ${CONTAINERID}
   echo removing $PREFIX with ID ${CONTAINERID}...
   docker rm ${CONTAINERID}
done
