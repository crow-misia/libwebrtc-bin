#!/bin/bash

df -h

# Cache 済み Docker Image の削除
docker rmi $(docker images -q -a)

# Boost の削除
sudo rm -rf /usr/local/share/boost

# .Net Core の削除
sudo rm -rf /usr/share/dotnet

# Haskell の削除
sudo rm -rf /opt/ghc

df -h
