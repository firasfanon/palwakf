
# MEDIA_CENTER_MOBILE_APPLICATION_OWNER_SCHEMA_PUBLIC_API_EDGE_MVP

## Nature

Flutter mobile application MVP for the Media Center.

## Route

```text
/app/media-center
```

This route is standalone and does not use the public web shell.

## Scope

```text
news
announcements
activities
mobile-first cards
bottom navigation
pull-to-refresh
search
detail bottom sheet
API edge runtime logs
```

## Data Contract

```text
media_center = source of truth
public.v_media_news_compat_v1 = API edge only
public.v_media_announcements_compat_v1 = API edge only
public.v_media_activities_compat_v1 = API edge only
```

## Not included

```text
No SQL apply
No public base tables
No owner schema migration to public
No media-gallery public auto-publish
No service_role
No production approval
```

## Runtime checks

```bash
flutter analyze
flutter test test/core/contracts/cms_payload_contracts_test.dart
flutter run -d chrome --dart-define=PWF_ALLOW_LEGACY_PUBLIC_MEDIA_BASE_FALLBACK=false
flutter run -d android --dart-define=PWF_ALLOW_LEGACY_PUBLIC_MEDIA_BASE_FALLBACK=false
```

Open:

```text
/app/media-center
```

Expected debug logs:

```text
PWF_MEDIA_CENTER_MOBILE_APP family=news owner_schema=media_center api_edge=public.v_media_news_compat_v1
PWF_MEDIA_CENTER_MOBILE_APP family=announcements owner_schema=media_center api_edge=public.v_media_announcements_compat_v1
PWF_MEDIA_CENTER_MOBILE_APP family=activities owner_schema=media_center api_edge=public.v_media_activities_compat_v1
```
