
# HOME_NEWS_MEDIA_EXPERIENCE_AND_HOMEPAGE_CHALLENGES_CLOSURE_MEGA_BATCH

## Scope

```text
/home
/home/news
/home/announcements
/home/activities
media-center read model
homepage overload
RTL/responsive behavior
news hero overflow risk
media-gallery governance awareness
```

## Frontend Changes Included

```text
1. NewsService now treats public base-table fallback as disabled by default.
2. Public v_media_* surfaces are logged as API edge, not source of truth.
3. Document Center now loads v_document_center_storage_objects_v1.
4. Document Center metrics include governed storage files.
5. Storage files show restricted/unassigned/mapping_required state.
```

## Runtime Retest

```bash
flutter analyze
flutter test test/core/contracts/cms_payload_contracts_test.dart
dart run tools/smoke/palwakf_smoke_suite.dart
flutter run -d chrome
```

Browser paths:

```text
/home
/home/news
/home/announcements
/home/activities
/admin/documents
/admin/media-center/news
```
