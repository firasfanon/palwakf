# Platform Data Ownership Stabilization — Controlled Execution + Runtime Reroute UAT

**Date:** 2026-05-21

Run order in Supabase SQL Editor:

1. `01_pre_execution_guard_read_only.sql`
2. `02_media_assets_contract_extension_apply.sql`
3. `03_media_content_activity_normalization_apply.sql`
4. `04_gallery_asset_mapping_apply.sql`
5. `05_locations_compat_activation_apply.sql`
6. `06_public_media_compat_wrapper_refresh_apply.sql`
7. `07_post_execution_uat_read_only.sql`
8. `08_sovereign_boundary_read_only.sql`

Scope: controlled/idempotent execution only. No deletion of legacy public media tables. No waqf/waqf_assets/awqaf_system mutation. Public remains compatibility surface.
