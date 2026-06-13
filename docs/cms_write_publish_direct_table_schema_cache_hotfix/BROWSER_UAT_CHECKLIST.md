# Browser UAT Checklist — CMS Write Schema Cache Hotfix

## Test 1 — Add News

1. Open `/admin/media-center/news`.
2. Open DevTools → Network → Fetch/XHR.
3. Enable Preserve log.
4. Click Add News.
5. Fill required fields only.
6. Click Save.
7. Verify the request target is `/rest/v1/news_articles`.

Expected:

```text
Status 201 / 200 / 204
No PGRST204 caused by attachment_url / is_pinned / sort_order
```

## Test 2 — Add Announcement

1. Open `/admin/media-center/announcements`.
2. Open DevTools → Network → Fetch/XHR.
3. Enable Preserve log.
4. Click Add Announcement.
5. Fill required fields only.
6. Click Save.
7. Verify the request target is `/rest/v1/announcements`.

Expected:

```text
Status 201 / 200 / 204
No PGRST204 caused by attachment_url / image_url / publish_at / is_featured / is_pinned / sort_order
```

## If a 400 remains

Click the failed request and capture:

```text
Headers
Payload
Response
```

Send the Response body to identify the next incompatible column or constraint.
