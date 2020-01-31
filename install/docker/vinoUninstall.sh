#!/bin/bash

. utils.sh

getVinoName $1

cd uninstall
./removeContainers.sh $VINONAME
./removeImages.sh
./removeVolumes.sh $VINONAME
cd ..
