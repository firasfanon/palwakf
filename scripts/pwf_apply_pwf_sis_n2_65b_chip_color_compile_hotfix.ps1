$ErrorActionPreference = "Stop"

# PWF-SIS N2.65B — Chip Color Compile Hotfix
# Fixes the remaining _Chip.color mismatch in the N2.64 media-center adoption page.
# No SQL. No Database Wave B. No workflow mutation. No waqf_assets mutation.

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Read-Utf8File([string]$Path) {
  return [System.IO.File]::ReadAllText((Resolve-Path $Path), [System.Text.Encoding]::UTF8)
}

function Write-Utf8File([string]$Path, [string]$Text) {
  [System.IO.File]::WriteAllText((Resolve-Path $Path), $Text, $utf8NoBom)
}

function Replace-ChipClass([string]$Path) {
  if (-not (Test-Path $Path)) {
    Write-Host "N2.65B WARN: file not found, skipped: $Path"
    return
  }

  $text = Read-Utf8File $Path
  $pattern = 'class\s+_Chip\s+extends\s+StatelessWidget\s*\{.*?\r?\n\}\s*\r?\n\s*class\s+_MediaCenterRouteTarget'
  $replacement = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String("Y2xhc3MgX0NoaXAgZXh0ZW5kcyBTdGF0ZWxlc3NXaWRnZXQgewogIGNvbnN0IF9DaGlwKHsKICAgIHJlcXVpcmVkIHRoaXMubGFiZWwsCiAgICByZXF1aXJlZCB0aGlzLmljb24sCiAgICB0aGlzLmludmVyc2UgPSBmYWxzZSwKICB9KTsKCiAgZmluYWwgU3RyaW5nIGxhYmVsOwogIGZpbmFsIEljb25EYXRhIGljb247CiAgZmluYWwgYm9vbCBpbnZlcnNlOwoKICBAb3ZlcnJpZGUKICBXaWRnZXQgYnVpbGQoQnVpbGRDb250ZXh0IGNvbnRleHQpIHsKICAgIGZpbmFsIGZnID0gaW52ZXJzZSA/IENvbG9ycy53aGl0ZSA6IGNvbnN0IENvbG9yKDB4RkYwQjNBNzApOwogICAgZmluYWwgYmcgPSBpbnZlcnNlCiAgICAgICAgPyBDb2xvcnMud2hpdGUud2l0aFZhbHVlcyhhbHBoYTogMC4xMikKICAgICAgICA6IGNvbnN0IENvbG9yKDB4RkYwQjNBNzApLndpdGhWYWx1ZXMoYWxwaGE6IDAuMDgpOwoKICAgIHJldHVybiBDb250YWluZXIoCiAgICAgIGNvbnN0cmFpbnRzOiBjb25zdCBCb3hDb25zdHJhaW50cyhtYXhXaWR0aDogMjYwKSwKICAgICAgcGFkZGluZzogY29uc3QgRWRnZUluc2V0cy5zeW1tZXRyaWMoaG9yaXpvbnRhbDogMTAsIHZlcnRpY2FsOiA3KSwKICAgICAgZGVjb3JhdGlvbjogQm94RGVjb3JhdGlvbigKICAgICAgICBjb2xvcjogYmcsCiAgICAgICAgYm9yZGVyUmFkaXVzOiBCb3JkZXJSYWRpdXMuY2lyY3VsYXIoOTk5KSwKICAgICAgICBib3JkZXI6IEJvcmRlci5hbGwoY29sb3I6IGZnLndpdGhWYWx1ZXMoYWxwaGE6IDAuMTgpKSwKICAgICAgKSwKICAgICAgY2hpbGQ6IFJvdygKICAgICAgICBtYWluQXhpc1NpemU6IE1haW5BeGlzU2l6ZS5taW4sCiAgICAgICAgY2hpbGRyZW46IFsKICAgICAgICAgIEljb24oaWNvbiwgc2l6ZTogMTUsIGNvbG9yOiBmZyksCiAgICAgICAgICBjb25zdCBTaXplZEJveCh3aWR0aDogNiksCiAgICAgICAgICBGbGV4aWJsZSgKICAgICAgICAgICAgY2hpbGQ6IFRleHQoCiAgICAgICAgICAgICAgbGFiZWwsCiAgICAgICAgICAgICAgbWF4TGluZXM6IDEsCiAgICAgICAgICAgICAgb3ZlcmZsb3c6IFRleHRPdmVyZmxvdy5lbGxpcHNpcywKICAgICAgICAgICAgICBzdHlsZTogVGV4dFN0eWxlKAogICAgICAgICAgICAgICAgY29sb3I6IGZnLAogICAgICAgICAgICAgICAgZm9udFdlaWdodDogRm9udFdlaWdodC53ODAwLAogICAgICAgICAgICAgICAgZm9udFNpemU6IDEyLAogICAgICAgICAgICAgICksCiAgICAgICAgICAgICksCiAgICAgICAgICApLAogICAgICAgIF0sCiAgICAgICksCiAgICApOwogIH0KfQoKY2xhc3MgX01lZGlhQ2VudGVyUm91dGVUYXJnZXQK"))

  $matches = [regex]::Matches($text, $pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
  if ($matches.Count -ne 1) {
    throw "N2.65B expected exactly one _Chip block in $Path, found $($matches.Count). Manual review required."
  }

  $text = [regex]::Replace(
    $text,
    $pattern,
    $replacement,
    [System.Text.RegularExpressions.RegexOptions]::Singleline
  )

  Write-Utf8File $Path $text
  Write-Host "N2.65B: replaced _Chip class safely in $Path"
}

Replace-ChipClass "lib/features/platform_design_system/presentation/pages/pwf_sis_media_center_low_risk_adoption_page.dart"
Replace-ChipClass "source_overlay/lib/features/platform_design_system/presentation/pages/pwf_sis_media_center_low_risk_adoption_page.dart"

# Deduplicate imports in PwfSisRoutes as a guard.
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
  Write-Host "N2.65B: duplicate imports removed from PwfSisRoutes: $duplicateCount"
}

$outDir = "baseline_control\pwf_sis_n2_65b"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$report = @()
$report += "# PWF-SIS N2.65B Chip Color Compile Hotfix"
$report += ""
$report += "Generated: $(Get-Date -Format s)"
$report += ""
$report += "## Applied"
$report += "- Replaced `_Chip` class in the N2.64 Media Center Low-Risk page with a safe no-color-parameter version."
$report += "- Updated the source_overlay copy as well."
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

[System.IO.File]::WriteAllText((Join-Path $outDir "chip_color_compile_hotfix_report.md"), ($report -join "`r`n"), $utf8NoBom)

Write-Host "PWF-SIS N2.65B applied. Run:"
Write-Host "dart format ."
Write-Host "flutter analyze"
Write-Host "flutter run -d chrome"
