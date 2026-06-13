
# Runbook

## Flutter/Web retest

```bash
flutter analyze
flutter test test/core/contracts/cms_payload_contracts_test.dart
flutter run -d chrome --dart-define=PWF_ALLOW_LEGACY_PUBLIC_MEDIA_BASE_FALLBACK=false
```

Open:

```text
/app/media
/app/media-center
/app/media-center/publish
```

## Android debug build

```powershell
.\scriptsuild_media_center_android_debug.ps1
```

Expected output:

```text
buildpp\outputslutter-apkpp-debug.apk
```

## SQL verification only

```text
sql_verification/media_center_official_first_mobile_operational_workflow_android_readiness/01_VERIFY_official_first_mobile_operational_readiness.sql
```

## Acceptance

```text
flutter analyze clean
cms tests passed
Chrome route /app/media works
Chrome route /app/media-center works
Chrome route /app/media-center/publish works
Android debug APK builds
SQL verification confirms mobile publishing RPCs
```
