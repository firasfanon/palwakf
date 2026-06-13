
param(
  [string]$ApkPath = "build\app\outputs\flutter-apk\app-debug.apk",
  [string]$PackageName = "com.example.waqf",
  [string]$DeviceSerial = "",
  [string]$EmulatorName = "",
  [switch]$SkipBuild,
  [switch]$ListOnly
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

function Resolve-Adb {
  $candidates = @()

  if ($env:ANDROID_HOME) {
    $candidates += Join-Path $env:ANDROID_HOME "platform-tools\adb.exe"
  }

  if ($env:ANDROID_SDK_ROOT) {
    $candidates += Join-Path $env:ANDROID_SDK_ROOT "platform-tools\adb.exe"
  }

  if ($env:LOCALAPPDATA) {
    $candidates += Join-Path $env:LOCALAPPDATA "Android\Sdk\platform-tools\adb.exe"
  }

  if ($env:USERPROFILE) {
    $candidates += Join-Path $env:USERPROFILE "AppData\Local\Android\Sdk\platform-tools\adb.exe"
  }

  $cmd = Get-Command adb -ErrorAction SilentlyContinue
  if ($cmd) {
    $candidates += $cmd.Source
  }

  foreach ($candidate in $candidates | Select-Object -Unique) {
    if ($candidate -and (Test-Path $candidate)) {
      Write-Host "Using adb: $candidate" -ForegroundColor DarkGreen
      return $candidate
    }
  }

  throw "adb.exe was not found. Install Android SDK Platform-Tools or set ANDROID_SDK_ROOT."
}

function Resolve-Emulator {
  $candidates = @()

  if ($env:ANDROID_HOME) {
    $candidates += Join-Path $env:ANDROID_HOME "emulator\emulator.exe"
  }

  if ($env:ANDROID_SDK_ROOT) {
    $candidates += Join-Path $env:ANDROID_SDK_ROOT "emulator\emulator.exe"
  }

  if ($env:LOCALAPPDATA) {
    $candidates += Join-Path $env:LOCALAPPDATA "Android\Sdk\emulator\emulator.exe"
  }

  if ($env:USERPROFILE) {
    $candidates += Join-Path $env:USERPROFILE "AppData\Local\Android\Sdk\emulator\emulator.exe"
  }

  $cmd = Get-Command emulator -ErrorAction SilentlyContinue
  if ($cmd) {
    $candidates += $cmd.Source
  }

  foreach ($candidate in $candidates | Select-Object -Unique) {
    if ($candidate -and (Test-Path $candidate)) {
      return $candidate
    }
  }

  return $null
}

function Get-AdbDevices {
  param([string]$AdbPath)

  $output = & $AdbPath devices
  $devices = @()

  foreach ($line in $output) {
    $trimmed = $line.Trim()
    if ($trimmed -eq "" -or $trimmed.StartsWith("List of devices")) {
      continue
    }

    $parts = $trimmed -split "\s+"
    if ($parts.Count -ge 2) {
      $devices += [PSCustomObject]@{
        Serial = $parts[0]
        State = $parts[1]
        Raw = $trimmed
      }
    }
  }

  return $devices
}

function Show-DeviceHelp {
  param(
    [string]$AdbPath,
    [string]$EmulatorPath
  )

  Write-Host ""
  Write-Host "No Android device/emulator is currently available to adb." -ForegroundColor Yellow
  Write-Host ""
  Write-Host "Option A — Start an emulator:" -ForegroundColor Yellow

  if ($EmulatorPath) {
    Write-Host "List available emulators:" -ForegroundColor Gray
    Write-Host "`"$EmulatorPath`" -list-avds"
    Write-Host ""
    Write-Host "Start one emulator:" -ForegroundColor Gray
    Write-Host ".\scripts\uat_media_center_android_runtime.ps1 -SkipBuild -EmulatorName <AVD_NAME>"
  } else {
    Write-Host "Open Android Studio > Device Manager > Start an emulator."
  }

  Write-Host ""
  Write-Host "Option B — Connect a physical Android phone:" -ForegroundColor Yellow
  Write-Host "1. Enable Developer options."
  Write-Host "2. Enable USB debugging."
  Write-Host "3. Connect USB cable."
  Write-Host "4. Accept the RSA debugging prompt on the phone."
  Write-Host "5. Run:"
  Write-Host "`"$AdbPath`" devices"
  Write-Host ""
  Write-Host "Then rerun:" -ForegroundColor Yellow
  Write-Host ".\scripts\uat_media_center_android_runtime.ps1 -SkipBuild"
}

function Wait-ForDevice {
  param(
    [string]$AdbPath,
    [int]$TimeoutSeconds = 120
  )

  $deadline = (Get-Date).AddSeconds($TimeoutSeconds)

  while ((Get-Date) -lt $deadline) {
    $devices = Get-AdbDevices -AdbPath $AdbPath
    $ready = $devices | Where-Object { $_.State -eq "device" }

    if ($ready.Count -gt 0) {
      return $ready
    }

    Start-Sleep -Seconds 3
  }

  return @()
}

function Invoke-AdbChecked {
  param(
    [Parameter(Mandatory = $true)]
    [string]$AdbPath,

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Arguments
  )

  if ($DeviceSerial.Trim().Length -gt 0) {
    Invoke-Checked $AdbPath -s $DeviceSerial @Arguments
  } else {
    Invoke-Checked $AdbPath @Arguments
  }
}

Write-Host "PalWakf Media Center Android Runtime UAT" -ForegroundColor Cyan
Write-Host "Package: $PackageName" -ForegroundColor Gray

if (!$SkipBuild) {
  Write-Host "Running debug build before UAT..." -ForegroundColor DarkCyan
  Invoke-Checked ".\scripts\build_media_center_android_debug.ps1"
}

if (!(Test-Path $ApkPath)) {
  throw "APK not found: $ApkPath"
}

$adb = Resolve-Adb
$emulator = Resolve-Emulator

Write-Host "Checking connected Android devices..." -ForegroundColor DarkCyan
& $adb devices | Out-Host

if ($ListOnly) {
  if ($emulator) {
    Write-Host ""
    Write-Host "Available emulators:" -ForegroundColor Yellow
    & $emulator -list-avds | Out-Host
  }
  exit 0
}

if ($EmulatorName.Trim().Length -gt 0) {
  if (!$emulator) {
    throw "emulator.exe was not found. Open Android Studio Device Manager or install Android Emulator."
  }

  Write-Host "Starting emulator: $EmulatorName" -ForegroundColor DarkCyan
  Start-Process -FilePath $emulator -ArgumentList @("-avd", $EmulatorName)
  Write-Host "Waiting for emulator/device..." -ForegroundColor DarkCyan
  $readyDevices = Wait-ForDevice -AdbPath $adb -TimeoutSeconds 180
} else {
  $devices = Get-AdbDevices -AdbPath $adb
  $readyDevices = $devices | Where-Object { $_.State -eq "device" }
}

if ($readyDevices.Count -eq 0) {
  Show-DeviceHelp -AdbPath $adb -EmulatorPath $emulator
  throw "No ready Android device/emulator found. Device availability UAT gate is blocked."
}

if ($DeviceSerial.Trim().Length -eq 0 -and $readyDevices.Count -gt 1) {
  Write-Host ""
  Write-Host "Multiple Android devices are ready:" -ForegroundColor Yellow
  foreach ($device in $readyDevices) {
    Write-Host "- $($device.Serial)"
  }
  Write-Host ""
  throw "Multiple devices found. Rerun with -DeviceSerial <serial>."
}

Write-Host "Installing APK..." -ForegroundColor DarkCyan
Invoke-AdbChecked $adb install -r $ApkPath

Write-Host "Launching app..." -ForegroundColor DarkCyan
Invoke-AdbChecked $adb shell monkey -p $PackageName -c android.intent.category.LAUNCHER 1

Write-Host ""
Write-Host "Manual UAT routes/screens to validate:" -ForegroundColor Yellow
Write-Host "1. /app/media — mobile operational home"
Write-Host "2. /app/media-center — media browsing"
Write-Host "3. /app/media-center/publish — quick publish"
Write-Host "4. /app/media-center/drafts — local drafts"
Write-Host ""
Write-Host "Manual UAT workflow:" -ForegroundColor Yellow
Write-Host "1. Launch app."
Write-Host "2. Confirm app renders without crash."
Write-Host "3. Navigate to Media Center mobile entry."
Write-Host "4. Create a local draft."
Write-Host "5. Open local drafts."
Write-Host "6. Resume editing the draft."
Write-Host "7. When signed in, test official submit/publish path according to role."
Write-Host ""
Write-Host "Runtime UAT launch completed. Record screenshots/logs for evidence closure." -ForegroundColor Green
