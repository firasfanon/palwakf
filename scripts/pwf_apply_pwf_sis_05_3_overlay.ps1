$ErrorActionPreference = "Stop"
$Root = Get-Location
$Overlay = Join-Path $PSScriptRoot "..\source_overlay"
if (!(Test-Path $Overlay)) {
  Write-Error "source_overlay not found next to package scripts."
}
Copy-Item -Path (Join-Path $Overlay "*") -Destination $Root -Recurse -Force
Write-Host "PWF-SIS-05.3 / N2.48 overlay applied. Next: dart format . ; flutter analyze ; flutter run -d chrome"
