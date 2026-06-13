
# Runbook

## Flutter retest

```bash
flutter analyze
flutter test test/core/contracts/cms_payload_contracts_test.dart
flutter run -d chrome --dart-define=PWF_ALLOW_LEGACY_PUBLIC_MEDIA_BASE_FALLBACK=false
```

## Routes

```text
/app/media
/app/media-center/publish
/app/media-center/drafts
```

## Manual test

```text
1. Open /app/media-center/publish.
2. Fill title, summary, body.
3. Press "حفظ على الهاتف".
4. Open /app/media-center/drafts.
5. Confirm the draft appears.
6. Press "متابعة التحرير".
7. Confirm fields are restored.
```

## Android

```powershell
.\scripts\build_media_center_android_debug.ps1
```
