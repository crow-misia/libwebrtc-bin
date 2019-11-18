# Copyright 2019, Shiguredo Inc, melpon and enm10k
# original: https://github.com/shiguredo/shiguredo-webrtc-windows/blob/master/gabuild.ps1

$REPO_DIR = Resolve-Path "."

Push-Location $REPO_DIR\release
  tar -Jcf $REPO_DIR\release\libwebrtc-win-x64.tar.xz include lib NOTICE VERSION
  Remove-Item lib -Recurse -Force
  Remove-Item include -Recurse -Force
  Remove-Item NOTICE -Force
  Remove-Item VERSION -Force
Pop-Location
