# Copyright 2019, Shiguredo Inc, melpon and enm10k
# Copyright 2019, Zenichi Amano
# original: https://github.com/shiguredo/shiguredo-webrtc-windows/blob/master/gabuild.ps1

$ErrorActionPreference = "Stop"

$PSVersionTable

# VERSIONファイル読み込み
$lines = get-content VERSION
foreach ($line in $lines) {
  # WEBRTC_COMMITの行のみ取得する
  if ($line -match "^WEBRTC_") {
    $name, $value = $line.split("=",2)
    Invoke-Expression "`$$name='$value'"
  }
}

# vsdevcmd.bat の設定を入れる
# https://github.com/microsoft/vswhere/wiki/Find-VC
$path = vswhere.exe -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
if ($path) {
  $batpath = join-path $path 'Common7\Tools\vsdevcmd.bat'
  if (test-path $batpath) {
    cmd /s /c """$batpath"" $args && set" | Where-Object { $_ -match '(\w+)=(.*)' } | ForEach-Object {
      $null = new-item -force -path "Env:\$($Matches[1])" -value $Matches[2]
    }
  }
}

$REPO_DIR = Resolve-Path "."
$WEBRTC_DIR = "C:\webrtc"
$BUILD_DIR = "C:\webrtc_build"
$DEPOT_TOOLS_DIR = Join-Path $REPO_DIR.Path "depot_tools"
$PATCH_DIR = Join-Path $REPO_DIR.Path "patch"
$PACKAGE_DIR = Join-Path $REPO_DIR.Path "package"

# WebRTC ビルドに必要な環境変数の設定
$Env:GYP_MSVS_VERSION = "2019"
$Env:DEPOT_TOOLS_WIN_TOOLCHAIN = "0"
$Env:PYTHONIOENCODING = "utf-8"

if (Test-Path $DEPOT_TOOLS_DIR) {
  Remove-Item $DEPOT_TOOLS_DIR -Force -Recurse
}
if (Test-Path $WEBRTC_DIR) {
  Remove-Item $WEBRTC_DIR -Force -Recurse
}
if (Test-Path $BUILD_DIR) {
  Remove-Item $BUILD_DIR -Force -Recurse
}
if (Test-Path $PACKAGE_DIR) {
  Remove-Item $PACKAGE_DIR -Force -Recurse
}

# depot_tools
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git

$Env:PATH = "$DEPOT_TOOLS_DIR;$Env:PATH"
# Choco へのパスを削除
$Env:PATH = $Env:Path.Replace("C:\ProgramData\Chocolatey\bin;", "")

# Git設定
git config --global core.longpaths true
git config --global depot-tools.allowGlobalGitConfig true

# WebRTC のソース取得
New-Item $WEBRTC_DIR -ItemType Directory -Force
Push-Location $WEBRTC_DIR
  fetch --nohooks webrtc

  New-Item $BUILD_DIR -ItemType Directory -Force

  Push-Location $WEBRTC_DIR\src
    git checkout -f $WEBRTC_COMMIT
    gclient sync

    git apply --ignore-space-change --ignore-whitespace -p 2 $PATCH_DIR\4k.patch
    git apply --ignore-space-change --ignore-whitespace -p 2 $PATCH_DIR\add_licenses.patch
    git apply --ignore-space-change --ignore-whitespace $PATCH_DIR\windows_fix_abseil.patch
    git apply --ignore-space-change --ignore-whitespace $PATCH_DIR\windows_fix_optional.patch
  Pop-Location
Pop-Location

Get-PSDrive

Push-Location $WEBRTC_DIR\src
  # WebRTC Debugビルド x64
  gn gen $BUILD_DIR\debug_x64 --args='is_debug=true treat_warnings_as_errors=false rtc_use_h264=false rtc_include_tests=false rtc_build_tools=false rtc_build_examples=false rtc_use_perfetto=false is_component_build=false use_rtti=true use_custom_libcxx=false'
  ninja -C "$BUILD_DIR\debug_x64"

  # WebRTC Releaseビルド x64
  gn gen $BUILD_DIR\release_x64 --args='is_debug=false treat_warnings_as_errors=false rtc_use_h264=false rtc_include_tests=false rtc_build_tools=false rtc_build_examples=false rtc_use_perfetto=false is_component_build=false use_rtti=true strip_debug_info=true symbol_level=0 use_custom_libcxx=false'
  ninja -C "$BUILD_DIR\release_x64"

  # WebRTC Debugビルド x86
  gn gen $BUILD_DIR\debug_x86 --args='target_os=\"win\" target_cpu=\"x86\" is_debug=true treat_warnings_as_errors=false rtc_use_h264=false rtc_include_tests=false rtc_build_tools=false rtc_build_examples=false rtc_use_perfetto=false is_component_build=false use_rtti=true use_custom_libcxx=false'
  ninja -C "$BUILD_DIR\debug_x86"

  # WebRTC Releaseビルド x86
  gn gen $BUILD_DIR\release_x86 --args='target_os=\"win\" target_cpu=\"x86\" is_debug=false treat_warnings_as_errors=false rtc_use_h264=false rtc_include_tests=false rtc_build_tools=false rtc_build_examples=false rtc_use_perfetto=false is_component_build=false use_rtti=true strip_debug_info=true symbol_level=0 use_custom_libcxx=false'
  ninja -C "$BUILD_DIR\release_x86"
Pop-Location

foreach ($build in @("debug_x64", "release_x64", "debug_x86", "release_x86")) {
  ninja -C "$BUILD_DIR\$build" audio_device_module_from_input_and_output

  # このままだと webrtc.lib に含まれないファイルがあるので、いくつか追加する
  Push-Location $BUILD_DIR\$build\obj
    lib.exe `
      /out:$BUILD_DIR\$build\webrtc.lib webrtc.lib `
      api\task_queue\default_task_queue_factory\default_task_queue_factory_win.obj `
      rtc_base\rtc_task_queue_win\task_queue_win.obj `
      modules\audio_device\audio_device_module_from_input_and_output\audio_device_factory.obj `
      modules\audio_device\audio_device_module_from_input_and_output\audio_device_module_win.obj `
      modules\audio_device\audio_device_module_from_input_and_output\core_audio_base_win.obj `
      modules\audio_device\audio_device_module_from_input_and_output\core_audio_input_win.obj `
      modules\audio_device\audio_device_module_from_input_and_output\core_audio_output_win.obj `
      modules\audio_device\windows_core_audio_utility\core_audio_utility_win.obj `
      modules\audio_device\audio_device_name\audio_device_name.obj
  Pop-Location
  Move-Item $BUILD_DIR\$build\webrtc.lib $BUILD_DIR\$build\obj\webrtc.lib -Force
}

# バージョンファイルコピー
New-Item $BUILD_DIR\package\webrtc -ItemType Directory -Force
$WEBRTC_VERSION | Out-File $BUILD_DIR\package\webrtc\VERSION

# WebRTC のヘッダーだけをパッケージングする
New-Item $BUILD_DIR\package\webrtc\include -ItemType Directory -Force
robocopy "$WEBRTC_DIR\src" "$BUILD_DIR\package\webrtc\include" *.h *.hpp /S /NP /NS /NC /NFL /NDL

# ライブラリディレクトリ作成
New-Item $BUILD_DIR\package\webrtc\debug -ItemType Directory -Force
New-Item $BUILD_DIR\package\webrtc\release -ItemType Directory -Force


# ライセンス生成 (x64)
Push-Location $WEBRTC_DIR\src
  vpython3 tools_webrtc\libs\generate_licenses.py --target :webrtc "$BUILD_DIR\" "$BUILD_DIR\debug_x64" "$BUILD_DIR\release_x64"
Pop-Location
Copy-Item "$BUILD_DIR\LICENSE.md" "$BUILD_DIR\package\webrtc\NOTICE"

# x64用ライブラリコピー
Copy-Item $BUILD_DIR\debug_x64\obj\webrtc.lib $BUILD_DIR\package\webrtc\debug\
Copy-Item $BUILD_DIR\release_x64\obj\webrtc.lib $BUILD_DIR\package\webrtc\release\

# ファイルを圧縮する
New-Item $PACKAGE_DIR -ItemType Directory -Force
Push-Location $BUILD_DIR\package\webrtc
  cmd /s /c "C:\ProgramData\Chocolatey\bin\7z.exe" a -bsp0 -t7z:r -ssc -ms+ $PACKAGE_DIR\libwebrtc-win-x64.7z *
Pop-Location

# ライセンス生成 (x86)
Push-Location $WEBRTC_DIR\src
  vpython3 tools_webrtc\libs\generate_licenses.py --target :webrtc "$BUILD_DIR\" "$BUILD_DIR\debug_x86" "$BUILD_DIR\release_x86"
Pop-Location
Copy-Item "$BUILD_DIR\LICENSE.md" "$BUILD_DIR\package\webrtc\NOTICE"

# x86用ファイル一式作成
Copy-Item $BUILD_DIR\debug_x86\obj\webrtc.lib $BUILD_DIR\package\webrtc\debug\
Copy-Item $BUILD_DIR\release_x86\obj\webrtc.lib $BUILD_DIR\package\webrtc\release\

# ファイルを圧縮する
New-Item $PACKAGE_DIR -ItemType Directory -Force
Push-Location $BUILD_DIR\package\webrtc
  cmd /s /c "C:\ProgramData\Chocolatey\bin\7z.exe" a -bsp0 -t7z:r -ssc -ms+ $PACKAGE_DIR\libwebrtc-win-x86.7z *
Pop-Location
