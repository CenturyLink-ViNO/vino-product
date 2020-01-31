#!/bin/bash

. utils.sh

getVinoName $1

./vinoStop.sh $VINONAME
./vinoStart.sh $VINONAME
