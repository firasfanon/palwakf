-- 04_SEED_initial_health_release_records.sql
-- Corrected version.
--
-- This script is safe in SQL Editor because it does not call authenticated public RPCs.
-- It directly upserts catalog-derived health checks after guarded metadata seeds.
-- Runtime users will still use rpc_platform_technical_health_snapshot_refresh_v1(),
-- which remains auth-protected.

begin;

insert into platform_technical.release_records (
  release_tag, git_commit_hash, flutter_version, dart_version,
  hosting_provider, deploy_url, status, notes
)
select
  'vercel-web-current',
  '8729fcd',
  'Flutter 3.44.1 stable',
  'Dart 3.12.1 stable',
  'vercel',
  'https://palwakf.vercel.app/#/home',
  'recorded',
  'Seeded from user-provided git log and environment evidence.'
where not exists (
  select 1 from platform_technical.release_records
  where release_tag = 'vercel-web-current'
);

insert into platform_technical.backup_registry (
  backup_kind, provider, backup_label, status, notes
)
select
  'database',
  'supabase',
  'Supabase/PostgreSQL backup policy placeholder',
  'recorded',
  'Metadata placeholder only; no backup export executed by this SQL.'
where not exists (
  select 1 from platform_technical.backup_registry
  where backup_label = 'Supabase/PostgreSQL backup policy placeholder'
);

with postgis_probe as (
  select n.nspname as extension_schema
  from pg_extension e
  join pg_namespace n on n.oid = e.extnamespace
  where e.extname = 'postgis'
),
health_seed as (
  select
    'postgis_extension_schema'::text as check_key,
    'database'::text as check_group,
    'PostGIS extension schema'::text as label,
    case
      when (select extension_schema from postgis_probe) = 'extensions'
      then 'healthy'
      else 'degraded'
    end::text as status,
    jsonb_build_object('schema', (select extension_schema from postgis_probe)) as details
  union all
  select
    'waqf_asset_detail_rpc',
    'rpc',
    'Waqf asset detail RPC',
    case
      when to_regprocedure('public.rpc_waqf_asset_detail_v1(uuid)') is not null
      then 'healthy'
      else 'blocked'
    end,
    jsonb_build_object('rpc','public.rpc_waqf_asset_detail_v1(uuid)')
  union all
  select
    'core_location_runtime_rpc',
    'rpc',
    'Core location runtime certification RPC',
    case
      when to_regprocedure('public.rpc_core_location_runtime_certification_v1()') is not null
      then 'healthy'
      else 'blocked'
    end,
    jsonb_build_object('rpc','public.rpc_core_location_runtime_certification_v1()')
  union all
  select
    'platform_role_permission_map',
    'rbac',
    'Platform role permission map',
    case
      when to_regclass('platform_access.platform_role_permission_map') is not null
      then 'healthy'
      else 'blocked'
    end,
    jsonb_build_object('table','platform_access.platform_role_permission_map')
)
insert into platform_technical.health_checks (
  check_key,
  check_group,
  label,
  status,
  details,
  last_checked_at,
  updated_at
)
select
  check_key,
  check_group,
  label,
  status,
  details,
  now(),
  now()
from health_seed
on conflict (check_key) do update
set
  status = excluded.status,
  details = excluded.details,
  last_checked_at = now(),
  updated_at = now();

insert into platform_technical.audit_events (
  event_type,
  actor_user_id,
  service_type,
  severity,
  message,
  payload
)
values (
  'technical_seed_health_snapshot_upserted',
  null,
  'health',
  'info',
  'Initial technical health snapshot upserted from SQL Editor seed script',
  jsonb_build_object(
    'auth_context_required', false,
    'runtime_refresh_rpc_still_auth_guarded', true
  )
);

commit;

select
  'platform_technical_seed_completed_sql_editor_safe' as section,
  true as release_seeded,
  true as backup_registry_placeholder_seeded,
  true as health_snapshot_upserted_without_authenticated_rpc,
  false as backup_export_executed,
  false as runtime_auth_weakened,
  false as production_approved;
