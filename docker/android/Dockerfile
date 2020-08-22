# syntax = docker/dockerfile:experimental
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

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
    libncurses5 \
    lsb-release \
    python \
    pkg-config \
    rsync \
    sudo \
    openjdk-11-jdk-headless \
    time \
    unzip

RUN update-java-alternatives -s java-1.11.0-openjdk-amd64

COPY config/android/ /root/config/android/
COPY build/ /root/build/
COPY Makefile VERSION LICENSE /root/
COPY scripts/ /root/scripts/

RUN \
  --mount=type=cache,id=libwebrtc,target=/var/cache/apt \
  --mount=type=cache,id=libwebrtc,target=/var/lib/apt \
  cd /root \
  && make USE_CCACHE=0 -C build android.fetch

