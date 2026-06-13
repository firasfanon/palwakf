
$ErrorActionPreference = "Stop"

$canonicalKotlin = "android\app\src\main\kotlin\com\example\waqf\MainActivity.kt"
$duplicateJava = "android\app\src\main\java\com\example\waqf\MainActivity.java"

if ((Test-Path $canonicalKotlin) -and (Test-Path $duplicateJava)) {
  Write-Host "Removing duplicate Android MainActivity Java source: $duplicateJava" -ForegroundColor Yellow
  Remove-Item $duplicateJava -Force
} else {
  Write-Host "No duplicate Android MainActivity cleanup needed." -ForegroundColor DarkGreen
}
