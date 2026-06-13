# Decision Record

```json
{
  "batch": "MEDIA_CENTER_OFFICIAL_FIRST_MOBILE_PUBLISHING_APP_MVP_MEGA_BATCH",
  "date": "2026_06_13",
  "idea": "Official-first mobile publishing app: publish to official platform first, then share official link on social media.",
  "routes": [
    "/app/media-center",
    "/app/media-center/publish",
    "/official/media/:family/:id"
  ],
  "workflows": {
    "normal_employee": "create draft -> submit for review",
    "trusted_publisher": "create draft -> publish now with audit",
    "public": "open official URL and share official link"
  },
  "sql_rpcs": [
    "public.rpc_media_center_mobile_create_draft_v1",
    "public.rpc_media_center_mobile_submit_for_review_v1",
    "public.rpc_media_center_mobile_publish_v1",
    "public.rpc_media_center_public_content_detail_v1"
  ],
  "owner_schema": "media_center",
  "public_schema_policy": "API edge only, not source of truth",
  "android_host_config": true,
  "boundaries": [
    "no public base tables",
    "no service_role",
    "no RLS mutation",
    "no storage.objects mutation",
    "no file deletion",
    "no media-gallery auto-publication",
    "production_not_approved"
  ],
  "status": "official-first-mobile-publishing-app-mvp-prepared / quick-compose-mobile-ui-prepared / draft-submit-publish-workflows-prepared / public-official-detail-interface-prepared / android-host-config-prepared / media-center-owner-schema-source-of-truth / public-api-edge-only / no-public-base-tables / no-service-role / production-not-approved / operator-apply-and-runtime-retest-pending"
}
```
