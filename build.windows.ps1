# Copyright 2019, Shiguredo Inc, melpon and enm10k
# Copyright 2019, Zenichi Amano
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

$7Z_DIR = Join-Path (Resolve-Path ".").Path "7z"

if (!(Test-Path vswhere.exe)) {
  Invoke-WebRequest -Uri "https://github.com/microsoft/vswhere/releases/download/2.8.4/vswhere.exe" -OutFile vswhere.exe
}

if (!(Test-Path $7Z_DIR\7z.exe)) {
  Invoke-WebRequest -Uri "https://jaist.dl.sourceforge.net/project/sevenzip/7-Zip/19.00/7z1900-x64.exe" -OutFile 7z-x64.exe
  ./7z-x64.exe /S /D="""$7Z_DIR"""
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
  foreach ($arch in @("x64", "x86")) {
    $debuggerpath = join-path $path "Common7\IDE\Extensions\TestPlatform\Extensions\Cpp\$arch\dbghelp.dll"
    if (!(Test-Path "C:\Program Files (x86)\Windows Kits\10\Debuggers\$arch")) {
      New-Item "C:\Program Files (x86)\Windows Kits\10\Debuggers\$arch" -ItemType Directory -Force
      Copy-Item $debuggerpath "C:\Program Files (x86)\Windows Kits\10\Debuggers\$arch\dbghelp.dll"
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

# depot_tools
if (Test-Path $DEPOT_TOOLS_DIR) {
  Push-Location $DEPOT_TOOLS_DIR
    git checkout .
    git clean -df .
    git pull .
  Pop-Location
} else {
  git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
}

$Env:PATH = "$DEPOT_TOOLS_DIR;$Env:PATH"
# Choco へのパスを削除
$Env:PATH = $Env:Path.Replace("C:\ProgramData\Chocolatey\bin;", "");

# WebRTC のソース取得
New-Item $WEBRTC_DIR -ItemType Directory -Force
Push-Location $WEBRTC_DIR
if (Test-Path .gclient) {
  Push-Location src
  git checkout .
  git clean -df
  Pop-Location

  Push-Location src\build
  git checkout .
  git clean -xdf
  Pop-Location

  Push-Location src\third_party
  git checkout .
  git clean -df
  Pop-Location
} else {
  if (Test-Path $DEPOT_TOOLS_DIR\metrics.cfg) {
    Remove-Item $DEPOT_TOOLS_DIR\metrics.cfg -Force
  }
  if (Test-Path src) {
    Remove-Item src -Recurse -Force
  }
  fetch --nohooks webrtc
}

if (!(Test-Path $BUILD_DIR)) {
  mkdir $BUILD_DIR
}

gclient sync --with_branch_heads -r $WEBRTC_COMMIT
git apply $PATCH_DIR\4k.patch
Pop-Location

Get-PSDrive

Push-Location $WEBRTC_DIR\src
  # WebRTC Debugビルド x64
  gn gen $BUILD_DIR\debug_x64 --args='is_debug=true treat_warnings_as_errors=false rtc_use_h264=false rtc_include_tests=false rtc_build_examples=false is_component_build=false use_rtti=true use_custom_libcxx=false'
  ninja -C "$BUILD_DIR\debug_x64"

  # WebRTC Releaseビルド x64
  gn gen $BUILD_DIR\release_x64 --args='is_debug=false treat_warnings_as_errors=false rtc_use_h264=false rtc_include_tests=false rtc_build_examples=false is_component_build=false use_rtti=true strip_debug_info=true symbol_level=0 use_custom_libcxx=false'
  ninja -C "$BUILD_DIR\release_x64"

  # WebRTC Debugビルド x86
  gn gen $BUILD_DIR\debug_x86 --args='target_os=\"win\" target_cpu=\"x86\" is_debug=true treat_warnings_as_errors=false rtc_use_h264=false rtc_include_tests=false rtc_build_examples=false is_component_build=false use_rtti=true use_custom_libcxx=false'
  ninja -C "$BUILD_DIR\debug_x86"

  # WebRTC Releaseビルド x86
  gn gen $BUILD_DIR\release_x86 --args='target_os=\"win\" target_cpu=\"x86\" is_debug=false treat_warnings_as_errors=false rtc_use_h264=false rtc_include_tests=false rtc_build_examples=false is_component_build=false use_rtti=true strip_debug_info=true symbol_level=0 use_custom_libcxx=false'
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
$WEBRTC_VERSION | Out-File $BUILD_DIR\package\webrtc\VERSION

# WebRTC のヘッダーだけをパッケージングする
if (Test-Path $BUILD_DIR\package) {
  Remove-Item -Force -Recurse -Path $BUILD_DIR\package
}
New-Item $BUILD_DIR\package\webrtc\include -ItemType Directory -Force
robocopy "$WEBRTC_DIR\src" "$BUILD_DIR\package\webrtc\include" *.h *.hpp /S /NP /NS /NC /NFL /NDL

# ライブラリディレクトリ作成
New-Item $BUILD_DIR\package\webrtc\debug -ItemType Directory -Force
New-Item $BUILD_DIR\package\webrtc\release -ItemType Directory -Force


# ライセンス生成 (x64)
Push-Location $WEBRTC_DIR\src
  vpython tools_webrtc\libs\generate_licenses.py --target :webrtc "$BUILD_DIR\" "$BUILD_DIR\debug_x64" "$BUILD_DIR\release_x64"
Pop-Location
Copy-Item "$BUILD_DIR\LICENSE.md" "$BUILD_DIR\package\webrtc\NOTICE"

# x64用ライブラリコピー
Copy-Item $BUILD_DIR\debug_x64\obj\webrtc.lib $BUILD_DIR\package\webrtc\debug\
Copy-Item $BUILD_DIR\release_x64\obj\webrtc.lib $BUILD_DIR\package\webrtc\release\

# ファイルを圧縮する
if (!(Test-Path $PACKAGE_DIR)) {
  New-Item $PACKAGE_DIR -ItemType Directory -Force
}
if (Test-Path $PACKAGE_DIR\libwebrtc-win-x64.7z) {
  Remove-Item -Force -Path $PACKAGE_DIR\libwebrtc-win-x64.7z
}
Push-Location $BUILD_DIR\package\webrtc
  cmd /s /c """$7Z_DIR\7z.exe""" a -bsp0 -t7z:r -ssc -ms+ $PACKAGE_DIR\libwebrtc-win-x64.7z *
Pop-Location


# ライセンス生成 (x86)
Push-Location $WEBRTC_DIR\src
  vpython tools_webrtc\libs\generate_licenses.py --target :webrtc "$BUILD_DIR\" "$BUILD_DIR\debug_x86" "$BUILD_DIR\release_x86"
Pop-Location
Copy-Item "$BUILD_DIR\LICENSE.md" "$BUILD_DIR\package\webrtc\NOTICE"

# x86用ファイル一式作成
Copy-Item $BUILD_DIR\debug_x86\obj\webrtc.lib $BUILD_DIR\package\webrtc\debug\
Copy-Item $BUILD_DIR\release_x86\obj\webrtc.lib $BUILD_DIR\package\webrtc\release\

# ファイルを圧縮する
if (!(Test-Path $PACKAGE_DIR)) {
  New-Item $PACKAGE_DIR -ItemType Directory -Force
}
if (Test-Path $PACKAGE_DIR\libwebrtc-win-x86.7z) {
  Remove-Item -Force -Path $PACKAGE_DIR\libwebrtc-win-x86.7z
}
Push-Location $BUILD_DIR\package\webrtc
  cmd /s /c """$7Z_DIR\7z.exe""" a -bsp0 -t7z:r -ssc -ms+ $PACKAGE_DIR\libwebrtc-win-x86.7z *
Pop-Location
