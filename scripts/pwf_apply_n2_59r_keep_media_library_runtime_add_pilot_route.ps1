$ErrorActionPreference = "Stop"

function Write-FileUtf8($Path, $Text) {
  $dir = Split-Path -Parent $Path
  if ($dir -and -not (Test-Path $dir)) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
  }
  Set-Content -Path $Path -Value $Text -Encoding UTF8
}

# 1) Restore Media Library operational route if N2.56/N2.59 modified it into read-only pilot.
$mediaPath = "lib/features/platform/media_center/presentation/pages/media_center_operational_pages.dart"
if (Test-Path $mediaPath) {
  $text = Get-Content -Raw -Encoding UTF8 $mediaPath

  $pattern = 'class\s+MediaCenterMediaLibraryOperationalPage\s+extends\s+StatelessWidget\s*\{.*?\r?\n\}\s*\r?\n\s*class\s+MediaCenterSanctitiesObservatoryOperationalPage'

  $replacement = @'
class MediaCenterMediaLibraryOperationalPage extends StatelessWidget {
  const MediaCenterMediaLibraryOperationalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MediaCenterCompletedOperationalPage(
      currentRoute: AppRoutes.adminMediaCenterMediaLibrary,
      governanceFamilyKey: 'media_library',
      title: 'مكتبة المواد الإعلامية',
      subtitle:
          'أصول رسمية مثل الشعار، القوالب، الصور المعتمدة، والكتيبات الإعلامية.',
      icon: Icons.folder_special_outlined,
      primaryLabel: 'إضافة مادة إعلامية',
      previewRoute: AppRoutes.mediaCenter,
      bullets: [
        'حفظ مواد الهوية الإعلامية والأصول البصرية الرسمية.',
        'ربط الملفات بمركز الوثائق عند الحاجة دون نسخ عشوائي.',
        'إتاحة التحميل حسب الصلاحية والنطاق.',
      ],
    );
  }
}

class MediaCenterSanctitiesObservatoryOperationalPage
'@

  $matches = [regex]::Matches($text, $pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
  if ($matches.Count -eq 1) {
    $text = [regex]::Replace(
      $text,
      $pattern,
      $replacement,
      [System.Text.RegularExpressions.RegexOptions]::Singleline
    )
    Set-Content -Path $mediaPath -Value $text -Encoding UTF8
    Write-Host "Restored operational Media Library route in $mediaPath"
  } else {
    Write-Host "Media Library operational block not patched; expected 1 match, found $($matches.Count). Review manually if needed."
  }
} else {
  Write-Host "Media Center operational file not found; skipping runtime restoration."
}

# 2) Copy pilot page from source_overlay if package was extracted into project root.
$pilotSource = "source_overlay/lib/features/platform_design_system/presentation/pages/pwf_sis_wave2_media_library_pilot_page.dart"
$pilotTarget = "lib/features/platform_design_system/presentation/pages/pwf_sis_wave2_media_library_pilot_page.dart"
if (Test-Path $pilotSource) {
  $dir = Split-Path -Parent $pilotTarget
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  Copy-Item $pilotSource $pilotTarget -Force
  Write-Host "Copied separate pilot page to $pilotTarget"
} elseif (-not (Test-Path $pilotTarget)) {
  throw "Pilot page source not found and target page does not exist: $pilotTarget"
}

# 3) Patch PwfSisRoutes.
$routesPath = "lib/features/platform_design_system/presentation/routes/pwf_sis_routes.dart"
if (-not (Test-Path $routesPath)) {
  throw "Routes file not found: $routesPath"
}

$routes = Get-Content -Raw -Encoding UTF8 $routesPath

if ($routes -notmatch "pwf_sis_wave2_media_library_pilot_page.dart") {
  $routes = $routes -replace "(import '../pages/pwf_sis_wave2_media_inventory_page.dart';)", "`$1`r`nimport '../pages/pwf_sis_wave2_media_library_pilot_page.dart';"
}

if ($routes -notmatch "wave2MediaLibraryPilot") {
  $routes = $routes -replace "(static const wave2MediaInventory = PwfSisWave2MediaInventoryPage.routePath;)", "`$1`r`n  static const wave2MediaLibraryPilot = PwfSisWave2MediaLibraryPilotPage.routePath;"
}

if ($routes -notmatch "PwfSisWave2MediaLibraryPilotPage") {
  throw "Pilot page symbol missing after route import patch."
}

if ($routes -notmatch "builder: \(context, state\) => const PwfSisWave2MediaLibraryPilotPage\(\)") {
  $routes = $routes -replace "(GoRoute\(\s*path: wave2MediaInventory,\s*builder: \(context, state\) => const PwfSisWave2MediaInventoryPage\(\),\s*\),)", "`$1`r`n      GoRoute(`r`n        path: wave2MediaLibraryPilot,`r`n        builder: (context, state) => const PwfSisWave2MediaLibraryPilotPage(),`r`n      ),"
}

Set-Content -Path $routesPath -Value $routes -Encoding UTF8
Write-Host "Patched PwfSisRoutes with separate Media Library pilot route."

# 4) Patch AppRoutes constant if present.
$appRoutesPath = "lib/app/routing/app_routes.dart"
if (Test-Path $appRoutesPath) {
  $appRoutes = Get-Content -Raw -Encoding UTF8 $appRoutesPath
  if ($appRoutes -notmatch "adminDesignSystemWave2MediaLibraryPilot") {
    $appRoutes = $appRoutes -replace "(static const adminDesignSystemWave2MediaInventory\s*=\s*'\/admin\/platform\/design-system\/wave-2-media-inventory';)", "`$1`r`n  static const adminDesignSystemWave2MediaLibraryPilot =`r`n      '/admin/platform/design-system/wave-2/media-library-pilot';"
    Set-Content -Path $appRoutesPath -Value $appRoutes -Encoding UTF8
    Write-Host "Added AppRoutes.adminDesignSystemWave2MediaLibraryPilot."
  }
}

Write-Host "N2.59R applied. Run: dart format . ; flutter analyze ; flutter run -d chrome"
