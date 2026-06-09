$ErrorActionPreference = "Stop"

# PWF-SIS N2.66B — Public Overflow Definitive Repair
# Scope:
# - Public eServices Portal card overflow still showing Offset(28,26).
# - Admin login mobile overflow visual evidence.
# - ParentDataWidget scan + conservative repair.
#
# No SQL. No Database Wave B. No public data contract change. No waqf_assets mutation.

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Read-Utf8File([string]$Path) {
  return [System.IO.File]::ReadAllText((Resolve-Path $Path), [System.Text.Encoding]::UTF8)
}

function Write-Utf8File([string]$Path, [string]$Text) {
  [System.IO.File]::WriteAllText((Resolve-Path $Path), $Text, $utf8NoBom)
}

function Backup-File([string]$Path, [string]$BackupDir) {
  if (Test-Path $Path) {
    $name = ($Path -replace "[:\\\/]", "_")
    Copy-Item $Path (Join-Path $BackupDir "$name.before_n2_66b") -Force
  }
}

function Apply-Regex([ref]$TextRef, [string]$Name, [string]$Pattern, [string]$Replacement, [System.Collections.Generic.List[string]]$Changes) {
  $before = $TextRef.Value
  $TextRef.Value = [regex]::Replace($TextRef.Value, $Pattern, $Replacement, [System.Text.RegularExpressions.RegexOptions]::Singleline)
  if ($TextRef.Value -ne $before) {
    $Changes.Add($Name)
  }
}

function Repair-EServices([string]$Path, [string]$BackupDir) {
  if (-not (Test-Path $Path)) {
    throw "Target eServices file not found: $Path"
  }

  Backup-File $Path $BackupDir

  $text = Read-Utf8File $Path
  $changes = New-Object System.Collections.Generic.List[string]
  $ref = [ref]$text

  # The N2.66A log still shows parentData offset=Offset(28.0, 26.0).
  # These replacements intentionally hit raw horizontal/vertical values as a second-pass repair.
  Apply-Regex $ref "force-horizontal-28-to-14" "horizontal\s*:\s*28(?:\.0)?" "horizontal: 14" $changes
  Apply-Regex $ref "force-vertical-26-to-10" "vertical\s*:\s*26(?:\.0)?" "vertical: 10" $changes
  Apply-Regex $ref "force-horizontal-24-to-16" "horizontal\s*:\s*24(?:\.0)?" "horizontal: 16" $changes
  Apply-Regex $ref "force-vertical-24-to-12" "vertical\s*:\s*24(?:\.0)?" "vertical: 12" $changes

  # Reduce common card icon and large-title pressure inside this public section.
  Apply-Regex $ref "icon-size-64-to-42" "size\s*:\s*64(?:\.0)?" "size: 42" $changes
  Apply-Regex $ref "icon-size-56-to-40" "size\s*:\s*56(?:\.0)?" "size: 40" $changes
  Apply-Regex $ref "icon-size-52-to-38" "size\s*:\s*52(?:\.0)?" "size: 38" $changes
  Apply-Regex $ref "icon-size-48-to-36" "size\s*:\s*48(?:\.0)?" "size: 36" $changes
  Apply-Regex $ref "font-size-22-to-18" "fontSize\s*:\s*22(?:\.0)?" "fontSize: 18" $changes
  Apply-Regex $ref "font-size-20-to-17" "fontSize\s*:\s*20(?:\.0)?" "fontSize: 17" $changes
  Apply-Regex $ref "font-size-18-to-16" "fontSize\s*:\s*18(?:\.0)?" "fontSize: 16" $changes

  # Reduce vertical gaps that commonly cause bottom overflow.
  Apply-Regex $ref "gap-20-to-10" "SizedBox\(\s*height\s*:\s*20(?:\.0)?\s*\)" "SizedBox(height: 10)" $changes
  Apply-Regex $ref "gap-18-to-10" "SizedBox\(\s*height\s*:\s*18(?:\.0)?\s*\)" "SizedBox(height: 10)" $changes
  Apply-Regex $ref "gap-16-to-8" "SizedBox\(\s*height\s*:\s*16(?:\.0)?\s*\)" "SizedBox(height: 8)" $changes
  Apply-Regex $ref "gap-14-to-8" "SizedBox\(\s*height\s*:\s*14(?:\.0)?\s*\)" "SizedBox(height: 8)" $changes
  Apply-Regex $ref "gap-12-to-6" "SizedBox\(\s*height\s*:\s*12(?:\.0)?\s*\)" "SizedBox(height: 6)" $changes

  # Remove invalid ParentDataWidget use when used as a direct child of a non-Flex widget.
  Apply-Regex $ref "child-expanded-to-sizedbox" "child\s*:\s*Expanded\s*\(" "child: SizedBox(" $changes
  Apply-Regex $ref "child-flexible-to-sizedbox" "child\s*:\s*Flexible\s*\(" "child: SizedBox(" $changes
  Apply-Regex $ref "child-positioned-to-align" "child\s*:\s*Positioned\s*\(" "child: Align(" $changes

  # Avoid horizontal overflows in constrained rows by softening strict spacing.
  Apply-Regex $ref "row-main-spacebetween-start" "mainAxisAlignment\s*:\s*MainAxisAlignment\.spaceBetween" "mainAxisAlignment: MainAxisAlignment.start" $changes

  Write-Utf8File $Path $ref.Value
  return $changes
}

