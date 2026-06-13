
# Media Center Governed Attachments Smoke Plan

## Current Status

This is a smoke plan, not an executable mutation script.

## Checks

After an authorized apply:

1. Create or update a news article.
2. Add one governed attachment.
3. Verify table row exists in `media_center.content_attachments`.
4. Verify public wrapper exposes the attachment only when `status = published`.
5. Verify CMS Add News still returns HTTP 201/200/204.
6. Verify existing `palwakf_smoke_suite.dart` remains `passed=4 skipped=0 failed=0`.

## Protected Boundaries

- No service_role in Flutter.
- No direct broad table grants.
- Public read via wrapper only.
