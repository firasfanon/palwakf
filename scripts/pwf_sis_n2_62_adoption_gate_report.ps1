$ErrorActionPreference = "Stop"

$outDir = "baseline_control\pwf_sis_inventory_n2_62"

if (-not (Test-Path "$outDir\routes_inventory.csv")) {
  throw "Missing routes inventory. Run .\scripts\pwf_sis_n2_62_generate_inventory.ps1 first."
}

if (-not (Test-Path "$outDir\pages_inventory.csv")) {
  throw "Missing pages inventory. Run .\scripts\pwf_sis_n2_62_generate_inventory.ps1 first."
}

$routes = @(Import-Csv "$outDir\routes_inventory.csv")
$pages = @(Import-Csv "$outDir\pages_inventory.csv")

# PowerShell safety:
# Do not combine two pipelines inside a single array expression with commas.
# Some Windows PowerShell versions parse the second pipeline incorrectly.
$blockedRoutes = @($routes | Where-Object { $_.adoption_decision -eq "readiness-only-n2-67-no-migration" })
$blockedPages = @($pages | Where-Object { $_.adoption_decision -eq "readiness-only-n2-67-no-migration" })
$blocked = @($blockedRoutes) + @($blockedPages)

$manualRoutes = @($routes | Where-Object { $_.adoption_decision -eq "manual-review" })
$manualPages = @($pages | Where-Object { $_.adoption_decision -eq "manual-review" })
$manual = @($manualRoutes) + @($manualPages)

$lowRoutes = @($routes | Where-Object { $_.adoption_decision -eq "bulk-migrate-n2-63" })
$lowPages = @($pages | Where-Object { $_.adoption_decision -eq "bulk-migrate-n2-63" })

$mediumRoutes = @($routes | Where-Object { $_.adoption_decision -eq "migrate-by-low-risk-surface-n2-64-n2-65" })
$mediumPages = @($pages | Where-Object { $_.adoption_decision -eq "migrate-by-low-risk-surface-n2-64-n2-65" })

$publicRoutes = @($routes | Where-Object { $_.adoption_decision -eq "responsive-align-n2-66" })
$publicPages = @($pages | Where-Object { $_.adoption_decision -eq "responsive-align-n2-66" })

$report = @()
$report += "# PWF-SIS N2.62 Adoption Gate Report"
$report += ""
$report += "Generated: $(Get-Date -Format s)"
$report += ""
$report += "## Rule"
$report += "No high-risk route/page may be migrated automatically."
$report += ""
$report += "## Counts"
$report += ""
$report += "| Category | Routes | Pages | Decision |"
$report += "|---|---:|---:|---|"
$report += "| N2.63 low platform admin | $($lowRoutes.Count) | $($lowPages.Count) | allowed for bulk migration |"
$report += "| N2.64/N2.65 medium operational | $($mediumRoutes.Count) | $($mediumPages.Count) | family UAT required |"
$report += "| N2.66 public responsive | $($publicRoutes.Count) | $($publicPages.Count) | responsive alignment only |"
$report += "| N2.67 high-risk/readiness-only | $($blockedRoutes.Count) | $($blockedPages.Count) | migration blocked |"
$report += "| Manual review | $($manualRoutes.Count) | $($manualPages.Count) | manual classification required |"
$report += ""
$report += "## Decision"
$report += "N2.63 may migrate only `bulk-migrate-n2-63` items."
$report += "N2.64/N2.65 may migrate medium operational items only after family-specific UAT."
$report += "N2.67 high-risk items are readiness-only and must not be migrated automatically."
$report += ""
$report += "## Generated files"
$report += "- routes_inventory.csv"
$report += "- pages_inventory.csv"
$report += "- inventory_summary.md"
$report += "- adoption_gate_report.md"

Set-Content -Path "$outDir\adoption_gate_report.md" -Value ($report -join "`r`n") -Encoding UTF8

$blocked | Export-Csv -Path "$outDir\blocked_readiness_only_items.csv" -NoTypeInformation -Encoding UTF8
$manual | Export-Csv -Path "$outDir\manual_review_items.csv" -NoTypeInformation -Encoding UTF8
$lowRoutes | Export-Csv -Path "$outDir\n2_63_candidate_routes.csv" -NoTypeInformation -Encoding UTF8
$lowPages | Export-Csv -Path "$outDir\n2_63_candidate_pages.csv" -NoTypeInformation -Encoding UTF8

Write-Host "PWF-SIS N2.62A adoption gate report generated:"
Write-Host " - $outDir\adoption_gate_report.md"
Write-Host " - $outDir\blocked_readiness_only_items.csv"
Write-Host " - $outDir\manual_review_items.csv"
Write-Host " - $outDir\n2_63_candidate_routes.csv"
Write-Host " - $outDir\n2_63_candidate_pages.csv"
