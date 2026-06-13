# CMS Payload Contracts

## Contract: News

Target:

```text
news_articles
```

Known access pattern:

```text
Direct Supabase REST table access
/rest/v1/news_articles
```

### Required Fields

| Field | Rule |
|---|---|
| `title` | Required |
| `content` | Required |
| `author` | Required; fallback: `إدارة المحتوى` |
| `status` | Must be normalized to supported DB status |
| `unit_id` | Required when scoped content is unit-specific |

### Optional Fields

| Field | Rule |
|---|---|
| `excerpt` | Optional |
| `category` | Optional, must match supported category taxonomy |
| `image_url` | Optional only if target table supports it |
| `tags` | Optional, must match expected DB type |

### Fields to Strip from Legacy Table Writes

| Field | Reason |
|---|---|
| `attachment_url` | Not present in current legacy table contract |
| `is_pinned` | Not guaranteed in current table contract |
| `sort_order` | Not guaranteed in current table contract |

## Contract: Announcements

Target:

```text
announcements
```

Known access pattern:

```text
Direct Supabase REST table access
/rest/v1/announcements
```

### Required Fields

| Field | Rule |
|---|---|
| `title` | Required |
| `content` | Required |
| `is_active` | Boolean |
| `unit_id` | Required when scoped |

### Fields to Strip

| Field | Reason |
|---|---|
| `attachment_url` | Not guaranteed in current table contract |
| `image_url` | Not guaranteed in current table contract |
| `is_featured` | Not guaranteed in current table contract |
| `is_pinned` | Not guaranteed in current table contract |
| `publish_at` | Not guaranteed in current table contract |
| `sort_order` | Not guaranteed in current table contract |

## Contract: Activities

Target:

```text
activities
```

### Required Fields

| Field | Rule |
|---|---|
| `title` | Required |
| `description` | Required |
| `start_date` | Required |
| `status` | Must match allowed state |

### Fields to Strip

| Field | Reason |
|---|---|
| `attachment_url` | Attachment handling must use governed media assets |
| `is_featured` | Not guaranteed |
| `is_pinned` | Not guaranteed |
| `publish_at` | Not guaranteed |
| `sort_order` | Not guaranteed |

## Implementation Note

The current compatibility helper should remain defensive and continue stripping unsupported optional fields until a governed owner-schema CMS write layer is fully adopted.
