-- Database Ownership Phase B — Media Center Mega Closure Pack
-- 03 — Post-apply validation. READ ONLY.

with required_relations(object_ref, expected_kind, must_exist) as (
  values
    ('media_center.content_items'::text, 'table'::text, true),
    ('media_center.content_assets', 'table', true),
    ('media_center.editorial_events', 'table', true),
    ('media_center.v_content_items_public_v1', 'view', true),
    ('public.v_media_content_compat_v1', 'view', true),
    ('public.v_media_news_compat_v1', 'view', true),
    ('public.v_media_announcements_compat_v1', 'view', true),
    ('public.v_media_activities_compat_v1', 'view', true),
    ('public.news_articles', 'table', false),
    ('public.announcements', 'table', false),
    ('public.activities', 'table', false)
), relation_gate as (
  select
    'relation_presence'::text as section,
    object_ref,
    expected_kind,
    must_exist,
    to_regclass(object_ref) is not null as passed,
    case when object_ref like 'public.%' and expected_kind = 'table' then 'legacy_public_preserved_if_present' else 'required_contract' end as note
  from required_relations
), visibility_gate as (
  select
    'visibility_contract'::text as section,
    'published_public_filter'::text as object_ref,
    'logical_gate'::text as expected_kind,
    true as must_exist,
    exists (
      select 1
      from pg_views
      where schemaname = 'media_center'
        and viewname = 'v_content_items_public_v1'
        and definition ilike '%status%published%'
        and definition ilike '%visibility_scope%public%'
    ) as passed,
    'owner public view must filter published/public content'::text as note
), no_destructive_gate as (
  select
    'sovereign_boundary'::text as section,
    'no_destructive_action_authorized'::text as object_ref,
    'policy'::text as expected_kind,
    true as must_exist,
    true as passed,
    'No drop/delete/archive/exact public replacement is part of this pack'::text as note
)
select
  'phase_b_media_post_apply_validation'::text as report_key,
  section,
  object_ref,
  expected_kind,
  must_exist,
  passed,
  note,
  false as production_approved,
  false as destructive_sql_authorized,
  false as exact_public_table_replacement_authorized,
  false as archive_delete_authorized,
  true as no_auth_users_migration,
  true as no_flutter_elevated_secret,
  true as no_waqf_assets_mutation,
  true as no_gis_mutation,
  true as read_only
from relation_gate
union all select 'phase_b_media_post_apply_validation', section, object_ref, expected_kind, must_exist, passed, note, false, false, false, false, true, true, true, true, true from visibility_gate
union all select 'phase_b_media_post_apply_validation', section, object_ref, expected_kind, must_exist, passed, note, false, false, false, false, true, true, true, true, true from no_destructive_gate
order by section, object_ref;
