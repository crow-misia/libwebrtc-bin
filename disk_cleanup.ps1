Get-PSDrive

# Cache 済み Docker Image の削除
docker rmi $(docker images -q -a)

# Android SDK の削除
Remove-Item -Recurse -Force $Env:ANDROID_HOME
Remove-Item -Recurse -Force $Env:ANDROID_NDK_HOME

# JVM の削除
Remove-Item -Recurse -Force $Env:JAVA_HOME_11_X64
Remove-Item -Recurse -Force $Env:JAVA_HOME_8_X64
Remove-Item -Recurse -Force $Env:JAVA_HOME_7_X64

Get-PSDrive
