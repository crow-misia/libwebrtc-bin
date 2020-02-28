#!/bin/bash

set -x

while IFS="=" read -r key value; do
    case "$key" in
      "WEBRTC_SEMANTIC_VERSION") VERSION="$value" ;;
    esac
  done < ./VERSION

AAR_URL=https://github.com/crow-misia/libwebrtc-bin/releases/download/m${VERSION}/libwebrtc-android.tar.xz

echo AAR_URL=${AAR_URL}

mkdir -p package
cd package

curl -L -O ${AAR_URL}
tar xf libwebrtc-android.tar.xz

mvn install:install-file \
    -Dfile=libwebrtc.aar \
    -Dpackaging=aar \
    -Dversion=${VERSION} \
    -DgroupId=com.github.crow-misia \
    -DartifactId=libwebrtc-bin

