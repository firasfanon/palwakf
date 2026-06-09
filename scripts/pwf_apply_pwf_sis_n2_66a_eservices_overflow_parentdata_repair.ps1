$ErrorActionPreference = "Stop"

# PWF-SIS N2.66A — Public eServices Portal Overflow + ParentDataWidget Repair
# Target: lib/features/platform/home/presentation/widgets/sections/pwf_eservices_portal_section.dart
# No SQL. No Database Wave B. No public data contract change. No waqf_assets mutation.

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Read-Utf8File([string]$Path) {
  return [System.IO.File]::ReadAllText((Resolve-Path $Path), [System.Text.Encoding]::UTF8)
}

function Write-Utf8File([string]$Path, [string]$Text) {
  [System.IO.File]::WriteAllText((Resolve-Path $Path), $Text, $utf8NoBom)
}

$target = "lib/features/platform/home/presentation/widgets/sections/pwf_eservices_portal_section.dart"
if (-not (Test-Path $target)) {
  throw "Target file not found: $target"
}

$outDir = "baseline_control\pwf_sis_n2_66a"
$backupDir = Join-Path $outDir "backups"
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

$backupPath = Join-Path $backupDir "pwf_eservices_portal_section.dart.before_n2_66a"
Copy-Item $target $backupPath -Force

$text = Read-Utf8File $target
$original = $text
$changes = New-Object System.Collections.Generic.List[string]

function Apply-Replace([string]$Name, [string]$Pattern, [string]$Replacement) {
  $script:before = $script:text
  $script:text = [regex]::Replace($script:text, $Pattern, $Replacement)
  if ($script:text -ne $script:before) {
    $script:changes.Add($Name)
  }
}

# 1) The overflow evidence shows a card content Column constrained to ~151px height
#    after Padding offset approximately horizontal=28 / vertical=26.
#    Reduce only the public eServices section padding patterns.
Apply-Replace "reduce-card-padding-28-26" `
  "EdgeInsets\.symmetric\(\s*horizontal:\s*28(?:\.0)?,\s*vertical:\s*26(?:\.0)?\s*\)" `
  "EdgeInsets.symmetric(horizontal: 20, vertical: 14)"

Apply-Replace "reduce-card-padding-28-24" `
  "EdgeInsets\.symmetric\(\s*horizontal:\s*28(?:\.0)?,\s*vertical:\s*24(?:\.0)?\s*\)" `
  "EdgeInsets.symmetric(horizontal: 20, vertical: 14)"

Apply-Replace "reduce-card-padding-24-24" `
  "EdgeInsets\.symmetric\(\s*horizontal:\s*24(?:\.0)?,\s*vertical:\s*24(?:\.0)?\s*\)" `
  "EdgeInsets.symmetric(horizontal: 18, vertical: 14)"

Apply-Replace "reduce-card-padding-all-28" `
  "EdgeInsets\.all\(\s*28(?:\.0)?\s*\)" `
  "EdgeInsets.all(18)"

Apply-Replace "reduce-card-padding-all-24" `
  "EdgeInsets\.all\(\s*24(?:\.0)?\s*\)" `
  "EdgeInsets.all(16)"

# 2) In constrained cards, center-aligned min Column can overflow vertically.
#    Prefer start alignment and max size in this section to let content use available space.
Apply-Replace "column-center-to-start" `
  "mainAxisAlignment:\s*MainAxisAlignment\.center" `
  "mainAxisAlignment: MainAxisAlignment.start"

Apply-Replace "column-min-to-max" `
  "mainAxisSize:\s*MainAxisSize\.min" `
  "mainAxisSize: MainAxisSize.max"

# 3) Common ParentDataWidget misuse pattern:
#    Expanded/Flexible nested as a `child:` of non-Flex widgets is invalid.
#    When it appears as `child: Expanded(` or `child: Flexible(` in this target file,
#    replace it with SizedBox to remove ParentDataWidget usage without altering data flow.
Apply-Replace "child-expanded-to-sizedbox" `
  "child:\s*Expanded\s*\(" `
  "child: SizedBox("

Apply-Replace "child-flexible-to-sizedbox" `
  "child:\s*Flexible\s*\(" `
  "child: SizedBox("

# 4) Soften large vertical gaps inside the section.
Apply-Replace "reduce-sizedbox-height-16" `
  "SizedBox\(\s*height:\s*16(?:\.0)?\s*\)" `
  "SizedBox(height: 10)"

Apply-Replace "reduce-sizedbox-height-14" `
  "SizedBox\(\s*height:\s*14(?:\.0)?\s*\)" `
  "SizedBox(height: 8)"

Apply-Replace "reduce-sizedbox-height-12" `
  "SizedBox\(\s*height:\s*12(?:\.0)?\s*\)" `
  "SizedBox(height: 8)"

if ($text -eq $original) {
  Write-Host "N2.66A WARN: no automatic replacements were applied. A manual layout review may be required."
} else {
  Write-Utf8File $target $text
  Write-Host "N2.66A applied replacements to $target"
}

# 5) ParentData scan report.
$scanLines = New-Object System.Collections.Generic.List[string]
$lineNo = 0
foreach ($line in [System.IO.File]::ReadAllLines((Resolve-Path $target), [System.Text.Encoding]::UTF8)) {
  $lineNo += 1
  if ($line -match "Expanded\(|Flexible\(|Positioned\(") {
    $scanLines.Add(("{0}: {1}" -f $lineNo, $line.Trim()))
  }
}

$report = @()
$report += "# PWF-SIS N2.66A Public eServices Overflow + ParentDataWidget Repair"
$report += ""
$report += "Generated: $(Get-Date -Format s)"
$report += ""
$report += "## Target"
$report += $target
$report += ""
$report += "## Backup"
$report += $backupPath
$report += ""
$report += "## Applied changes"
if ($changes.Count -eq 0) {
  $report += "- none automatically applied"
} else {
  foreach ($c in $changes) {
    $report += "- $c"
  }
}
$report += ""
$report += "## ParentData scan candidates"
if ($scanLines.Count -eq 0) {
  $report += "- none"
} else {
  foreach ($s in $scanLines) {
    $report += "- $s"
  }
}
$report += ""
$report += "## Required retest"
$report += "- dart format ."
$report += "- flutter analyze"
$report += "- flutter run -d chrome"
$report += "- Browser check: public homepage/eServices section"
$report += "- Console clean: no RenderFlex overflow and no ParentDataWidget exception"

[System.IO.File]::WriteAllText((Join-Path $outDir "public_eservices_overflow_parentdata_repair_report.md"), ($report -join "`r`n"), $utf8NoBom)

Write-Host "PWF-SIS N2.66A report written:"
Write-Host " - $outDir\public_eservices_overflow_parentdata_repair_report.md"
Write-Host "Run next:"
Write-Host "dart format ."
Write-Host "flutter analyze"
Write-Host "flutter run -d chrome"