function Find-LoginFiles() {
  $matches = New-Object System.Collections.Generic.List[string]
  $files = Get-ChildItem -Path "lib" -Recurse -File -Include "*.dart" -ErrorAction SilentlyContinue
  foreach ($f in $files) {
    $content = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
    if ($content -match "تسجيل الدخول الإداري" -or
        $content -match "نظام إداري سيادي" -or
        $content -match "RBAC\s*/\s*RLS" -or
        $content -match "WebLoginScreen") {
      $rel = Resolve-Path -Relative $f.FullName
      $matches.Add(($rel -replace "^\.\\", ""))
    }
  }
  return $matches
}

function Repair-LoginOverflow([string]$Path, [string]$BackupDir) {
  if (-not (Test-Path $Path)) { return @() }

  Backup-File $Path $BackupDir

  $text = Read-Utf8File $Path
  $changes = New-Object System.Collections.Generic.List[string]
  $ref = [ref]$text

  # Login mobile evidence shows narrow pane overflows.
  # Apply conservative mobile-friendly reductions only inside identified login files.
  Apply-Regex $ref "login-padding-48-to-24" "EdgeInsets\.all\(\s*48(?:\.0)?\s*\)" "EdgeInsets.all(24)" $changes
  Apply-Regex $ref "login-padding-40-to-22" "EdgeInsets\.all\(\s*40(?:\.0)?\s*\)" "EdgeInsets.all(22)" $changes
  Apply-Regex $ref "login-padding-36-to-20" "EdgeInsets\.all\(\s*36(?:\.0)?\s*\)" "EdgeInsets.all(20)" $changes
  Apply-Regex $ref "login-padding-32-to-18" "EdgeInsets\.all\(\s*32(?:\.0)?\s*\)" "EdgeInsets.all(18)" $changes
  Apply-Regex $ref "login-gap-32-to-16" "SizedBox\(\s*height\s*:\s*32(?:\.0)?\s*\)" "SizedBox(height: 16)" $changes
  Apply-Regex $ref "login-gap-28-to-14" "SizedBox\(\s*height\s*:\s*28(?:\.0)?\s*\)" "SizedBox(height: 14)" $changes
  Apply-Regex $ref "login-gap-24-to-12" "SizedBox\(\s*height\s*:\s*24(?:\.0)?\s*\)" "SizedBox(height: 12)" $changes
  Apply-Regex $ref "login-font-38-to-30" "fontSize\s*:\s*38(?:\.0)?" "fontSize: 30" $changes
  Apply-Regex $ref "login-font-36-to-28" "fontSize\s*:\s*36(?:\.0)?" "fontSize: 28" $changes
  Apply-Regex $ref "login-font-34-to-27" "fontSize\s*:\s*34(?:\.0)?" "fontSize: 27" $changes
  Apply-Regex $ref "login-font-32-to-26" "fontSize\s*:\s*32(?:\.0)?" "fontSize: 26" $changes
  Apply-Regex $ref "login-font-30-to-25" "fontSize\s*:\s*30(?:\.0)?" "fontSize: 25" $changes
  Apply-Regex $ref "login-child-expanded-to-sizedbox" "child\s*:\s*Expanded\s*\(" "child: SizedBox(" $changes
  Apply-Regex $ref "login-child-flexible-to-sizedbox" "child\s*:\s*Flexible\s*\(" "child: SizedBox(" $changes

  Write-Utf8File $Path $ref.Value
  return $changes
}

