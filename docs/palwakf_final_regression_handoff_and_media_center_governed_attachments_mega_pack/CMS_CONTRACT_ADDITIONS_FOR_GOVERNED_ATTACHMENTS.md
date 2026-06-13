
# CMS Contract Additions for Governed Attachments

## Admin DTO Contract

A CMS write payload may include:

```json
{
  "title_ar": "...",
  "summary_ar": "...",
  "body_ar": "...",
  "status": "published",
  "attachments": [
    {
      "attachment_kind": "image",
      "storage_bucket": "media-center",
      "storage_path": "news/2026/example.jpg",
      "title_ar": "صورة الخبر",
      "is_primary": true,
      "status": "published"
    }
  ]
}
```

## Validation Rules

- `attachments` must be an array if present.
- Each attachment must have exactly one location mode:
  - internal storage: `storage_bucket + storage_path`
  - external link: `external_url`
- `attachment_kind` must be one of:
  - image
  - file
  - document
  - video
  - link
- `content_table` is server-owned, not client-trusted.
- `content_id` is assigned after content insert/update.
- Published public read exposes only `status = published` attachments.

## Repository Rule

Do not write attachments directly from Flutter to arbitrary tables without contract validation.

Preferred patterns:

1. Content save succeeds.
2. Attachments are upserted through governed RPC.
3. Public wrappers expose safe published attachment records.
