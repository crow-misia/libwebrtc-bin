# syntax = docker/dockerfile:experimental
FROM ubuntu:22.04

RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

COPY scripts/ /root/scripts/
RUN scripts/apt_install.sh && sudo apt-get install -y openjdk-11-jdk

COPY config/android/ /root/config/android/
COPY build/ /root/build/
COPY Makefile VERSION LICENSE /root/

RUN \
  cd /root \
  && make -C build android.fetch

