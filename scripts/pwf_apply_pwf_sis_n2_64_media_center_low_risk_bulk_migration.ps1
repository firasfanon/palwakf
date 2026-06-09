$ErrorActionPreference = "Stop"

# PWF-SIS N2.64 — Media Center Low-Risk Bulk Migration.
# No SQL. No Database Wave B. No waqf_assets mutation.

$source = "source_overlay/lib/features/platform_design_system/presentation/pages/pwf_sis_media_center_low_risk_adoption_page.dart"
$target = "lib/features/platform_design_system/presentation/pages/pwf_sis_media_center_low_risk_adoption_page.dart"

if (-not (Test-Path $source)) {
  throw "Missing source overlay: $source"
}

$targetDir = Split-Path -Parent $target
if (-not (Test-Path $targetDir)) {
  New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
}
Copy-Item $source $target -Force
Write-Host "Copied N2.64 Media Center Low-Risk Adoption page."

$routesPath = "lib/features/platform_design_system/presentation/routes/pwf_sis_routes.dart"
if (-not (Test-Path $routesPath)) {
  throw "Routes file not found: $routesPath"
}

$routes = [System.IO.File]::ReadAllText((Resolve-Path $routesPath), [System.Text.Encoding]::UTF8)

if ($routes -notmatch "pwf_sis_media_center_low_risk_adoption_page.dart") {
  $routes = $routes -replace "((?:import [^\r\n]+;\r?\n)+)", "`$1import '../pages/pwf_sis_media_center_low_risk_adoption_page.dart';`r`n"
}

if ($routes -notmatch "mediaCenterLowRiskAdoption") {
  $routes = $routes -replace "(class\s+PwfSisRoutes\s*\{\s*)", "`$1`r`n  static const mediaCenterLowRiskAdoption = PwfSisMediaCenterLowRiskAdoptionPage.routePath;`r`n"
}

if ($routes -notmatch "PwfSisMediaCenterLowRiskAdoptionPage\(\)") {
  $insert = @'
      GoRoute(
        path: mediaCenterLowRiskAdoption,
        builder: (context, state) => const PwfSisMediaCenterLowRiskAdoptionPage(),
      ),

'@

  if ($routes -match "PwfSisPlatformAdminAdoptionPage\(\)") {
    $pattern = "(GoRoute\(\s*path:\s*platformAdminAdoption,\s*builder:\s*\(context,\s*state\)\s*=>\s*const\s*PwfSisPlatformAdminAdoptionPage\(\),\s*\),)"
    $routes = [regex]::Replace($routes, $pattern, "`$1`r`n$insert", 1)
  } else {
    $routes = $routes -replace "\r?\n\s*\];", "`r`n$insert`r`n  ];"
  }
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText((Resolve-Path $routesPath), $routes, $utf8NoBom)
Write-Host "Patched PwfSisRoutes with N2.64 Media Center Low-Risk route."

$appRoutesPath = "lib/app/routing/app_routes.dart"
if (Test-Path $appRoutesPath) {
  $appRoutes = [System.IO.File]::ReadAllText((Resolve-Path $appRoutesPath), [System.Text.Encoding]::UTF8)
  if ($appRoutes -notmatch "adminDesignSystemMediaCenterLowRiskAdoption") {
    $insertConst = "  static const adminDesignSystemMediaCenterLowRiskAdoption =`r`n      '/admin/platform/design-system/media-center-low-risk-adoption';"
    if ($appRoutes -match "adminDesignSystemPlatformAdminAdoption") {
      $appRoutes = $appRoutes -replace "(static const adminDesignSystemPlatformAdminAdoption[\s\S]*?;\s*)", "`$1`r`n$insertConst`r`n"
    } else {
      $appRoutes = $appRoutes -replace "(class\s+AppRoutes\s*\{\s*)", "`$1`r`n$insertConst`r`n"
    }
    [System.IO.File]::WriteAllText((Resolve-Path $appRoutesPath), $appRoutes, $utf8NoBom)
    Write-Host "Added AppRoutes.adminDesignSystemMediaCenterLowRiskAdoption."
  }
}

$outDir = "baseline_control\pwf_sis_n2_64"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$report = @()
$report += "# PWF-SIS N2.64 Media Center Low-Risk Bulk Migration Report"
$report += ""
$report += "Generated: $(Get-Date -Format s)"
$report += ""
$report += "## Applied"
$report += "- Added route: /admin/platform/design-system/media-center-low-risk-adoption"
$report += "- Added Media Center low-risk adoption page."
$report += "- Preserved Media Center runtime workflow."
$report += ""
$report += "## Routes to test"
$report += "- /admin/platform/design-system/media-center-low-risk-adoption"
$report += "- /admin/media-center/governance"
$report += "- /admin/media-center"
$report += "- /admin/media-center/media-library"
$report += "- /admin/media-center/photos"
$report += "- /admin/media-center/videos"
$report += ""
$report += "## Required next evidence"
$report += "- dart format ."
$report += "- flutter analyze"
$report += "- flutter run -d chrome"
$report += "- Browser screenshots and console clean evidence."

[System.IO.File]::WriteAllText((Join-Path $outDir "media_center_low_risk_migration_report.md"), ($report -join "`r`n"), $utf8NoBom)

Write-Host "PWF-SIS N2.64 applied. Run:"
Write-Host "dart format ."
Write-Host "flutter analyze"
Write-Host "flutter run -d chrome"
