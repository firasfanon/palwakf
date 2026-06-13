
# Document Center Unification Architecture

## Existing Surfaces

| Surface | Role |
|---|---|
| `/admin/documents` | Unified portal |
| `/admin/document-intelligence` | Processing/OCR/review/linking |
| `platform_services.service_request_attachments` | Citizen service request attachments |
| `media_center.content_assets` | Public/media content assets |
| `storage.objects` | Physical object storage registry |

## Target Behavior

`/admin/documents` does not become a new storage silo.

It becomes a read/operations hub that resolves:

```text
document intelligence jobs
service request attachments
media center assets
```

into one governed document center view.

## Current Delivery in this Mega Batch

```text
Route screen replacement + read-only dashboard + governance drafts
```

## Future Apply

SQL apply for document type registry and retention columns requires explicit authorization.
