$ErrorActionPreference = "Stop"

# PWF-SIS N2.65A — Restore Color Fields Compile Hotfix
# Fixes over-aggressive N2.64A cleanup that removed `color` fields still used by
# _Notice and _Chip in pwf_sis_media_center_low_risk_adoption_page.dart.
# No SQL. No Database Wave B. No workflow mutation. No waqf_assets mutation.

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Read-Utf8File([string]$Path) {
  return [System.IO.File]::ReadAllText((Resolve-Path $Path), [System.Text.Encoding]::UTF8)
}

function Write-Utf8File([string]$Path, [string]$Text) {
  [System.IO.File]::WriteAllText((Resolve-Path $Path), $Text, $utf8NoBom)
}

function Restore-ColorFields([string]$Path) {
  if (-not (Test-Path $Path)) {
    Write-Host "N2.65A WARN: file not found, skipped: $Path"
    return
  }

  $text = Read-Utf8File $Path

  # Restore `final Color color;` inside _Notice if constructor/use sites still need it.
  if ($text -match "class\s+_Notice\s+extends\s+StatelessWidget" -and
      $text -match "required\s+this\.color" -and
      $text -notmatch "final\s+Color\s+color;") {
    $text = $text -replace "(final\s+String\s+message;\s*\r?\n)", "`$1  final Color color;`r`n"
    Write-Host "N2.65A: restored _Notice.color field in $Path"
  }

  # Restore _Chip optional color constructor parameter if the class still references `color`.
  if ($text -match "class\s+_Chip\s+extends\s+StatelessWidget") {
    if ($text -match ":\s*color\.withValues\(alpha:\s*0\.08\)" -and
        $text -notmatch "this\.color\s*=\s*const\s+Color\(0xFF0B3A70\)") {
      $text = $text -replace "(required\s+this\.icon,\s*\r?\n\s*this\.inverse\s*=\s*false,\s*)", "`$1`r`n    this.color = const Color(0xFF0B3A70),"
      Write-Host "N2.65A: restored _Chip optional color parameter in $Path"
    }

    if ($text -match ":\s*color\.withValues\(alpha:\s*0\.08\)" -and
        $text -notmatch "final\s+Color\s+color;") {
      $text = $text -replace "(final\s+IconData\s+icon;\s*\r?\n)", "`$1  final Color color;`r`n"
      Write-Host "N2.65A: restored _Chip.color field in $Path"
    }
  }

  Write-Utf8File $Path $text
}

# Repair runtime page and source overlay copy if present.
Restore-ColorFields "lib/features/platform_design_system/presentation/pages/pwf_sis_media_center_low_risk_adoption_page.dart"
Restore-ColorFields "source_overlay/lib/features/platform_design_system/presentation/pages/pwf_sis_media_center_low_risk_adoption_page.dart"

# Deduplicate imports in PwfSisRoutes once more.
$routesPath = "lib/features/platform_design_system/presentation/routes/pwf_sis_routes.dart"
if (Test-Path $routesPath) {
  $lines = [System.Collections.Generic.List[string]]::new()
  $seenImports = New-Object 'System.Collections.Generic.HashSet[string]'
  $duplicateCount = 0

  foreach ($line in [System.IO.File]::ReadAllLines((Resolve-Path $routesPath), [System.Text.Encoding]::UTF8)) {
    if ($line.TrimStart().StartsWith("import ")) {
      if ($seenImports.Contains($line)) {
        $duplicateCount += 1
        continue
      }
      [void]$seenImports.Add($line)
    }
    $lines.Add($line)
  }

  [System.IO.File]::WriteAllLines((Resolve-Path $routesPath), $lines, $utf8NoBom)
  Write-Host "N2.65A: duplicate imports removed from PwfSisRoutes: $duplicateCount"
}

$outDir = "baseline_control\pwf_sis_n2_65a"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$report = @()
$report += "# PWF-SIS N2.65A Restore Color Fields Compile Hotfix"
$report += ""
$report += "Generated: $(Get-Date -Format s)"
$report += ""
$report += "## Applied"
$report += "- Restored `_Notice.color` field where required by constructor and rendering."
$report += "- Restored `_Chip.color` optional parameter/field where still used by rendering."
$report += "- Deduplicated PwfSisRoutes imports."
$report += ""
$report += "## Required"
$report += "- dart format ."
$report += "- flutter analyze"
$report += "- flutter run -d chrome"
$report += ""
$report += "## Boundaries"
$report += "- No SQL."
$report += "- No Database Wave B."
$report += "- No workflow mutation."
$report += "- No waqf_assets mutation."

[System.IO.File]::WriteAllText((Join-Path $outDir "restore_color_fields_compile_hotfix_report.md"), ($report -join "`r`n"), $utf8NoBom)

Write-Host "PWF-SIS N2.65A applied. Run:"
Write-Host "dart format ."
Write-Host "flutter analyze"
Write-Host "flutter run -d chrome"
