#!/bin/bash

. utils.sh

UICONTAINER=$(getContainerIDFromImageName vino-proxy)
CORECONTAINER=$(getContainerIDFromImageName vino-core)

docker stop $UICONTAINER $CORECONTAINER

./vinoInit.sh
