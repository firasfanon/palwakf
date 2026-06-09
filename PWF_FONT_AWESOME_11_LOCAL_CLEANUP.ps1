# PalWakf FontAwesome 11 / Flutter IconData final-class cleanup
# Run from project root after applying this hotfix.
Write-Host "PWF_FONT_AWESOME_11_CLEANUP starting..." -ForegroundColor Cyan
if (Test-Path pubspec.lock) {
  Remove-Item pubspec.lock -Force
  Write-Host "Removed stale pubspec.lock so font_awesome_flutter can resolve to 11.x." -ForegroundColor Yellow
}
flutter clean
flutter pub get
flutter pub upgrade font_awesome_flutter
flutter analyze
flutter run -d chrome
