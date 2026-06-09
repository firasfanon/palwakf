$ErrorActionPreference = "Stop"

# PWF-SIS N2.63 — Platform Admin Pages bulk migration control package.
# No SQL. No Database Wave B. No waqf_assets mutation.

$adoptionSource = "source_overlay/lib/features/platform_design_system/presentation/pages/pwf_sis_platform_admin_adoption_page.dart"
$adoptionTarget = "lib/features/platform_design_system/presentation/pages/pwf_sis_platform_admin_adoption_page.dart"

if (-not (Test-Path $adoptionSource)) {
  throw "Missing adoption page source: $adoptionSource"
}

$targetDir = Split-Path -Parent $adoptionTarget
if (-not (Test-Path $targetDir)) {
  New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
}
Copy-Item $adoptionSource $adoptionTarget -Force
Write-Host "Copied N2.63 Platform Admin Adoption page."

$routesPath = "lib/features/platform_design_system/presentation/routes/pwf_sis_routes.dart"
if (-not (Test-Path $routesPath)) {
  throw "Routes file not found: $routesPath"
}

$routes = Get-Content -Raw -Encoding UTF8 $routesPath

if ($routes -notmatch "pwf_sis_platform_admin_adoption_page.dart") {
  $routes = $routes -replace "((?:import [^\r\n]+;\r?\n)+)", "`$1import '../pages/pwf_sis_platform_admin_adoption_page.dart';`r`n"
}

if ($routes -notmatch "platformAdminAdoption") {
  $routes = $routes -replace "(class\s+PwfSisRoutes\s*\{\s*)", "`$1`r`n  static const platformAdminAdoption = PwfSisPlatformAdminAdoptionPage.routePath;`r`n"
}

if ($routes -notmatch "PwfSisPlatformAdminAdoptionPage\(\)") {
  $insert = @'
      GoRoute(
        path: platformAdminAdoption,
        builder: (context, state) => const PwfSisPlatformAdminAdoptionPage(),
      ),

'@
  $patternDesign = "(GoRoute\(\s*path:\s*root,\s*builder:\s*\(context,\s*state\)\s*=>\s*const\s*[A-Za-z0-9_]+\(\),\s*\),)"
  if ($routes -match $patternDesign) {
    $routes = [regex]::Replace($routes, $patternDesign, "`$1`r`n$insert", 1)
  } else {
    $routes = $routes -replace "\r?\n\s*\];", "`r`n$insert`r`n  ];"
  }
}

Set-Content -Path $routesPath -Value $routes -Encoding UTF8
Write-Host "Patched PwfSisRoutes with platform admin adoption route."

$appRoutesPath = "lib/app/routing/app_routes.dart"
if (Test-Path $appRoutesPath) {
  $appRoutes = Get-Content -Raw -Encoding UTF8 $appRoutesPath
  if ($appRoutes -notmatch "adminDesignSystemPlatformAdminAdoption") {
    $insertConst = "  static const adminDesignSystemPlatformAdminAdoption =`r`n      '/admin/platform/design-system/platform-admin-adoption';"
    if ($appRoutes -match "adminDesignSystem") {
      $appRoutes = $appRoutes -replace "(static const adminDesignSystem[^\r\n]+;\s*)", "`$1`r`n$insertConst`r`n"
    } else {
      $appRoutes = $appRoutes -replace "(class\s+AppRoutes\s*\{\s*)", "`$1`r`n$insertConst`r`n"
    }
    Set-Content -Path $appRoutesPath -Value $appRoutes -Encoding UTF8
    Write-Host "Added AppRoutes.adminDesignSystemPlatformAdminAdoption."
  } else {
    Write-Host "AppRoutes adminDesignSystemPlatformAdminAdoption already exists."
  }
}

$outDir = "baseline_control\pwf_sis_n2_63"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$report = @()
$report += "# PWF-SIS N2.63 Platform Admin Bulk Migration Report"
$report += ""
$report += "Generated: $(Get-Date -Format s)"
$report += ""
$report += "## Applied"
$report += "- Added route: /admin/platform/design-system/platform-admin-adoption"
$report += "- Added Platform Admin Adoption control page."
$report += "- Runtime pages outside Platform Admin family were not changed."
$report += ""
$report += "## Candidate pages from N2.62"
$report += "- pwf_database_domain_migration_page.dart"
$report += "- pwf_dynamic_system_home_page.dart"
$report += "- pwf_dynamic_system_page.dart"
$report += "- pwf_platform_system_operations_page.dart"
$report += "- usage_guide_screen.dart"
$report += ""
$report += "## Required next evidence"
$report += "- dart format ."
$report += "- flutter analyze"
$report += "- flutter run -d chrome"
$report += "- Browser: /admin/platform/design-system/platform-admin-adoption"
$report += "- Console clean and no overflow."

Set-Content -Path "$outDir\platform_admin_bulk_migration_report.md" -Value ($report -join "`r`n") -Encoding UTF8

Write-Host "PWF-SIS N2.63 applied. Run:"
Write-Host "dart format ."
Write-Host "flutter analyze"
Write-Host "flutter run -d chrome"
