-- Database Ownership Phase B — Media Center Controlled Ownership Closure
-- 01 — Media inventory. READ ONLY.
-- No DDL/DML/GRANT/DROP. No waqf/auth/GIS mutation.

with objects as (
  select 'media_owner_schema'::text as section, 'media_center'::text as object_ref, 'schema'::text as expected_kind, 'owner source for media content'::text as purpose
  union all select 'legacy_public_media', 'public.news_articles', 'table', 'legacy news source to preserve until compatibility certified'
  union all select 'legacy_public_media', 'public.announcements', 'table', 'legacy announcements source to preserve until compatibility certified'
  union all select 'legacy_public_media', 'public.activities', 'table', 'legacy activities source to preserve until compatibility certified'
  union all select 'legacy_public_media', 'public.media_gallery_items', 'table', 'legacy gallery/media assets candidate; preserve until certified'
  union all select 'owner_media_tables', 'media_center.content_items', 'table', 'canonical media content owner table candidate'
  union all select 'owner_media_tables', 'media_center.content_assets', 'table', 'canonical media assets owner table candidate'
  union all select 'owner_media_views', 'media_center.v_content_items_public_v1', 'view', 'published public owner-schema read surface'
)
select
  'phase_b_media_inventory'::text as phase,
  section,
  object_ref,
  expected_kind,
  purpose,
  case
    when expected_kind = 'schema' then exists(select 1 from information_schema.schemata s where s.schema_name = object_ref)
    else to_regclass(object_ref) is not null
  end as object_present,
  false as execution_authorized,
  false as production_approved,
  false as destructive_sql_authorized,
  false as exact_public_table_replacement_authorized,
  false as archive_delete_authorized,
  true as no_auth_users_migration,
  true as no_flutter_elevated_secret,
  true as no_waqf_assets_mutation,
  true as no_gis_mutation,
  true as read_only
from objects
order by section, object_ref;
