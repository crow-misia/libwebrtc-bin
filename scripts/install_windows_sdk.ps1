# Windows SDK を公式 web インストーラ (winsdksetup.exe) でインストールする

$ErrorActionPreference = "Stop"

# ===== バージョン設定 =====
$SdkVersion   = "10.0.28000.2526"
# Windows SDK downloads ページ記載の、上記バージョンの Installer リンク
$InstallerUrl = "https://go.microsoft.com/fwlink/?linkid=2372508"
# ===========================================

# バージョンから「系」(例: 10.0.28000.) を導出して確認に使う
$SdkSeries = ($SdkVersion -replace '\d+$', '')

# 管理者権限チェック
$principal = New-Object Security.Principal.WindowsPrincipal(
    [Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "管理者として PowerShell を起動して再実行してください。"
}

# ダウンロード
$dir = Join-Path $env:TEMP "WindowsSdk"
New-Item -ItemType Directory -Path $dir -Force | Out-Null
$exe = Join-Path $dir "winsdksetup.exe"

Write-Host "Windows SDK $SdkVersion をダウンロード中: $InstallerUrl"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$old = $ProgressPreference
$ProgressPreference = "SilentlyContinue"
try { Invoke-WebRequest -Uri $InstallerUrl -OutFile $exe -UseBasicParsing }
finally { $ProgressPreference = $old }

# 署名検証
$sig = Get-AuthenticodeSignature $exe
if ($sig.Status -ne "Valid") { throw "インストーラの署名が不正です: $($sig.Status)" }
$subject = $sig.SignerCertificate.Subject
if ($subject -notmatch "Microsoft") {
    throw "署名者が Microsoft Corporation ではありません: $subject"
}
Write-Host "署名者: $subject"

# サイレントインストール
Write-Host "インストール中..."
$processArguments = @{
    FilePath     = $exe
    Wait         = $true
    PassThru     = $true
    ArgumentList = @("/quiet", "/norestart")
}
$p = Start-Process @processArguments
if ($p.ExitCode -notin 0, 3010) {
    throw "インストーラがエラー終了しました (ExitCode=$($p.ExitCode))"
}

# インストール確認 (10.0.28000. で始まるディレクトリがあるか)
$bin = "${env:ProgramFiles(x86)}\Windows Kits\10\bin"
$found = Get-ChildItem $bin -Directory -ErrorAction SilentlyContinue |
    Where-Object { $_.Name.StartsWith($SdkSeries) }
if (-not $found) { throw "$($SdkSeries)x の SDK が見つかりません。インストールに失敗した可能性があります。" }
$found | ForEach-Object { "インストール済み: " + $_.Name }
