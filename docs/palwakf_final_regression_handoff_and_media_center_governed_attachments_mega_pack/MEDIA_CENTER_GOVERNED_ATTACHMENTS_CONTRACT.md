
# Media Center Governed Attachments Contract

## Problem

Current CMS content can rely on loose attachment URL fields. This is weak for governance because it does not provide:

- attachment lifecycle
- ownership
- content link integrity
- audit trail
- attachment type validation
- storage object traceability
- rollback/depublish behavior

## Target Contract

Attachments become governed records linked to CMS/Media Center content.

## Proposed Owner Schema

```text
media_center
```

## Proposed Table

```text
media_center.content_attachments
```

## Logical Fields

| Column | Purpose |
|---|---|
| `id` | attachment record UUID |
| `content_table` | target content surface, e.g. `news_articles` |
| `content_id` | target content row id |
| `attachment_kind` | image/file/document/video/link |
| `storage_bucket` | Supabase storage bucket name, nullable for external link |
| `storage_path` | storage object path, nullable for external link |
| `external_url` | controlled external URL, nullable |
| `title_ar` | Arabic title |
| `title_en` | English title |
| `mime_type` | MIME type |
| `file_size_bytes` | file size |
| `display_order` | ordering |
| `is_primary` | primary attachment marker |
| `status` | draft/published/archived/deleted |
| `created_by` | admin user UUID |
| `created_at` | creation timestamp |
| `updated_at` | update timestamp |

## Contract Rules

1. One attachment record belongs to one content row.
2. Primary attachment must be unique per content item where applicable.
3. Internal storage references and external URLs are mutually controlled.
4. Published content may only expose attachments with `status = published`.
5. Admin writes must route through governed RPC or validated repository contract.
6. Public reads must use read-only wrappers/views.

## Non-Goals for First Apply

- No storage bucket policy mutation unless explicitly authorized.
- No migration of historical loose URLs unless separately authorized.
- No destructive cleanup of existing content.
