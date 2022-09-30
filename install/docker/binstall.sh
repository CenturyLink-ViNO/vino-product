#!/bin/bash

productName="ViNO_Docker_Distribution"

function main()
{
   osPreconditions
   startLogging
   preConditions
   install
}

function osPreconditions()
{
   if [ ! -e /usr/bin/yum ]; then
      logLine "yum not installed, cannot continue"
      logLine "If you are on a non-RedHat based OS, use '--noexec --keep --target <where to extract>' as arguments to the script to extract the
      contents and manually set up your environment."
      exit 1
   fi
   if [ ! -e /usr/bin/tee ]; then
      /usr/bin/yum -y install coreutils
      if [ $? -ne 0 ]; then
         if [ ! -e /usr/bin/tee ]; then
            logLine "tee not installed, cannot continue"
            exit 1
         fi
      fi
   fi
   if [ ! -e /usr/bin/find ]; then
      /usr/bin/yum -y install findutils
      if [ $? -ne 0 ]; then
         if [ ! -e /usr/bin/find ]; then
            logLine "find not installed, cannot continue"
            exit 1
         fi
      fi
   fi
   if [ ! -e /usr/bin/wget ]; then
      /usr/bin/yum -y install wget
      if [ $? -ne 0 ]; then
         if [ ! -e /usr/bin/wget ]; then
            logLine "wget not installed, cannot continue"
            exit 1
         fi
      fi
   fi
}

function startLogging()
{
   # now that we are sure we have 'tee' send our output to the screen and a log file
   /bin/mkdir -p /var/log/vino.install
   logFile=/var/log/vino.install/${productName}_product_Install.$$.log
   exec > >(/usr/bin/tee ${logFile}) 2>&1
   logLine "$0 $* Logging to ${logFile}"
   /bin/date
}

function preConditions()
{
   # Do Nothing
   echo "" > /dev/null
}

function install()
{
   logLine "Installing_ViNO_Software."
   exec 3>&1
   dockerLog=$(wget -qO- https://get.docker.com/ | sh)
   ret=$?

   if [ $ret -ne 0 ]; then
      logLine "dockerLog - Initial installation failed, repair the issues above and run the installer again."
   else
      set -e
      usermod -aG docker $(whoami)
      systemctl enable docker.service
      systemctl start docker.service
      yum install -y epel-release
      yum install -y python3
      yum install -y jq
      yum upgrade -y python*
      yum install -y gcc
      yum install -y python-devel
      pip3 install --upgrade pip
      pip3 install yq
      pip3 install jsonschema
      pip3 install requests --ignore-installed
      pip3 install docker-compose
      mkdir -p /opt/vino/vino-docker
      cp docker-compose.yml getip.sh /opt/vino/vino-docker
      cp vinoctl.sh vinoInit.sh vinoRestart.sh vinoStart.sh vinoStartFast.sh vinoStop.sh vinoUninstall.sh vinoNewServiceManager.sh utils.sh initialize.sh /opt/vino/vino-docker
      cp vino-boot.service /usr/lib/systemd/system
      systemctl enable vino-boot.service
      chmod +x /opt/vino/vino-docker/*.sh
      mkdir -p /opt/vino/filebeat
      cp filebeat.yml /opt/vino/filebeat
      mkdir -p /opt/vino/vino-docker/settingsServer
      cp -r settingsServer/* /opt/vino/vino-docker/settingsServer
      chmod +x /opt/vino/vino-docker/settingsServer/*.sh
      mkdir -p /opt/vino/vino-docker/uninstall
      cp uninstall/* /opt/vino/vino-docker/uninstall
      chmod +x /opt/vino/vino-docker/uninstall/*.sh
      for i in *.tar; do
         [ -f "$i" ] || break
         docker load -q -i "$i"
      done
      set +e
      logLine "The ViNO docker images have been loaded. Please see the Virtual Network Orchestrator (ViNO) User Guide for detailed instructions on how to setup and run ViNO."
   fi

   /bin/date
   logLine "log available in ${logFile}"
   exit $ret
}

function postInstall()
{
   cleanEmptyLogs
   logLine "installation complete."
}

function cleanEmptyLogs()
{
   /usr/bin/find /var/log/vino.install -type f -size 0 -exec /bin/rm -f {} \;
}

function logLine()
{
   /bin/echo ""
   /bin/echo "ViNO ---> $1"
   /bin/echo ""
}

main $*
