
# Media Center Official-first Mobile Visual Contract Alignment Hotfix

## Evidence Intake

User supplied screenshots for:

```text
/home
/app/media-center
/app/media-center/publish
```

The runtime routes work after the previous hotfix, but the mobile media interfaces were visually inconsistent with the PalWakf platform contract.

## Problem

The mobile UI still looked like a raw Material prototype:

```text
default Material purple/disabled tones
weak PalWakf identity
unclear official-first publishing hierarchy
generic bottom navigation
generic cards and chips
employee/publisher/public surfaces visually under-differentiated
```

## Fix

Added a dedicated visual contract layer:

```text
lib/features/media_center_mobile/presentation/widgets/media_center_mobile_visual_contract.dart
```

Aligned the following pages:

```text
/app/media-center
/app/media-center/publish
/official/media/:family/:id
```

## Visual Rules Applied

```text
platform dark: #0B1220
platform gold: #D4AF37
platform blue: #0E3A6D
royal red: #B22222
RTL-first
official-first message prominent
public schema as API edge only
media_center as source of truth
clear employee sign-in barrier
clear official URL public interface
```

## No Backend Changes

```text
no SQL
no public base tables
no service_role
no RLS mutation
no storage mutation
no production approval
```

## Retest

```bash
flutter analyze
flutter test test/core/contracts/cms_payload_contracts_test.dart
flutter run -d chrome --dart-define=PWF_ALLOW_LEGACY_PUBLIC_MEDIA_BASE_FALLBACK=false
```

Open:

```text
/home
/app/media-center
/app/media-center/publish
/official/media/news/<published_uuid>
```
