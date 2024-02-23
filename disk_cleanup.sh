#!/bin/bash

df -h

# Cache 済み Docker Image の削除
docker rmi $(docker images -q -a)

# ghcup の削除
sudo rm -rf /usr/local/.ghcup

# Swift の削除
sudo rm -rf /usr/share/swift

# Boost の削除
sudo rm -rf /usr/local/share/boost

# .Net Core の削除
sudo rm -rf /usr/share/dotnet

# Haskell の削除
sudo rm -rf /opt/ghc

# Android SDK の削除
sudo rm -rf /usr/local/lib/android

# 未使用パッケージを削除
sudo apt-get remove aspnetcore-* dotnet-* firefox gcc libmysqlclient* mysql-*
sudo apt-get autoremove --purge

df -h
