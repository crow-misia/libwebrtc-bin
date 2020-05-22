#!/bin/bash

# swapファイルの削除
sudo swapoff -a
sudo rm -f /swapfile

# aptのキャッシュの削除
sudo apt clean

# Cache 済み Docker Image の削除
docker rmi $(docker images -q -a)

# Android SDK の削除
sudo rm -rf ${ANDROID_HOME}

# JVM の削除
sudo rm -rf ${JAVA_HOME_12_X64}
sudo rm -rf ${JAVA_HOME_11_X64}
sudo rm -rf ${JAVA_HOME_8_X64}
sudo rm -rf ${JAVA_HOME_7_X64} 

