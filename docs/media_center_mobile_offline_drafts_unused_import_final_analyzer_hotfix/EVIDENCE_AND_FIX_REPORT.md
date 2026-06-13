
# Media Center Mobile Offline Drafts — Final Analyzer Unused Import Hotfix

## Evidence

The latest `flutter analyze` reached a single remaining issue:

```text
warning - Unused import:
../../features/media_center_mobile/data/repositories/media_center_mobile_local_draft_store.dart
lib/app/routing/go_router_config.dart:89:8
```

## Root Cause

After the previous route type-decoupling hotfix, `common_routes_group.dart` no longer depends on `MediaCenterLocalDraft`.

Therefore, the parent import in:

```text
lib/app/routing/go_router_config.dart
```

became unnecessary.

## Fix

Removed this unused import:

```dart
import '../../features/media_center_mobile/data/repositories/media_center_mobile_local_draft_store.dart';
```

## Changed File

```text
lib/app/routing/go_router_config.dart
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
