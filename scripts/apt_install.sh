#!/bin/sh

set -ex

export DEBIAN_FRONTEND=noninteractive

apt-get update --fix-missing
apt-get upgrade -y

apt-get install -y --no-install-recommends \
  binutils \
  ca-certificates \
  clang \
  cmake \
  curl \
  git \
  lsb-release \
  make \
  ninja-build \
  patch \
  pkg-config \
  python3 \
  rsync \
  sudo \
  unzip \
  xz-utils

