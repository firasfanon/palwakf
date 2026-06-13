
# Document Center Public Wrappers Applied + Runtime Retest Evidence Closure

## User-Supplied SQL Apply Evidence

| section | service_attachments_wrapper_present | media_assets_wrapper_present | service_attachments_authenticated_select | media_assets_authenticated_select | production_approved |
|---|---|---|---|---|---|
| document_center_public_wrappers_apply_result | true | true | true | true | false |

## User-Supplied Storage Verification

| section | bucket_id | object_count |
|---|---|---:|
| document_center_storage_counts | document-intelligence | 5 |
| document_center_storage_counts | media-gallery | 6 |

## Browser Runtime Evidence

### `/home/news`

Observed:

- Route loads.
- Network shows `v_media_news_compat_v1` = HTTP 200.
- Network shows `news_articles` = HTTP 200.
- News page renders article cards.
- No visible `RenderFlex`/unbounded height assertion in the provided post-hotfix screenshot.

### `/admin/documents`

Observed:

- Route loads.
- Header: `مركز الوثائق الموحّد`.
- Metrics visible:
  - total records = 7
  - document intelligence = 7
  - service attachments = 0
  - media assets = 0
  - long/legal references = 4
  - storage-linked = 0
- Latest documents list renders document-intelligence rows.
- No red `PGRST106` panel for `platform_services` or `media_center`.
- Console no longer shows direct owner-schema REST errors in the visible screenshot.

## Interpretation

The wrapper apply succeeded:

```text
public.v_document_center_service_attachments_v1 = present
public.v_document_center_media_assets_v1 = present
authenticated select = true
```

The runtime now degrades correctly:

- `/admin/documents` renders available `document-intelligence` data.
- Service/media counters can remain `0` if wrappers currently return no rows or if no matching governed data is linked yet.
- Owner schemas remain private.
- Flutter no longer directly reads owner schemas.

## Decision

```text
DOCUMENT_CENTER_PUBLIC_WRAPPERS_APPLIED_AND_RUNTIME_RETEST_PASSED
```

## Scope Boundary

```text
no RLS mutation
no data mutation
no service_role
production-not-approved
```
