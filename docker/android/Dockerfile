# syntax = docker/dockerfile:experimental
FROM ubuntu:18.04

RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

RUN \
  --mount=type=cache,id=libwebrtc,target=/var/cache/apt \
  --mount=type=cache,id=libwebrtc,target=/var/lib/apt \
  apt update \
  && apt upgrade -y \
  && apt install -y \
    build-essential \
    curl \
    git \
    lsb-release \
    python \
    pkg-config \
    sudo \
    openjdk-8-jdk-headless \
    time

RUN update-java-alternatives -s java-1.8.0-openjdk-amd64

COPY config/android/ /root/config/android/
COPY build/ /root/build/
COPY Makefile VERSION LICENSE NOTICE /root/
COPY scripts/ /root/scripts/

RUN \
  --mount=type=cache,id=libwebrtc,target=/var/cache/apt \
  --mount=type=cache,id=libwebrtc,target=/var/lib/apt \
  --mount=type=cache,id=libwebrtc,target=/root/webrtc-cache \
  cd /root \
  && make USE_CCACHE=0 CACHE_DIR=/root/webrtc-cache -C build android.fetch
