$ErrorActionPreference = "Stop"

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Read-Utf8File([string]$Path) {
  return [System.IO.File]::ReadAllText((Resolve-Path $Path), [System.Text.Encoding]::UTF8)
}

function Write-Utf8File([string]$Path, [string]$Text) {
  [System.IO.File]::WriteAllText((Resolve-Path $Path), $Text, $utf8NoBom)
}

function Remove-DuplicateImports([string]$Path) {
  $lines = [System.Collections.Generic.List[string]]::new()
  $seenImports = New-Object 'System.Collections.Generic.HashSet[string]'
  $duplicateCount = 0
  foreach ($line in [System.IO.File]::ReadAllLines((Resolve-Path $Path), [System.Text.Encoding]::UTF8)) {
    if ($line.TrimStart().StartsWith("import ")) {
      if ($seenImports.Contains($line)) {
        $duplicateCount += 1
        continue
      }
      [void]$seenImports.Add($line)
    }
    $lines.Add($line)
  }
  [System.IO.File]::WriteAllLines((Resolve-Path $Path), $lines, $utf8NoBom)
  return $duplicateCount
}

# N2.64A cleanup: remove unused private optional color parameter from the N2.64 page.
foreach ($n264Page in @(
  "lib/features/platform_design_system/presentation/pages/pwf_sis_media_center_low_risk_adoption_page.dart",
  "source_overlay/lib/features/platform_design_system/presentation/pages/pwf_sis_media_center_low_risk_adoption_page.dart"
)) {
  if (Test-Path $n264Page) {
    $text = Read-Utf8File $n264Page
    $text = $text -replace "\r?\n\s*this\.color = const Color\(0xFF0B3A70\),", ""
    $text = $text -replace "\r?\n\s*final Color color;", ""
    $text = $text -replace "final fg = inverse \? Colors\.white : color;", "final fg = inverse ? Colors.white : const Color(0xFF0B3A70);"
    $text = $text -replace "inverse \? Colors\.white\.withValues\(alpha: 0\.12\) : color\.withValues\(alpha: 0\.08\)", "inverse ? Colors.white.withValues(alpha: 0.12) : const Color(0xFF0B3A70).withValues(alpha: 0.08)"
    Write-Utf8File $n264Page $text
    Write-Host "N2.64A cleanup applied to $n264Page"
  }
}

$routesPath = "lib/features/platform_design_system/presentation/routes/pwf_sis_routes.dart"
if (-not (Test-Path $routesPath)) {
  throw "Routes file not found: $routesPath"
}

$removedBefore = Remove-DuplicateImports $routesPath
Write-Host "Duplicate imports removed before N2.65 route patch: $removedBefore"

# Copy N2.65 page.
$source = "source_overlay/lib/features/platform_design_system/presentation/pages/pwf_sis_services_platform_content_adoption_page.dart"
$target = "lib/features/platform_design_system/presentation/pages/pwf_sis_services_platform_content_adoption_page.dart"
if (-not (Test-Path $source)) {
  throw "Missing source overlay: $source"
}
$targetDir = Split-Path -Parent $target
if (-not (Test-Path $targetDir)) {
  New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
}
Copy-Item $source $target -Force
Write-Host "Copied N2.65 Services + Platform Content adoption page."

# Patch routes.
$routes = Read-Utf8File $routesPath
if ($routes -notmatch "pwf_sis_services_platform_content_adoption_page.dart") {
  $routes = $routes -replace "((?:import [^\r\n]+;\r?\n)+)", "`$1import '../pages/pwf_sis_services_platform_content_adoption_page.dart';`r`n"
}
if ($routes -notmatch "servicesPlatformContentAdoption") {
  $routes = $routes -replace "(class\s+PwfSisRoutes\s*\{\s*)", "`$1`r`n  static const servicesPlatformContentAdoption = PwfSisServicesPlatformContentAdoptionPage.routePath;`r`n"
}
if ($routes -notmatch "PwfSisServicesPlatformContentAdoptionPage\(\)") {
  $insert = @'
      GoRoute(
        path: servicesPlatformContentAdoption,
        builder: (context, state) =>
            const PwfSisServicesPlatformContentAdoptionPage(),
      ),

'@
  if ($routes -match "PwfSisMediaCenterLowRiskAdoptionPage\(\)") {
    $pattern = "(GoRoute\(\s*path:\s*mediaCenterLowRiskAdoption,\s*builder:\s*\(context,\s*state\)\s*=>\s*const\s*PwfSisMediaCenterLowRiskAdoptionPage\(\),\s*\),)"
    $routes = [regex]::Replace($routes, $pattern, "`$1`r`n$insert", 1)
  } else {
    $routes = $routes -replace "\r?\n\s*\];", "`r`n$insert`r`n  ];"
  }
}
Write-Utf8File $routesPath $routes
$removedAfter = Remove-DuplicateImports $routesPath
Write-Host "Duplicate imports removed after N2.65 route patch: $removedAfter"

# Patch AppRoutes.
$appRoutesPath = "lib/app/routing/app_routes.dart"
if (Test-Path $appRoutesPath) {
  $appRoutes = Read-Utf8File $appRoutesPath
  if ($appRoutes -notmatch "adminDesignSystemServicesPlatformContentAdoption") {
    $insertConst = "  static const adminDesignSystemServicesPlatformContentAdoption =`r`n      '/admin/platform/design-system/services-platform-content-adoption';"
    if ($appRoutes -match "adminDesignSystemMediaCenterLowRiskAdoption") {
      $appRoutes = $appRoutes -replace "(static const adminDesignSystemMediaCenterLowRiskAdoption[\s\S]*?;\s*)", "`$1`r`n$insertConst`r`n"
    } else {
      $appRoutes = $appRoutes -replace "(class\s+AppRoutes\s*\{\s*)", "`$1`r`n$insertConst`r`n"
    }
    Write-Utf8File $appRoutesPath $appRoutes
    Write-Host "Added AppRoutes.adminDesignSystemServicesPlatformContentAdoption."
  }
}

$outDir = "baseline_control\pwf_sis_n2_65"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
$report = @()
$report += "# PWF-SIS N2.65 Services + Platform Content Bulk Migration Report"
$report += ""
$report += "Generated: $(Get-Date -Format s)"
$report += ""
$report += "Included cleanup:"
$report += "- N2.64A unused_element_parameter cleanup."
$report += "- PwfSisRoutes duplicate import cleanup."
$report += ""
$report += "Applied:"
$report += "- Added route: /admin/platform/design-system/services-platform-content-adoption"
$report += "- Added Services + Platform Content adoption page."
$report += "- Preserved Service Center and Platform Content workflows."
$report += ""
$report += "Run next:"
$report += "- dart format ."
$report += "- flutter analyze"
$report += "- flutter run -d chrome"
[System.IO.File]::WriteAllText((Join-Path $outDir "services_platform_content_migration_report.md"), ($report -join "`r`n"), $utf8NoBom)

Write-Host "PWF-SIS N2.65 applied. Run:"
Write-Host "dart format ."
Write-Host "flutter analyze"
Write-Host "flutter run -d chrome"
