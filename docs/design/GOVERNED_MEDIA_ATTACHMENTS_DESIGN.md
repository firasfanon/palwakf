# Governed Media Attachments Design

## Decision

Attachments must not be added as quick columns to legacy/public content tables. They should be managed through a governed attachment registry.

## Recommended Owner Surface

```text
media_center.content_assets
```

## Design Goals

- Separate content records from file metadata.
- Support multiple attachments per content item.
- Audit attachment link/unlink operations.
- Preserve compatibility views for public reads.
- Avoid ad-hoc public table expansion.

## Proposed Attachment Registry

### Logical Fields

| Field | Purpose |
|---|---|
| `id` | Attachment technical key |
| `content_type` | news, announcement, activity, event |
| `content_id` | Target content record |
| `storage_path` | Supabase storage path |
| `file_name` | Original file name |
| `mime_type` | File MIME type |
| `file_size` | Size in bytes |
| `checksum` | Optional integrity hash |
| `unit_id` | Scope/ownership |
| `uploaded_by` | Admin user |
| `created_at` | Audit timestamp |
| `status` | active/archived/deleted |

## Permission Model

| Operation | Requirement |
|---|---|
| Upload | Authenticated admin with media permission |
| Link | Admin scoped to content unit |
| Unlink | Admin scoped to content unit + audit |
| Archive | Elevated permission |
| Public read | Only through published content wrappers |

## Audit Requirements

Each attachment operation should create an audit event:

- attachment_uploaded
- attachment_linked
- attachment_unlinked
- attachment_archived
- attachment_downloaded_admin

## Acceptance Criteria

- No `attachment_url` column added to public legacy tables.
- Attachments are linked through owner/governed schema.
- Public pages receive attachment URLs through safe views/RPC only.
- Audit events exist for attachment changes.
