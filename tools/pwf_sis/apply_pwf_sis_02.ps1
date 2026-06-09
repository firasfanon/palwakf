param(
  [string]$ProjectRoot = "."
)

$ErrorActionPreference = "Stop"

Write-Host "PWF-SIS-02 one-batch apply started..." -ForegroundColor Cyan

$source = Join-Path $PSScriptRoot "..\..\patch_to_project"
if (!(Test-Path $source)) {
  Write-Host "If this script is already inside the project root, use the ZIP's patch_to_project manually." -ForegroundColor Yellow
  $source = Join-Path (Get-Location) "patch_to_project"
}

if (!(Test-Path $source)) {
  throw "patch_to_project folder not found."
}

Copy-Item -Path (Join-Path $source "*") -Destination $ProjectRoot -Recurse -Force

Write-Host "PWF-SIS-02 files copied." -ForegroundColor Green
Write-Host "Next: merge integration_snippets/go_router_pwf_sis_routes_snippet.dart into the real GoRouter." -ForegroundColor Yellow
Write-Host "Then run: dart format . ; flutter analyze ; flutter run -d chrome" -ForegroundColor Yellow