$outDir = "baseline_control\pwf_sis_n2_66b"
$backupDir = Join-Path $outDir "backups"
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

$allChanges = New-Object System.Collections.Generic.List[string]

$eservicesPath = "lib/features/platform/home/presentation/widgets/sections/pwf_eservices_portal_section.dart"
$esChanges = Repair-EServices $eservicesPath $backupDir
foreach ($c in $esChanges) { $allChanges.Add("eServices: $c") }

$loginFiles = Find-LoginFiles
foreach ($lf in $loginFiles) {
  $loginChanges = Repair-LoginOverflow $lf $backupDir
  foreach ($c in $loginChanges) { $allChanges.Add("login:$lf: $c") }
}

# Final ParentData candidate scan in touched areas.
$scan = New-Object System.Collections.Generic.List[string]
$scanTargets = New-Object System.Collections.Generic.List[string]
$scanTargets.Add($eservicesPath)
foreach ($lf in $loginFiles) { $scanTargets.Add($lf) }

foreach ($p in $scanTargets) {
  if (Test-Path $p) {
    $lineNo = 0
    foreach ($line in [System.IO.File]::ReadAllLines((Resolve-Path $p), [System.Text.Encoding]::UTF8)) {
      $lineNo += 1
      if ($line -match "Expanded\(|Flexible\(|Positioned\(") {
        $scan.Add(("{0}:{1}: {2}" -f $p, $lineNo, $line.Trim()))
      }
    }
  }
}

$report = @()
$report += "# PWF-SIS N2.66B Public Overflow Definitive Repair"
$report += ""
$report += "Generated: $(Get-Date -Format s)"
$report += ""
$report += "## Why"
$report += "N2.66A kept runtime overflow. The log still showed Offset(28,26), meaning the active card padding path was not changed."
$report += ""
$report += "## Target"
$report += "- $eservicesPath"
$report += ""
$report += "## Login files detected"
if ($loginFiles.Count -eq 0) {
  $report += "- none"
} else {
  foreach ($lf in $loginFiles) { $report += "- $lf" }
}
$report += ""
$report += "## Applied changes"
if ($allChanges.Count -eq 0) {
  $report += "- none automatically applied"
} else {
  foreach ($c in $allChanges) { $report += "- $c" }
}
$report += ""
$report += "## ParentData scan candidates after repair"
if ($scan.Count -eq 0) {
  $report += "- none"
} else {
  foreach ($s in $scan) { $report += "- $s" }
}
$report += ""
$report += "## Required retest"
$report += "- dart format ."
$report += "- flutter analyze"
$report += "- flutter run -d chrome"
$report += "- Browser: /"
$report += "- Browser: /login?from=/admin"
$report += "- Console clean: no RenderFlex overflow and no ParentDataWidget exception"

[System.IO.File]::WriteAllText((Join-Path $outDir "public_overflow_definitive_repair_report.md"), ($report -join "`r`n"), $utf8NoBom)

Write-Host "PWF-SIS N2.66B applied."
Write-Host "Report:"
Write-Host " - $outDir\public_overflow_definitive_repair_report.md"
Write-Host "Run next:"
Write-Host "dart format ."
Write-Host "flutter analyze"
Write-Host "flutter run -d chrome"
