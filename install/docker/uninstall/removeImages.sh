#!/bin/bash

docker image ls | awk '{ print $1, $3 }' | while read -r name id; do
  if  [[ $name == vino* ]] || [[ $name == abacus* ]] ;
  then
      printf "removing image %s with ID: %s\n" "$name" "$id"
      docker image rm -f ${id}
  fi
done
