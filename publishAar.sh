#!/bin/bash

set -x

while IFS="=" read -r key value; do
    case "$key" in
      "WEBRTC_SEMANTIC_VERSION") VERSION="$value" ;;
    esac
  done < ./VERSION

echo $VERSION

tar xf libwebrtc-android.tar.xz/libwebrtc-android.tar.xz

mvn deploy:deploy-file \
    -Dfile=libwebrtc.aar \
    -Dpackaging=aar \
    -Dversion=${VERSION} \
    -DgroupId=crow-misia \
    -DartifactId=webrtc \
    -DrepositoryId=github \
    -Durl=https://maven.pkg.github.com/crow-misia/libwebrtc-bin
