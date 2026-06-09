# N2.22 Flutter usage audit
# Run from PalWakf project root.

$patterns = @(
  "\.from\('org_units'\)",
  "\.from\('pwf_org_units_cache'\)",
  "\.from\('org_units_cache'\)",
  "\.from\('locations'\)",
  "\.from\('platform_systems'\)",
  "\.from\('platform_permissions'\)",
  "\.from\('user_system_roles'\)",
  "\.from\('user_system_permissions'\)",
  "\.from\('services'\)",
  "\.from\('documents'\)",
  "\.from\('waqf_lands'\)"
) -join "|"

Get-ChildItem -Path lib -Filter *.dart -Recurse |
  Select-String -Pattern $patterns -CaseSensitive:$false |
  Select-Object Path, LineNumber, Line |
  Export-Csv ".\n2_22_flutter_sensitive_table_usage_audit.csv" -NoTypeInformation -Encoding UTF8

Write-Host "Audit exported to n2_22_flutter_sensitive_table_usage_audit.csv"
