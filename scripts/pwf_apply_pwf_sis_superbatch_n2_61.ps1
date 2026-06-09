$ErrorActionPreference = "Stop"

# PWF-SIS SuperBatch N2.61
# Applies N2.59R + N2.60/N2.61 route separation in one command.
# No SQL. No Database Wave B. No waq_assets mutation.

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
    Write-Host "Media Library runtime restored/confirmed: $mediaPath"
  } else {
    Write-Host "WARN: Media Library runtime block not replaced. Match count=$($matches.Count). If runtime is already operational, this may be OK."
  }
} else {
  Write-Host "WARN: Media Center operational file not found; runtime restoration skipped."
}

# Copy standalone pilot page.
$pilotSource = "source_overlay/lib/features/platform_design_system/presentation/pages/pwf_sis_wave2_media_library_pilot_page.dart"
$pilotTarget = "lib/features/platform_design_system/presentation/pages/pwf_sis_wave2_media_library_pilot_page.dart"

if (-not (Test-Path $pilotSource)) {
  throw "Pilot page source missing: $pilotSource"
}

$pilotDir = Split-Path -Parent $pilotTarget
if (-not (Test-Path $pilotDir)) {
  New-Item -ItemType Directory -Force -Path $pilotDir | Out-Null
}
Copy-Item $pilotSource $pilotTarget -Force
Write-Host "Pilot page copied: $pilotTarget"

# Patch PwfSisRoutes.
$routesPath = "lib/features/platform_design_system/presentation/routes/pwf_sis_routes.dart"
if (-not (Test-Path $routesPath)) {
  throw "Routes file not found: $routesPath"
}
$routes = Get-Content -Raw -Encoding UTF8 $routesPath

if ($routes -notmatch "pwf_sis_wave2_media_library_pilot_page.dart") {
  $routes = $routes -replace "((?:import [^\r\n]+;\r?\n)+)", "`$1import '../pages/pwf_sis_wave2_media_library_pilot_page.dart';`r`n"
}

if ($routes -notmatch "wave2MediaLibraryPilot") {
  $routes = $routes -replace "(class\s+PwfSisRoutes\s*\{\s*)", "`$1`r`n  static const wave2MediaLibraryPilot = PwfSisWave2MediaLibraryPilotPage.routePath;`r`n"
}

if ($routes -notmatch "PwfSisWave2MediaLibraryPilotPage\(\)") {
  $insert = @'
      GoRoute(
        path: wave2MediaLibraryPilot,
        builder: (context, state) => const PwfSisWave2MediaLibraryPilotPage(),
      ),

'@
  # Prefer inserting after wave2MediaInventory route if present, otherwise before the last closing bracket of routes list.
  $patternInventory = "(GoRoute\(\s*path:\s*wave2MediaInventory,\s*builder:\s*\(context,\s*state\)\s*=>\s*const\s*PwfSisWave2MediaInventoryPage\(\),\s*\),)"
  if ($routes -match $patternInventory) {
    $routes = [regex]::Replace($routes, $patternInventory, "`$1`r`n$insert", 1)
  } else {
    # Safer fallback: insert before first occurrence of '];' after route constants.
    $routes = $routes -replace "\r?\n\s*\];", "`r`n$insert`r`n  ];"
  }
}

Set-Content -Path $routesPath -Value $routes -Encoding UTF8
Write-Host "PwfSisRoutes patched with separate pilot route."

# Patch AppRoutes, if constant not present.
$appRoutesPath = "lib/app/routing/app_routes.dart"
if (Test-Path $appRoutesPath) {
  $appRoutes = Get-Content -Raw -Encoding UTF8 $appRoutesPath
  if ($appRoutes -notmatch "adminDesignSystemWave2MediaLibraryPilot") {
    $insertConst = "  static const adminDesignSystemWave2MediaLibraryPilot =`r`n      '/admin/platform/design-system/wave-2/media-library-pilot';"
    if ($appRoutes -match "adminDesignSystemWave2MediaInventory") {
      $appRoutes = $appRoutes -replace "(static const adminDesignSystemWave2MediaInventory[^\r\n]+;\s*)", "`$1`r`n$insertConst`r`n"
    } else {
      $appRoutes = $appRoutes -replace "(class\s+AppRoutes\s*\{\s*)", "`$1`r`n$insertConst`r`n"
    }
    Set-Content -Path $appRoutesPath -Value $appRoutes -Encoding UTF8
    Write-Host "AppRoutes patched with adminDesignSystemWave2MediaLibraryPilot."
  } else {
    Write-Host "AppRoutes pilot constant already exists."
  }
} else {
  Write-Host "WARN: AppRoutes file not found; skipping."
}

Write-Host "PWF-SIS SuperBatch N2.61 applied."
Write-Host "Run: dart format . ; flutter analyze ; flutter run -d chrome"
