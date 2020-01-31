#!/bin/bash

case "$1" in

  init)
    ./vinoInit.sh
  ;;
  start)
    ./vinoStart.sh
  ;;
  stop)
    ./vinoStop.sh
  ;;
  restart)
    ./vinoRestart.sh
  ;;
  uninstall)
    ./vinoUninstall.sh
  ;;
  loadsettings)
    cd settingsServer
    ./addAllSettings.sh
    cd ..
  ;;
*) echo
   echo "'$1' is not a valid parameter"
   echo "try one of: init, stop, start, restart, loadsettings, or uninstall"
   echo "init must be run once the first time to start vino properly."
   echo "After that the other commands can be used."
   ;;
esac

