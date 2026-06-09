-- Database Ownership Phase B — Media Center Mega Closure Pack
-- 01 — Master decision census. READ ONLY.
-- No DDL/DML/GRANT/DROP. No RPC calls. No waqf/auth/GIS mutation.

with expected_objects(section, object_ref, expected_kind, owner_decision, required_for_apply) as (
  values
    ('owner_schema'::text, 'media_center'::text, 'schema'::text, 'OWNER_SCHEMA_TARGET'::text, true),
    ('owner_table', 'media_center.content_items', 'table', 'CANONICAL_CONTENT_TARGET', true),
    ('owner_table', 'media_center.content_assets', 'table', 'CANONICAL_ASSET_TARGET', false),
    ('owner_table', 'media_center.editorial_events', 'table', 'AUDIT_TRACE_TARGET', false),
    ('owner_view', 'media_center.v_content_items_public_v1', 'view', 'OWNER_PUBLIC_READ_SURFACE', true),
    ('legacy_public_source', 'public.news_articles', 'table', 'LEGACY_SOURCE_PRESERVE_AND_SYNC', false),
    ('legacy_public_source', 'public.announcements', 'table', 'LEGACY_SOURCE_PRESERVE_AND_SYNC', false),
    ('legacy_public_source', 'public.activities', 'table', 'LEGACY_SOURCE_PRESERVE_AND_SYNC', false),
    ('legacy_public_source', 'public.breaking_news', 'table', 'LEGACY_SOURCE_DRAFT_ONLY_OPTIONAL', false),
    ('legacy_public_source', 'public.media_gallery_items', 'table', 'LEGACY_ASSET_SOURCE_PRESERVE', false),
    ('public_compat_surface', 'public.v_media_content_compat_v1', 'view', 'PUBLIC_COMPATIBILITY_SURFACE', true),
    ('public_compat_surface', 'public.v_media_news_compat_v1', 'view', 'PUBLIC_COMPATIBILITY_SURFACE', true),
    ('public_compat_surface', 'public.v_media_announcements_compat_v1', 'view', 'PUBLIC_COMPATIBILITY_SURFACE', true),
    ('public_compat_surface', 'public.v_media_activities_compat_v1', 'view', 'PUBLIC_COMPATIBILITY_SURFACE', true),
    ('public_compat_surface', 'public.v_media_gallery_compat_v1', 'view', 'PUBLIC_COMPATIBILITY_SURFACE', false)
), relation_inventory as (
  select
    eo.section,
    eo.object_ref,
    eo.expected_kind,
    eo.owner_decision,
    eo.required_for_apply,
    case
      when eo.expected_kind = 'schema' then exists(select 1 from information_schema.schemata s where s.schema_name = eo.object_ref)
      else to_regclass(eo.object_ref) is not null
    end as object_present,
    c.reltuples::bigint as estimated_rows,
    obj_description(c.oid) as object_comment
  from expected_objects eo
  left join pg_class c on c.oid = to_regclass(eo.object_ref)
), required_columns(relation_ref, column_name, purpose) as (
  values
    ('media_center.content_items'::text, 'id'::text, 'owner primary key'::text),
    ('media_center.content_items', 'legacy_source', 'idempotent legacy trace'),
    ('media_center.content_items', 'legacy_source_id', 'idempotent legacy trace'),
    ('media_center.content_items', 'content_key', 'stable compatibility key'),
    ('media_center.content_items', 'content_type', 'news/announcement/activity discriminator'),
    ('media_center.content_items', 'title_ar', 'Arabic title'),
    ('media_center.content_items', 'summary_ar', 'Arabic summary'),
    ('media_center.content_items', 'body_ar', 'Arabic body'),
    ('media_center.content_items', 'status', 'publication workflow state'),
    ('media_center.content_items', 'visibility_scope', 'public/internal exposure guard'),
    ('media_center.content_items', 'published_at', 'published ordering and visibility'),
    ('media_center.content_items', 'metadata', 'legacy payload trace'),
    ('media_center.content_items', 'source_public_table', 'legacy source trace')
), column_inventory as (
  select
    'owner_required_column'::text as section,
    rc.relation_ref || '.' || rc.column_name as object_ref,
    'column'::text as expected_kind,
    rc.purpose as owner_decision,
    true as required_for_apply,
    exists (
      select 1 from information_schema.columns c
      where c.table_schema = split_part(rc.relation_ref, '.', 1)
        and c.table_name = split_part(rc.relation_ref, '.', 2)
        and c.column_name = rc.column_name
    ) as object_present,
    null::bigint as estimated_rows,
    null::text as object_comment
  from required_columns rc
), source_shape as (
  select
    'legacy_source_column_profile'::text as section,
    table_schema || '.' || table_name || '.' || column_name as object_ref,
    'column'::text as expected_kind,
    data_type as owner_decision,
    false as required_for_apply,
    true as object_present,
    ordinal_position::bigint as estimated_rows,
    null::text as object_comment
  from information_schema.columns
  where table_schema = 'public'
    and table_name in ('news_articles','announcements','activities','breaking_news','media_gallery_items')
    and column_name in (
      'id','uuid','title','title_ar','title_en','headline_ar','headline_en','name_ar','name_en',
      'summary','summary_ar','summary_en','excerpt','excerpt_ar','description','description_ar','description_en',
      'body','body_ar','body_en','content','content_ar','content_en','category','category_key','type',
      'status','publish_status','is_published','published','is_active','active','published_at','publish_date','created_at','updated_at',
      'unit_id','unit_slug','image_url','thumbnail_url','cover_image_url'
    )
), public_runtime_functions as (
  select
    'public_compat_function'::text as section,
    n.nspname || '.' || p.proname || '(' || pg_get_function_arguments(p.oid) || ')' as object_ref,
    case p.prokind when 'f' then 'function' when 'p' then 'procedure' else p.prokind::text end as expected_kind,
    'PUBLIC_MEDIA_COMPATIBILITY_RPC_OR_HELPER'::text as owner_decision,
    false as required_for_apply,
    true as object_present,
    null::bigint as estimated_rows,
    null::text as object_comment
  from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace
  where n.nspname = 'public'
    and (p.proname ilike '%media%' or p.proname ilike '%news%' or p.proname ilike '%announcement%' or p.proname ilike '%activit%')
)
select
  'phase_b_media_master_census'::text as report_key,
  section,
  object_ref,
  expected_kind,
  owner_decision,
  required_for_apply,
  object_present,
  estimated_rows,
  object_comment,
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
from relation_inventory
union all
select 'phase_b_media_master_census', section, object_ref, expected_kind, owner_decision, required_for_apply, object_present, estimated_rows, object_comment, false, false, false, false, false, true, true, true, true, true
from column_inventory
union all
select 'phase_b_media_master_census', section, object_ref, expected_kind, owner_decision, required_for_apply, object_present, estimated_rows, object_comment, false, false, false, false, false, true, true, true, true, true
from source_shape
union all
select 'phase_b_media_master_census', section, object_ref, expected_kind, owner_decision, required_for_apply, object_present, estimated_rows, object_comment, false, false, false, false, false, true, true, true, true, true
from public_runtime_functions
order by section, object_ref;
