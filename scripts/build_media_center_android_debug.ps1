
param(
  [string]$EntryPoint = "lib/main.dart"
)

$ErrorActionPreference = "Stop"

function Invoke-Checked {
  param(
    [Parameter(Mandatory = $true)]
    [string]$FilePath,

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Arguments
  )

  Write-Host ">> $FilePath $($Arguments -join ' ')" -ForegroundColor DarkCyan
  & $FilePath @Arguments

  if ($LASTEXITCODE -ne 0) {
    throw "Command failed with exit code $($LASTEXITCODE): $FilePath $($Arguments -join ' ')"
  }
}

Write-Host "Building PalWakf Media Center Android debug APK..." -ForegroundColor Cyan

Write-Host "Checking Android MainActivity duplicate sources..." -ForegroundColor DarkCyan
if (Test-Path ".\scripts\cleanup_android_duplicate_mainactivity.ps1") {
  & ".\scripts\cleanup_android_duplicate_mainactivity.ps1"
}

Write-Host "Stopping existing Gradle daemons if Java is available..." -ForegroundColor DarkCyan
$javaAvailable = $false
if ($env:JAVA_HOME) {
  $javaAvailable = $true
} elseif (Get-Command java -ErrorAction SilentlyContinue) {
  $javaAvailable = $true
}

if ($javaAvailable -and (Test-Path ".\\android\\gradlew.bat")) {
  & ".\\android\\gradlew.bat" --stop | Out-Host
} else {
  Write-Host "Skipping Gradle daemon stop because JAVA_HOME/java is not available in this shell." -ForegroundColor Yellow
}


Invoke-Checked flutter pub get
Invoke-Checked flutter analyze
Invoke-Checked flutter test test/core/contracts/cms_payload_contracts_test.dart

Invoke-Checked flutter build apk `
  --debug `
  --target $EntryPoint `
  --dart-define=PWF_ALLOW_LEGACY_PUBLIC_MEDIA_BASE_FALLBACK=false

$apkPath = "build\app\outputs\flutter-apk\app-debug.apk"

if (!(Test-Path $apkPath)) {
  throw "APK output was not found: $apkPath"
}

Write-Host "Debug APK build completed." -ForegroundColor Green
Write-Host "Output: $apkPath"
