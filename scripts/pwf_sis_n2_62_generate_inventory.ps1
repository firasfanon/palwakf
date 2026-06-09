$ErrorActionPreference = "Stop"

$root = Get-Location
$outDir = "baseline_control\pwf_sis_inventory_n2_62"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

function Get-RiskClass([string]$Path) {
  $p = $Path.ToLowerInvariant()
  if ($p -match "waqf_assets|awqaf_system|billing|cases|gis|map|mustakshif|nosok|nusuk|manasik") { return "high-risk-sovereign-or-domain" }
  if ($p -match "media-center|platform_content|services|service-center") { return "medium-operational" }
  if ($p -match "design-system|dynamic_systems|system_registry|database_migration|operations|usage|guide") { return "low-platform-admin" }
  if ($p -match "public|home|about|contact") { return "public-responsive" }
  return "unclassified-review"
}

function Get-AdoptionDecision([string]$Risk) {
  switch ($Risk) {
    "low-platform-admin" { return "bulk-migrate-n2-63" }
    "medium-operational" { return "migrate-by-low-risk-surface-n2-64-n2-65" }
    "public-responsive" { return "responsive-align-n2-66" }
    "high-risk-sovereign-or-domain" { return "readiness-only-n2-67-no-migration" }
    default { return "manual-review" }
  }
}

$routes = @()
$routeFiles = @(
  "lib\app\routing\go_router_config.dart",
  "lib\app\routing\app_routes.dart"
) + (Get-ChildItem -Path "lib" -Recurse -File -Include "*routes*.dart","*route*.dart" -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName })

$routeFiles = $routeFiles | Select-Object -Unique

foreach ($file in $routeFiles) {
  if (-not (Test-Path $file)) { continue }
  $text = Get-Content -Raw -Encoding UTF8 $file
  $matches = [regex]::Matches($text, "['""](/[^'""]+)['""]")
  foreach ($m in $matches) {
    $path = $m.Groups[1].Value
    if ($path.Length -lt 2) { continue }
    $risk = Get-RiskClass $path
    $routes += [pscustomobject]@{
      route_path = $path
      source_file = (Resolve-Path $file).Path.Replace($root.Path + "\", "")
      risk_class = $risk
      adoption_decision = Get-AdoptionDecision $risk
    }
  }
}

$pages = Get-ChildItem -Path "lib" -Recurse -File -Include "*page.dart","*_screen.dart","*_view.dart" -ErrorAction SilentlyContinue |
  ForEach-Object {
    $rel = $_.FullName.Replace($root.Path + "\", "")
    $risk = Get-RiskClass $rel
    [pscustomobject]@{
      file_path = $rel
      risk_class = $risk
      adoption_decision = Get-AdoptionDecision $risk
    }
  }

$routes | Sort-Object route_path, source_file -Unique |
  Export-Csv -Path "$outDir\routes_inventory.csv" -NoTypeInformation -Encoding UTF8

$pages | Sort-Object file_path |
  Export-Csv -Path "$outDir\pages_inventory.csv" -NoTypeInformation -Encoding UTF8

$summary = @()
$summary += "# PWF-SIS N2.62 Inventory Summary"
$summary += ""
$summary += "Generated: $(Get-Date -Format s)"
$summary += ""
$summary += "## Route counts by decision"
$routes | Group-Object adoption_decision | Sort-Object Name | ForEach-Object {
  $summary += "- $($_.Name): $($_.Count)"
}
$summary += ""
$summary += "## Page counts by decision"
$pages | Group-Object adoption_decision | Sort-Object Name | ForEach-Object {
  $summary += "- $($_.Name): $($_.Count)"
}

Set-Content -Path "$outDir\inventory_summary.md" -Value ($summary -join "`r`n") -Encoding UTF8

Write-Host "PWF-SIS N2.62 inventory generated under $outDir"
Write-Host "Files:"
Write-Host " - $outDir\routes_inventory.csv"
Write-Host " - $outDir\pages_inventory.csv"
Write-Host " - $outDir\inventory_summary.md"
