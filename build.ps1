# Copyright 2019, Shiguredo Inc, melpon and enm10k
# original: https://github.com/shiguredo/shiguredo-webrtc-windows/blob/master/gabuild.ps1

# VERSIONファイル読み込み
$lines = get-content VERSION
foreach($line in $lines){
  # WEBRTC_COMMITの行のみ取得する
  if ($line -match "^WEBRTC_") {
    $name, $value = $line.split("=",2)
    Invoke-Expression "`$$name='$value'"
  }
}

if (!(Test-Path vswhere.exe)) {
  Invoke-WebRequest -Uri "https://github.com/microsoft/vswhere/releases/download/2.8.4/vswhere.exe" -OutFile vswhere.exe
}

# vsdevcmd.bat の設定を入れる
# https://github.com/microsoft/vswhere/wiki/Find-VC
$path = .\vswhere.exe -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
if ($path) {
  $batpath = join-path $path 'Common7\Tools\vsdevcmd.bat'
  if (test-path $batpath) {
    cmd /s /c """$batpath"" $args && set" | Where-Object { $_ -match '(\w+)=(.*)' } | ForEach-Object {
      $null = new-item -force -path "Env:\$($Matches[1])" -value $Matches[2]
    }
  }
  # dbghelp.dll が無いと怒られてしまうので所定の場所にコピーする (管理者権限で実行する必要がある)
  $debuggerpath = join-path $path 'Common7\IDE\Extensions\TestPlatform\Extensions\Cpp\x64\dbghelp.dll'
  if (!(Test-Path 'C:\Program Files (x86)\Windows Kits\10\Debuggers\x64')) {
    New-Item 'C:\Program Files (x86)\Windows Kits\10\Debuggers\x64' -ItemType Directory -Force
    Copy-Item $debuggerpath 'C:\Program Files (x86)\Windows Kits\10\Debuggers\x64\dbghelp.dll'
  }
}

$REPO_DIR = Resolve-Path "."
$WEBRTC_DIR = "C:\webrtc"

# WebRTC ビルドに必要な環境変数の設定
$Env:GYP_MSVS_VERSION = "2019"
$Env:DEPOT_TOOLS_WIN_TOOLCHAIN = "0"
$Env:PYTHONIOENCODING = "utf-8"

# depot_tools
if (Test-Path depot_tools) {
  Push-Location depot_tools
    git checkout .
    git clean -df .
    git pull .
  Pop-Location
} else {
  git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
}
$Env:PATH = "$REPO_DIR\depot_tools;$Env:PATH"
# Choco へのパスを削除
$Env:PATH = $Env:Path.Replace("C:\ProgramData\Chocolatey\bin;", "");

# WebRTC のソース取得
if (!(Test-Path $WEBRTC_DIR)) {
  mkdir $WEBRTC_DIR
}
Push-Location $WEBRTC_DIR
  fetch webrtc
Pop-Location

Get-PSDrive

Push-Location $WEBRTC_DIR\src
  git checkout -f $WEBRTC_COMMIT
  gclient sync

  # WebRTC ビルド
  gn gen ..\build_debug --args='is_debug=true treat_warnings_as_errors=false rtc_use_h264=false rtc_include_tests=false rtc_build_examples=false is_component_build=false use_rtti=true use_custom_libcxx=false'
  ninja -C "$WEBRTC_DIR\build_debug"

  gn gen ..\build_release --args='is_debug=false treat_warnings_as_errors=false rtc_use_h264=false rtc_include_tests=false rtc_build_examples=false is_component_build=false use_rtti=true strip_debug_info=true symbol_level=0 use_custom_libcxx=false'
  ninja -C "$WEBRTC_DIR\build_release"
Pop-Location

ninja -C "$WEBRTC_DIR\build_debug" audio_device_module_from_input_and_output
ninja -C "$WEBRTC_DIR\build_release" audio_device_module_from_input_and_output

# このままだと webrtc.lib に含まれないファイルがあるので、いくつか追加する
Push-Location $WEBRTC_DIR\build_debug\obj
  lib.exe `
    /out:$WEBRTC_DIR\build_debug\webrtc.lib webrtc.lib `
    modules\audio_device\audio_device_module_from_input_and_output\audio_device_factory.obj `
    modules\audio_device\audio_device_module_from_input_and_output\audio_device_module_win.obj `
    modules\audio_device\audio_device_module_from_input_and_output\core_audio_base_win.obj `
    modules\audio_device\audio_device_module_from_input_and_output\core_audio_input_win.obj `
    modules\audio_device\audio_device_module_from_input_and_output\core_audio_output_win.obj `
    modules\audio_device\windows_core_audio_utility\core_audio_utility_win.obj `
    modules\audio_device\audio_device_name\audio_device_name.obj
Pop-Location

Push-Location $WEBRTC_DIR\build_release\obj
  lib.exe `
    /out:$WEBRTC_DIR\build_release\webrtc.lib webrtc.lib `
    modules\audio_device\audio_device_module_from_input_and_output\audio_device_factory.obj `
    modules\audio_device\audio_device_module_from_input_and_output\audio_device_module_win.obj `
    modules\audio_device\audio_device_module_from_input_and_output\core_audio_base_win.obj `
    modules\audio_device\audio_device_module_from_input_and_output\core_audio_input_win.obj `
    modules\audio_device\audio_device_module_from_input_and_output\core_audio_output_win.obj `
    modules\audio_device\windows_core_audio_utility\core_audio_utility_win.obj `
    modules\audio_device\audio_device_name\audio_device_name.obj
Pop-Location

# WebRTC のヘッダーだけをパッケージングする
New-Item $REPO_DIR\release\include -ItemType Directory -Force
New-Item $REPO_DIR\release\debug -ItemType Directory -Force
New-Item $REPO_DIR\release\release -ItemType Directory -Force
robocopy "$WEBRTC_DIR\src" "$REPO_DIR\release\include" *.h
robocopy "$WEBRTC_DIR\src\api" "$REPO_DIR\release\include\api" *.h /S
robocopy "$WEBRTC_DIR\src\audio" "$REPO_DIR\release\include\audio" *.h /S
robocopy "$WEBRTC_DIR\src\base" "$REPO_DIR\release\include\base" *.h /S
robocopy "$WEBRTC_DIR\src\call" "$REPO_DIR\release\include\call" *.h /S
robocopy "$WEBRTC_DIR\src\common_audio" "$REPO_DIR\release\include\common_audio" *.h /S
robocopy "$WEBRTC_DIR\src\common_video" "$REPO_DIR\release\include\common_video" *.h /S
robocopy "$WEBRTC_DIR\src\logging" "$REPO_DIR\release\include\logging" *.h /S
robocopy "$WEBRTC_DIR\src\media" "$REPO_DIR\release\include\media" *.h /S
robocopy "$WEBRTC_DIR\src\modules" "$REPO_DIR\release\include\modules" *.h /S
robocopy "$WEBRTC_DIR\src\p2p" "$REPO_DIR\release\include\p2p" *.h /S
robocopy "$WEBRTC_DIR\src\pc" "$REPO_DIR\release\include\pc" *.h /S
robocopy "$WEBRTC_DIR\src\rtc_base" "$REPO_DIR\release\include\rtc_base" *.h /S
robocopy "$WEBRTC_DIR\src\rtc_tools" "$REPO_DIR\release\include\rtc_tools" *.h /S
robocopy "$WEBRTC_DIR\src\system_wrappers" "$REPO_DIR\release\include\system_wrappers" *.h /S
robocopy "$WEBRTC_DIR\src\video" "$REPO_DIR\release\include\video" *.h /S
robocopy "$WEBRTC_DIR\src\third_party\abseil-cpp\absl" "$REPO_DIR\release\include\absl" *.h /S
robocopy "$WEBRTC_DIR\src\third_party\boringssl\src\include\openssl" "$REPO_DIR\release\include\openssl" *.h /S
robocopy "$WEBRTC_DIR\src\third_party\jsoncpp\source\include\json" "$REPO_DIR\release\include\json" *.h /S
robocopy "$WEBRTC_DIR\src\third_party\libyuv\include\libyuv" "$REPO_DIR\release\include\libyuv" *.h /S
New-Item $REPO_DIR\release\include\third_party\libyuv\include -ItemType Directory -Force
Copy-Item $WEBRTC_DIR\src\third_party\libyuv\include\libyuv.h $REPO_DIR\release\include\libyuv.h
Move-Item $WEBRTC_DIR\build_debug\webrtc.lib $REPO_DIR\release\debug\webrtc.lib -Force
Move-Item $WEBRTC_DIR\build_debug\obj\third_party\boringssl\boringssl.lib $REPO_DIR\release\debug\boringssl.lib -Force
Move-Item $WEBRTC_DIR\build_release\webrtc.lib $REPO_DIR\release\release\webrtc.lib -Force
Move-Item $WEBRTC_DIR\build_release\obj\third_party\boringssl\boringssl.lib $REPO_DIR\release\release\boringssl.lib -Force
Copy-Item $REPO_DIR\NOTICE $REPO_DIR\release\NOTICE
$WEBRTC_VERSION | Out-File $REPO_DIR\release\VERSION

