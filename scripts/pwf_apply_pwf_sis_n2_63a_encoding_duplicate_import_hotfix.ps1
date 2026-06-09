$ErrorActionPreference = "Stop"

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Read-Utf8File([string]$Path) {
  return [System.IO.File]::ReadAllText((Resolve-Path $Path), [System.Text.Encoding]::UTF8)
}

function Write-Utf8File([string]$Path, [string]$Text) {
  [System.IO.File]::WriteAllText((Resolve-Path $Path), $Text, $utf8NoBom)
}

$mediaPath = "lib/features/platform/media_center/presentation/pages/media_center_operational_pages.dart"
if (Test-Path $mediaPath) {
  $text = Read-Utf8File $mediaPath
  $pattern = 'class\s+MediaCenterMediaLibraryOperationalPage\s+extends\s+StatelessWidget\s*\{.*?\r?\n\}\s*\r?\n\s*class\s+MediaCenterSanctitiesObservatoryOperationalPage'
  $replacement = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String("Y2xhc3MgTWVkaWFDZW50ZXJNZWRpYUxpYnJhcnlPcGVyYXRpb25hbFBhZ2UgZXh0ZW5kcyBTdGF0ZWxlc3NXaWRnZXQgewogIGNvbnN0IE1lZGlhQ2VudGVyTWVkaWFMaWJyYXJ5T3BlcmF0aW9uYWxQYWdlKHtzdXBlci5rZXl9KTsKCiAgQG92ZXJyaWRlCiAgV2lkZ2V0IGJ1aWxkKEJ1aWxkQ29udGV4dCBjb250ZXh0KSB7CiAgICByZXR1cm4gY29uc3QgTWVkaWFDZW50ZXJDb21wbGV0ZWRPcGVyYXRpb25hbFBhZ2UoCiAgICAgIGN1cnJlbnRSb3V0ZTogQXBwUm91dGVzLmFkbWluTWVkaWFDZW50ZXJNZWRpYUxpYnJhcnksCiAgICAgIGdvdmVybmFuY2VGYW1pbHlLZXk6ICdtZWRpYV9saWJyYXJ5JywKICAgICAgdGl0bGU6ICfZhdmD2KrYqNipINin2YTZhdmI2KfYryDYp9mE2KXYudmE2KfZhdmK2KknLAogICAgICBzdWJ0aXRsZToKICAgICAgICAgICfYo9i12YjZhCDYsdiz2YXZitipINmF2KvZhCDYp9mE2LTYudin2LHYjCDYp9mE2YLZiNin2YTYqNiMINin2YTYtdmI2LEg2KfZhNmF2LnYqtmF2K/YqdiMINmI2KfZhNmD2KrZitio2KfYqiDYp9mE2KXYudmE2KfZhdmK2KkuJywKICAgICAgaWNvbjogSWNvbnMuZm9sZGVyX3NwZWNpYWxfb3V0bGluZWQsCiAgICAgIHByaW1hcnlMYWJlbDogJ9il2LbYp9mB2Kkg2YXYp9iv2Kkg2KXYudmE2KfZhdmK2KknLAogICAgICBwcmV2aWV3Um91dGU6IEFwcFJvdXRlcy5tZWRpYUNlbnRlciwKICAgICAgYnVsbGV0czogWwogICAgICAgICfYrdmB2Lgg2YXZiNin2K8g2KfZhNmH2YjZitipINin2YTYpdi52YTYp9mF2YrYqSDZiNin2YTYo9i12YjZhCDYp9mE2KjYtdix2YrYqSDYp9mE2LHYs9mF2YrYqS4nLAogICAgICAgICfYsdio2Lcg2KfZhNmF2YTZgdin2Kog2KjZhdix2YPYsiDYp9mE2YjYq9in2KbZgiDYudmG2K8g2KfZhNit2KfYrNipINiv2YjZhiDZhtiz2K4g2LnYtNmI2KfYptmKLicsCiAgICAgICAgJ9il2KrYp9it2Kkg2KfZhNiq2K3ZhdmK2YQg2K3Ys9ioINin2YTYtdmE2KfYrdmK2Kkg2YjYp9mE2YbYt9in2YIuJywKICAgICAgXSwKICAgICk7CiAgfQp9CgpjbGFzcyBNZWRpYUNlbnRlclNhbmN0aXRpZXNPYnNlcnZhdG9yeU9wZXJhdGlvbmFsUGFnZQo="))
  $matches = [regex]::Matches($text, $pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
  if ($matches.Count -eq 1) {
    $text = [regex]::Replace($text, $pattern, $replacement, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    Write-Utf8File $mediaPath $text
    Write-Host "N2.63A: repaired Media Library Arabic strings in $mediaPath"
  } else {
    Write-Host "N2.63A WARN: expected one Media Library block; found $($matches.Count)."
  }
} else {
  Write-Host "N2.63A WARN: media file not found; skipping."
}

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
  Write-Host "N2.63A: removed duplicate imports from $routesPath. Removed=$duplicateCount"
}

$outDir = "baseline_control\pwf_sis_n2_63a"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
$report = @()
$report += "# PWF-SIS N2.63A Encoding + Duplicate Import Hotfix"
$report += ""
$report += "Generated: $(Get-Date -Format s)"
$report += ""
$report += "Applied:"
$report += "- Repaired Arabic strings in Media Library runtime block using UTF-8 Base64 decode."
$report += "- Removed duplicate import lines from PwfSisRoutes."
$report += ""
$report += "Required:"
$report += "- dart format ."
$report += "- flutter analyze"
$report += "- flutter run -d chrome"
[System.IO.File]::WriteAllText((Join-Path $outDir "encoding_duplicate_import_hotfix_report.md"), ($report -join "`r`n"), $utf8NoBom)

Write-Host "N2.63A applied. Run:"
Write-Host "dart format ."
Write-Host "flutter analyze"
Write-Host "flutter run -d chrome"
