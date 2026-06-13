
# Document Center SQL Schema-safe + News Hero Runtime Hotfix

## Evidence Intake

Accepted evidence showed:

- `storage.objects` has:
  - `document-intelligence = 5`
  - `media-gallery = 6`
- Document Center verification storage counts also returned:
  - `document-intelligence = 5`
  - `media-gallery = 6`
- SQL draft failed because `ca.status` does not exist on `media_center.content_assets`.
- Flutter analyzer passed.
- CMS contract tests passed.
- Smoke suite passed public media checks and skipped protected technical RPC without token.
- Browser runtime hit a `RenderFlex` unbounded constraint in `_NewsHeroCard`.

## Fixes

### SQL Draft Fix

Updated:

```text
sql_drafts/palwakf_document_center_unification_and_lifecycle_governance_mega_batch/03_DRAFT_unified_document_center_view.sql
```

Removed:

```text
coalesce(ca.status, 'active') as status
```

Replaced with:

```text
'active'::text as status
```

Also kept the media asset source bound to `content_item_id`, not an assumed `content_id`.

### Flutter Runtime Fix

Updated:

```text
lib/features/platform/home/presentation/screens/pages/pwf_news_pages.dart
```

Changed `_NewsHeroCard` so that:

- narrow layout uses `Column(mainAxisSize: MainAxisSize.min)` without `Expanded`.
- wide layout uses `Row` with `Expanded`.
- content column uses `mainAxisSize: MainAxisSize.min`.

## No Database Mutation

```text
no SQL apply
no RLS apply
no production approval
no service_role
```
