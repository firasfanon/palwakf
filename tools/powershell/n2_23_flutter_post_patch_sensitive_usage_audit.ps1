# N2.23 Flutter Post-Patch Sensitive Table Usage Audit
# Run from project root after applying source_patch.

$patterns = "\.from\('org_units'\)|\.from\('pwf_org_units_cache'\)|\.from\('org_units_cache'\)|\.from\('locations'\)|\.from\('platform_systems'\)|\.from\('platform_permissions'\)|\.from\('user_system_roles'\)|\.from\('user_system_permissions'\)|schema\('core'\)\.from\('org_units'\)"

Get-ChildItem -Path lib -Filter *.dart -Recurse |
  Select-String -Pattern $patterns -CaseSensitive:$false |
  Select-Object Path, LineNumber, Line |
  Export-Csv ".\n2_23_flutter_post_patch_sensitive_usage_audit.csv" -NoTypeInformation -Encoding UTF8

Write-Host "N2.23 sensitive usage audit written to n2_23_flutter_post_patch_sensitive_usage_audit.csv"
