#!/bin/bash

CACHE_DIR=$(cd $1 && pwd)
DEPOT_TOOLS_DIR=$(cd $2 && pwd)
WEBRTC_COMMIT=$3
CONFIG_DIR=$(cd $4 && pwd)
GCLIENT_CONFIG=$CONFIG_DIR/GCLIENT
TARGET=`cat ${GCLIENT_CONFIG}`

mkdir -p $CACHE_DIR
cd $CACHE_DIR
if [ -f $CACHE_DIR/.gclient ]; then
  echo "Syncing webrtc ...";
  cd $CACHE_DIR/src;
  git reset --hard;
  git clean -xdf;
  cd third_party;
  git reset --hard;
  git clean -xdf;
else
  echo "Getting WEBRTC ...";
  rm -f $DEPOT_TOOLS_DIR/metrics.cfg;
  rm -rf $CACHE_DIR/src;
  fetch --nohooks $TARGET;
fi
cd $CACHE_DIR/src
git fetch
git checkout -f $WEBRTC_COMMIT
yes | gclient sync
