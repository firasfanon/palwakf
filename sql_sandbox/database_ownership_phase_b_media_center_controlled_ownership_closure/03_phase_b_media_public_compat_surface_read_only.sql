-- Database Ownership Phase B — Media public compatibility surface. READ ONLY.

with relations as (
  select 'public.v_media_content_compat_v1'::text as object_ref, 'view'::text as expected_kind, 'generic public media compatibility view'::text as purpose
  union all select 'public.v_media_news_compat_v1', 'view', 'news list/detail compatibility view'
  union all select 'public.v_media_announcements_compat_v1', 'view', 'announcement list/detail compatibility view'
  union all select 'public.v_media_activities_compat_v1', 'view', 'activity compatibility view'
  union all select 'public.v_media_gallery_compat_v1', 'view', 'gallery compatibility view'
  union all select 'media_center.v_content_items_public_v1', 'view', 'owner-schema published public media view'
), funcs as (
  select
    'public.rpc_media_content_compat_v1'::text as object_ref,
    exists (
      select 1
      from pg_proc p
      join pg_namespace n on n.oid = p.pronamespace
      where n.nspname = 'public'
        and p.proname = 'rpc_media_content_compat_v1'
    ) as object_present,
    'public media content compatibility RPC'::text as purpose
)
select
  'phase_b_media_compat_surface'::text as section,
  r.object_ref,
  r.expected_kind,
  r.purpose,
  to_regclass(r.object_ref) is not null as object_present,
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
from relations r
union all
select
  'phase_b_media_compat_surface'::text,
  f.object_ref,
  'function'::text,
  f.purpose,
  f.object_present,
  false,
  false,
  false,
  false,
  false,
  true,
  true,
  true,
  true,
  true
from funcs f
order by object_ref;
