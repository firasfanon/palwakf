
# Media Center Mobile Offline Drafts — Route Type Decoupling Analyzer Hotfix

## Evidence

The Android build script stopped at `flutter analyze` with the same three errors:

```text
MediaCenterLocalDraft isn't defined in common_routes_group.dart
MediaCenterLocalDraft isn't a type in common_routes_group.dart
labelAr isn't defined for MediaPublishingContentType
```

## Stronger Fix

Instead of requiring `common_routes_group.dart` to know `MediaCenterLocalDraft`, the route now passes `state.extra` as `Object?`:

```dart
MediaCenterQuickPublishPage(initialDraft: state.extra)
```

The actual type check is moved into:

```text
lib/features/media_center_mobile/presentation/pages/media_center_quick_publish_page.dart
```

where `MediaCenterLocalDraft` is already in feature scope and can be imported normally.

## labelAr Fix

The local drafts page no longer depends on the extension getter. It uses a local helper:

```dart
String _contentTypeLabel(MediaPublishingContentType type)
```

## Changed Files

```text
lib/app/routing/route_groups/common_routes_group.dart
lib/features/media_center_mobile/presentation/pages/media_center_quick_publish_page.dart
lib/features/media_center_mobile/presentation/pages/media_center_local_drafts_page.dart
```

## Boundaries

```text
no SQL
no Gradle changes
no public base tables
no service_role
no production approval
```

## Retest

```powershell
.\scripts\build_media_center_android_debug.ps1
```
