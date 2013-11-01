#!/bin/bash
#

export OBF_PROJECT_NAME=openjdk8-lambda

#
# Safe Environment
#
export LC_ALL=C
export LANG=C

#
# Prepare Drop DIR
#
if [ -z $OBF_DROP_DIR ]; then
  export OBF_DROP_DIR=`pwd`/OBF_DROP_DIR
  mkdir -p $OBF_DROP_DIR
fi

#
# Provide Main Variables to Scripts
#
if [ -z "$OBF_BUILD_PATH" ]; then
  export OBF_BUILD_PATH=`pwd`/obuildfactory/$OBF_PROJECT_NAME/linux
fi

if [ -z "$OBF_SOURCES_PATH" ]; then
  export OBF_SOURCES_PATH=`pwd`/sources/$OBF_PROJECT_NAME
  mkdir -p `pwd`/sources
fi

if [ -z "$OBF_WORKSPACE_PATH" ]; then
  export OBF_WORKSPACE_PATH=`pwd`
fi

if [ ! -d $OBF_SOURCES_PATH ]; then
  hg clone http://hg.openjdk.java.net/lambda/lambda $OBF_SOURCES_PATH
fi	
	
pushd $OBF_SOURCES_PATH >>/dev/null

# 
# Updating sources for Mercurial repo
#
sh ./get_source.sh

#
# Update sources to provided tag XUSE_TAG (if defined)
#
if [ ! -z "$XUSE_TAG" ]; then
  echo "using tag $XUSE_TAG"
  sh ./make/scripts/hgforest.sh update $XUSE_TAG
fi

#
# OBF_MILESTONE will contains build tag number and name, ie b56-lambda but without dash inside (suited for RPM packages)
# OBF_BUILD_NUMBER will contains build number, ie b56
# OBF_BUILD_DATE will contains build date, ie 20120908
#
# Build System concats OBF_MILESTONE, - and OBF_BUILD_DATE, ie b56-lambda-20120908
#
export OBF_MILESTONE=`hg tags | grep jdk8 | head -1 | cut -d ' ' -f 1 | sed 's/^-//'`
export OBF_BUILD_NUMBER=`hg tags | grep jdk8 | head -1 | sed "s/jdk8//" | cut -d ' ' -f 1 | sed 's/^-//'`
export OBF_BUILD_DATE=`date +%Y%m%d`


popd >>/dev/null

if [ "$XBUILD" = "true" ]; then
  $OBF_BUILD_PATH/build.sh

  if [ $? != 0 ]; then
    exit -1
  fi

fi

if [ "$XTEST" = "true" ]; then
  $OBF_BUILD_PATH/test.sh

  if [ $? != 0 ]; then
    exit -1
  fi

fi

if [ "$XPACKAGE"  = "true" ]; then
  $OBF_BUILD_PATH/package.sh

  if [ $? != 0 ]; then
    exit -1
  fi

fi

if [ "$XDEPLOY"  = "true" ]; then
  $OBF_BUILD_PATH/deploy.sh

  if [ $? != 0 ]; then
    exit -1
  fi

fi
