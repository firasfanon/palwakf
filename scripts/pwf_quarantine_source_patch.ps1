# PalWakf N2.39 - Source Patch Quarantine
# Purpose: keep source_patch snippets out of flutter analyze while preserving them as evidence.
$ErrorActionPreference = "Stop"
$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$archiveRoot = Join-Path "baseline_control" "source_patch_archive"
if (-not (Test-Path $archiveRoot)) { New-Item -ItemType Directory -Force -Path $archiveRoot | Out-Null }
if (Test-Path "source_patch") {
  $target = Join-Path $archiveRoot "source_patch_$stamp"
  Move-Item -Path "source_patch" -Destination $target
  Write-Host "source_patch moved to $target"
} else {
  Write-Host "No source_patch directory found. Nothing to quarantine."
}
Write-Host "Next: dart format . ; flutter analyze"
