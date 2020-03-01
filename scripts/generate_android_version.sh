#!/bin/bash

# usage: generate_version_android.sh SRC_DIR VERSION COMMIT

SRC_DIR=$(cd $1 && pwd)
WEBRTC_COMMIT=$2
WEBRTC_VERSION=$3

echo output version to $SRC_DIR/sdk/android/api/org/webrtc/WebRtcVersion.java
cat << EOF > $SRC_DIR/sdk/android/api/org/webrtc/WebRtcVersion.java
package org.webrtc;
public interface WebRtcVersion {
    public static final String COMMIT = "$WEBRTC_COMMIT";
    public static final String VERSION = "$WEBRTC_VERSION";
}
EOF

