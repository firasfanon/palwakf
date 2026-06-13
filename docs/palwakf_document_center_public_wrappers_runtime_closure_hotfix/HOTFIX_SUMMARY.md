
# Document Center Public Wrappers Runtime Closure Hotfix

## Evidence

The `/admin/documents` page rendered, but Flutter attempted direct PostgREST reads from:

```text
platform_services.service_request_attachments
media_center.content_assets
```

Supabase returned:

```text
PGRST106
The schema must be one of the following...
```

This proves the owner schemas are not exposed to the REST API, which is correct from a governance standpoint.

The browser also still showed a News Hero runtime layout problem on `/home/news` caused by flex layout under unbounded height.

## Fix

### Flutter

- `DocumentCenterRepository` no longer reads owner schemas directly.
- It reads optional public wrappers:
  - `public.v_document_center_service_attachments_v1`
  - `public.v_document_center_media_assets_v1`
- If wrappers are not applied yet, it degrades to empty rows without PGRST106 surface errors.
- `document-intelligence` RPC remains active.

### News Hero

- Wide layout now has finite height via `SizedBox(height: 360)`.
- Content side is wrapped to avoid unbounded flex conflict.
- Author row no longer uses `Flexible` inside a min-size Row under Wrap.

### SQL

Added draft public wrapper views:

```text
04_DRAFT_public_document_center_wrappers.sql
```

No SQL apply was performed.

## Boundary

```text
no SQL apply
no RLS apply
no service_role
production-not-approved
```
