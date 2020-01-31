#!/bin/bash

. ../utils.sh

getVinoName $1

STR=$(yq -r '.volumes | keys | .[]' ../docker-compose.yml)
#echo $STR
for i in $STR
do
   VOLUMENAMT=${VINONAME}_${i}
   echo removing ${VOLUMENAMT}...
   docker volume rm ${VOLUMENAMT}
done

