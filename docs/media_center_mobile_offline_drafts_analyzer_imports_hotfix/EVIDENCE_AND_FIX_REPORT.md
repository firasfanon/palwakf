
# Media Center Mobile Offline Drafts Analyzer Imports Hotfix

## Evidence

The Android build script correctly stopped at `flutter analyze`. The analyzer reported:

```text
MediaCenterLocalDraft isn't defined in common_routes_group.dart
MediaCenterLocalDraft isn't a type in common_routes_group.dart
labelAr isn't defined for MediaPublishingContentType in media_center_local_drafts_page.dart
```

## Root Cause

`common_routes_group.dart` is a `part of '../go_router_config.dart';` file.  
Therefore, type imports required by route builders must be imported in the parent library:

```text
lib/app/routing/go_router_config.dart
```

not inside the part file.

The `labelAr` getter is an extension declared in:

```text
media_center_publish_models.dart
```

and extension methods are only available when the declaring library is imported.

## Fix

Added to:

```text
lib/app/routing/go_router_config.dart
```

```dart
import '../../features/media_center_mobile/data/repositories/media_center_mobile_local_draft_store.dart';
```

Added to:

```text
lib/features/media_center_mobile/presentation/pages/media_center_local_drafts_page.dart
```

```dart
import '../../data/models/media_center_publish_models.dart';
```

## Scope

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
