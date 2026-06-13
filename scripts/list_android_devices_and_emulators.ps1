
$ErrorActionPreference = "Stop"

function Resolve-PathCandidate {
  param([string[]]$Candidates)

  foreach ($candidate in $Candidates | Select-Object -Unique) {
    if ($candidate -and (Test-Path $candidate)) {
      return $candidate
    }
  }

  return $null
}

$adbCandidates = @()
$emuCandidates = @()

if ($env:ANDROID_HOME) {
  $adbCandidates += Join-Path $env:ANDROID_HOME "platform-tools\adb.exe"
  $emuCandidates += Join-Path $env:ANDROID_HOME "emulator\emulator.exe"
}

if ($env:ANDROID_SDK_ROOT) {
  $adbCandidates += Join-Path $env:ANDROID_SDK_ROOT "platform-tools\adb.exe"
  $emuCandidates += Join-Path $env:ANDROID_SDK_ROOT "emulator\emulator.exe"
}

if ($env:LOCALAPPDATA) {
  $adbCandidates += Join-Path $env:LOCALAPPDATA "Android\Sdk\platform-tools\adb.exe"
  $emuCandidates += Join-Path $env:LOCALAPPDATA "Android\Sdk\emulator\emulator.exe"
}

$adbCmd = Get-Command adb -ErrorAction SilentlyContinue
if ($adbCmd) { $adbCandidates += $adbCmd.Source }

$emuCmd = Get-Command emulator -ErrorAction SilentlyContinue
if ($emuCmd) { $emuCandidates += $emuCmd.Source }

$adb = Resolve-PathCandidate $adbCandidates
$emulator = Resolve-PathCandidate $emuCandidates

if ($adb) {
  Write-Host "adb: $adb" -ForegroundColor DarkGreen
  & $adb devices
} else {
  Write-Host "adb not found." -ForegroundColor Red
}

if ($emulator) {
  Write-Host ""
  Write-Host "emulator: $emulator" -ForegroundColor DarkGreen
  Write-Host "Available AVDs:" -ForegroundColor Yellow
  & $emulator -list-avds
} else {
  Write-Host ""
  Write-Host "emulator.exe not found." -ForegroundColor Yellow
}
