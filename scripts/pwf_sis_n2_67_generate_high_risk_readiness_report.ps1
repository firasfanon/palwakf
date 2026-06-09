$ErrorActionPreference = "Stop"

# PWF-SIS N2.67 — High-risk systems readiness-only report.
# No source/runtime changes. No SQL. No Database Wave B. No waqf_assets mutation.

$outDir = "baseline_control\pwf_sis_n2_67"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$systems = @(
  @{ system_key = "awqaf_system"; classification = "high-risk-sovereign-domain"; decision = "readiness-only" },
  @{ system_key = "waqf_assets"; classification = "sovereign-source-of-truth"; decision = "readiness-only" },
  @{ system_key = "cases"; classification = "legal-workflow-sensitive"; decision = "readiness-only" },
  @{ system_key = "billing_system"; classification = "financial-sensitive"; decision = "readiness-only" },
  @{ system_key = "mustakshif_gis"; classification = "gis-performance-sensitive"; decision = "readiness-only" },
  @{ system_key = "nusuk_manasikuna"; classification = "external-public-service-sensitive"; decision = "readiness-only" },
  @{ system_key = "tasks"; classification = "workflow-operational"; decision = "readiness-only" },
  @{ system_key = "assistant"; classification = "knowledge-access-sensitive"; decision = "readiness-only" }
)

$csv = $systems | ForEach-Object {
  [pscustomobject]@{
    system_key = $_.system_key
    classification = $_.classification
    decision = $_.decision
    ui_migration_allowed = "false"
    sql_allowed = "false"
    database_wave_b_allowed = "false"
    production_approval_allowed = "false"
  }
}

$csv | Export-Csv -Path "$outDir\high_risk_readiness_only_report.csv" -NoTypeInformation -Encoding UTF8

$report = @()
$report += "# PWF-SIS N2.67 High-Risk Systems Readiness-Only Report"
$report += ""
$report += "Generated: $(Get-Date -Format s)"
$report += ""
$report += "## Decision"
$report += "High-risk systems are readiness-only. No UI migration is allowed in N2.67."
$report += ""
$report += "## Systems"
foreach ($s in $systems) {
  $report += "- $($s.system_key): $($s.classification) / $($s.decision)"
}
$report += ""
$report += "## Blocked"
$report += "- Runtime UI migration for high-risk systems."
$report += "- SQL execution."
$report += "- Database Wave B."
$report += "- Production approval."
$report += "- waqf_assets mutation."
$report += ""
$report += "## Carry-over blocker"
$report += "N2.66 browser runtime still has public eServices overflow and ParentDataWidget exceptions; repair via N2.66A before closing PWF-SIS adoption path."

Set-Content -Path "$outDir\high_risk_readiness_only_report.md" -Value ($report -join "`r`n") -Encoding UTF8

Write-Host "PWF-SIS N2.67 readiness-only report generated:"
Write-Host " - $outDir\high_risk_readiness_only_report.csv"
Write-Host " - $outDir\high_risk_readiness_only_report.md"
