
# Public Interfaces

## Required public flow

```text
Social media should not be the primary publishing location.
Social media should share the official platform link.
```

## Public official detail route

```text
/official/media/:family/:id
```

Examples:

```text
/official/media/news/<content_item_uuid>
/official/media/announcements/<content_item_uuid>
/official/media/activities/<content_item_uuid>
```

## Public data rule

The public detail route reads via:

```text
public.rpc_media_center_public_content_detail_v1
```

This RPC returns only:

```text
status = published
visibility_scope = public
published_at <= now
```

So drafts and in-review content are not visible to the public.
