$ErrorActionPreference = "Stop"

# PWF-SIS N2.66 — Public Pages Responsive Alignment.
# Includes N2.65C result intake as local report only.
# No SQL. No Database Wave B. No waqf_assets mutation.

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Read-Utf8File([string]$Path) {
  return [System.IO.File]::ReadAllText((Resolve-Path $Path), [System.Text.Encoding]::UTF8)
}

function Write-Utf8File([string]$Path, [string]$Text) {
  [System.IO.File]::WriteAllText((Resolve-Path $Path), $Text, $utf8NoBom)
}

function Remove-DuplicateImports([string]$Path) {
  if (-not (Test-Path $Path)) { return 0 }

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

# 1) Copy N2.66 page.
$source = "source_overlay/lib/features/platform_design_system/presentation/pages/pwf_sis_public_responsive_alignment_page.dart"
$target = "lib/features/platform_design_system/presentation/pages/pwf_sis_public_responsive_alignment_page.dart"

if (-not (Test-Path $source)) {
  throw "Missing source overlay: $source"
}

$targetDir = Split-Path -Parent $target
if (-not (Test-Path $targetDir)) {
  New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
}
Copy-Item $source $target -Force
Write-Host "Copied N2.66 Public Responsive Alignment page."

# 2) Patch PwfSisRoutes.
$routesPath = "lib/features/platform_design_system/presentation/routes/pwf_sis_routes.dart"
if (-not (Test-Path $routesPath)) {
  throw "Routes file not found: $routesPath"
}

$removedBefore = Remove-DuplicateImports $routesPath
Write-Host "N2.66: duplicate imports removed before route patch: $removedBefore"

$routes = Read-Utf8File $routesPath

if ($routes -notmatch "pwf_sis_public_responsive_alignment_page.dart") {
  $routes = $routes -replace "((?:import [^\r\n]+;\r?\n)+)", "`$1import '../pages/pwf_sis_public_responsive_alignment_page.dart';`r`n"
}

if ($routes -notmatch "publicResponsiveAlignment") {
  $routes = $routes -replace "(class\s+PwfSisRoutes\s*\{\s*)", "`$1`r`n  static const publicResponsiveAlignment = PwfSisPublicResponsiveAlignmentPage.routePath;`r`n"
}

if ($routes -notmatch "PwfSisPublicResponsiveAlignmentPage\(\)") {
  $insert = @'
      GoRoute(
        path: publicResponsiveAlignment,
        builder: (context, state) =>
            const PwfSisPublicResponsiveAlignmentPage(),
      ),

'@

  if ($routes -match "PwfSisServicesPlatformContentAdoptionPage\(\)") {
    $pattern = "(GoRoute\(\s*path:\s*servicesPlatformContentAdoption,\s*builder:\s*\(context,\s*state\)\s*=>\s*const\s*PwfSisServicesPlatformContentAdoptionPage\(\),\s*\),)"
    $routes = [regex]::Replace($routes, $pattern, "`$1`r`n$insert", 1)
  } else {
    $routes = $routes -replace "\r?\n\s*\];", "`r`n$insert`r`n  ];"
  }
}

Write-Utf8File $routesPath $routes
$removedAfter = Remove-DuplicateImports $routesPath
Write-Host "N2.66: duplicate imports removed after route patch: $removedAfter"

# 3) Patch AppRoutes.
$appRoutesPath = "lib/app/routing/app_routes.dart"
if (Test-Path $appRoutesPath) {
  $appRoutes = Read-Utf8File $appRoutesPath
  if ($appRoutes -notmatch "adminDesignSystemPublicResponsiveAlignment") {
    $insertConst = "  static const adminDesignSystemPublicResponsiveAlignment =`r`n      '/admin/platform/design-system/public-responsive-alignment';"
    if ($appRoutes -match "adminDesignSystemServicesPlatformContentAdoption") {
      $appRoutes = $appRoutes -replace "(static const adminDesignSystemServicesPlatformContentAdoption[\s\S]*?;\s*)", "`$1`r`n$insertConst`r`n"
    } else {
      $appRoutes = $appRoutes -replace "(class\s+AppRoutes\s*\{\s*)", "`$1`r`n$insertConst`r`n"
    }
    Write-Utf8File $appRoutesPath $appRoutes
    Write-Host "Added AppRoutes.adminDesignSystemPublicResponsiveAlignment."
  } else {
    Write-Host "AppRoutes adminDesignSystemPublicResponsiveAlignment already exists."
  }
}

# 4) Write report.
$outDir = "baseline_control\pwf_sis_n2_66"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$report = @()
$report += "# PWF-SIS N2.66 Public Pages Responsive Alignment Report"
$report += ""
$report += "Generated: $(Get-Date -Format s)"
$report += ""
$report += "## N2.65B evidence accepted before this batch"
$report += "- N2.65B script applied."
$report += "- dart format completed."
$report += "- flutter analyze returned No issues found."
$report += "- flutter run -d chrome started successfully."
$report += ""
$report += "## Applied in N2.66"
$report += "- Added route: /admin/platform/design-system/public-responsive-alignment"
$report += "- Added Public Responsive Alignment control page."
$report += "- Preserved public data contracts and published-only filters."
$report += ""
$report += "## Routes to test"
$report += "- /admin/platform/design-system/public-responsive-alignment"
$report += "- /"
$report += "- /services"
$report += "- /media-center"
$report += "- /home/news"
$report += ""
$report += "## Required next evidence"
$report += "- dart format ."
$report += "- flutter analyze"
$report += "- flutter run -d chrome"
$report += "- Browser screenshots at desktop/tablet/mobile where possible."
$report += "- Console clean and no overflow."

[System.IO.File]::WriteAllText((Join-Path $outDir "public_responsive_alignment_report.md"), ($report -join "`r`n"), $utf8NoBom)

Write-Host "PWF-SIS N2.66 applied. Run:"
Write-Host "dart format ."
Write-Host "flutter analyze"
Write-Host "flutter run -d chrome"
