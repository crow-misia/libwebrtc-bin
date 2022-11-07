# syntax = docker/dockerfile:experimental
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

RUN \
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
    cmake

COPY config/linux-arm/ /root/config/linux-arm/
COPY build/ /root/build/
COPY Makefile VERSION LICENSE /root/
COPY scripts/ /root/scripts/

RUN \
  cd /root \
  && make -C build linux-arm.fetch

