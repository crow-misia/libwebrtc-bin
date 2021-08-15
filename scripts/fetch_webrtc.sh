#!/bin/bash

WEBRTC_DIR=$(cd $1 && pwd)
DEPOT_TOOLS_DIR=$(cd $2 && pwd)
WEBRTC_COMMIT=$3
CONFIG_DIR=$(cd $4 && pwd)
FETCH_TARGET=`cat ${CONFIG_DIR}/webrtc_fetch`

mkdir -p $WEBRTC_DIR
cd $WEBRTC_DIR
if [ -f $WEBRTC_DIR/.gclient ]; then
  echo "Syncing webrtc ...";
  cd $WEBRTC_DIR/src;
  git reset --hard;
  git clean -xdf;
  if [ -d $WEBRTC_DIR/src/third_party ]; then
    cd $WEBRTC_DIR/src/third_party;
    git reset --hard;
    git clean -xdf;
  fi
  if [ -d $WEBRTC_DIR/src/build ]; then
    cd $WEBRTC_DIR/src/build;
    git reset --hard;
    git clean -xdf;
  fi
else
  echo "Getting WEBRTC ...";
  rm -f $DEPOT_TOOLS_DIR/metrics.cfg;
  rm -rf $WEBRTC_DIR/src;
  fetch --nohooks $FETCH_TARGET;
fi
cd $WEBRTC_DIR/src
git fetch
git checkout -f $WEBRTC_COMMIT
yes | gclient sync -D
