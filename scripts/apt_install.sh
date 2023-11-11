#!/bin/sh

set -ex

export DEBIAN_FRONTEND=noninteractive

apt-get remove -y gcc
apt-get autoremove

apt-get update --fix-missing
apt-get upgrade -y

apt-get install -y \
  binutils \
  cmake \
  curl \
  git \
  lsb-release \
  make \
  pkg-config \
  python3 \
  rsync \
  sudo \
  unzip \
  xz-utils

