# Error Record — Platform 12 Home Search + Sections Source

Date: 2026-06-13

## Error 1

### Symptom

Homepage search box did not return results.

### Cause

The active header search icon was wired to a temporary SnackBar only:

```text
البحث قيد الربط
```

No navigation and no query submission were performed.

### Files

```text
lib/features/platform/home/presentation/widgets/header/pwf_main_header.dart
lib/presentation/screens/public/search/search_screen.dart
lib/presentation/screens/public/search/web_search_screen.dart
lib/presentation/screens/public/search/mobile_search_screen.dart
lib/app/routing/route_groups/public_routes_group.dart
```

### Fix

Header search now navigates to scoped search routes with `q`. Search screens consume the initial query and run the search.

## Error 2

### Symptom

Homepage sections appeared duplicated or unclear in source.

### Cause

The unit-aware homepage sections repository method was reading from the legacy base table in its scoped path, despite the platform wrapper policy. It also merged section rows by raw normalized key, not canonical logical key.

### Files

```text
lib/data/repositories/homepage_repository.dart
```

### Fix

Runtime reads now use `v_platform_homepage_sections_compat_v1`, and merge keys canonicalize legacy aliases.

## Error 3

### Symptom

Admin sections manager could accidentally activate newly added official catalog sections.

### Cause

Missing official catalog keys were inserted into the draft model as active by default.

### Files

```text
lib/presentation/screens/admin/main/management/home_management/pwf_homepage_sections_manager.dart
```

### Fix

Missing catalog entries now default inactive except pinned shell rows.

## Last stable baseline before this patch

```text
media_center_mobile_session_handoff_updated_baseline_2026_06_13.zip
```

## New baseline after this patch

```text
platform12_home_search_sections_source_remediation_2026_06_13.zip
```
