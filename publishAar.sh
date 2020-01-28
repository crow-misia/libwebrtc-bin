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
    -DgroupId=com.github.crow-misia \
    -DartifactId=webrtc-android \
    -Dregistry=https://maven.pkg.github.com/crow-misia \
    -Dtoken=${GITHUB_TOKEN}
