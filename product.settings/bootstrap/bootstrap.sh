#!/bin/bash

[[ $_ == $0 ]] && echo "Script should be sourced, not run" && exit 1

bootstrapDir="$(cd "$(dirname "$BASH_SOURCE")"; pwd)"

productRootDir="$(cd "$(dirname "${bootstrapDir}/../../../.. ")"; pwd)"

if [ ! -d ${productRootDir}/tools/dev-env ]; then
   mkdir -p ${productRootDir}/tools/dev-env
fi

if [ ! -e ${productRootDir}/tools/dev-env/public/ant ]; then
   branch="$(xmllint --xpath '/repositories/shared/common/@ref' ${bootstrapDir}/../repos.properties.xml | sed 's/ref=//g;s/\"//g' 2>&1)"
   if [ $? -ne 0 ]; then
      branch="master"
   fi
   if [ -n "${GIT_OVER_HTTPS}" ]; then
      git clone -b $branch https://github.com/CenturyLink-ViNO/dev-env-public.git ${productRootDir}/tools/dev-env/public
   else
      git clone -b $branch git@github.com:CenturyLink-ViNO/dev-env-public.git ${productRootDir}/tools/dev-env/public
   fi
   if [ $? -ne 0 ]; then
      exit $?
   fi
fi

export ANT_TOOLS_HOME=${productRootDir}/tools/dev-env/public/ant/

if [ ! -f ${productRootDir}/treeTop.txt ]; then
   touch ${productRootDir}/treeTop.txt
fi

if [ ! -L ${productRootDir}/build.xml ]; then
   ln -s ${bootstrapDir}/build.bootstrap.xml ${productRootDir}/build.xml
fi

if [ ! -L ${productRootDir}/gitup.sh ]; then
   ln -s ${productRootDir}/tools/dev-env/public/tools/gitup.sh ${productRootDir}/gitup.sh
fi

source ${bootstrapDir}/../product.environment.sh

cd ${productRootDir}

unset bootstrapDir
unset productRootDir
unset NEWPATH
