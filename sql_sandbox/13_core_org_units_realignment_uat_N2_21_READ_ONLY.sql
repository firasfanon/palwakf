-- Mega Batch N2.21 — Core Org Units Wrapper Realignment UAT
-- READ ONLY evidence. Does not modify waqf, waqf_assets, awqaf_system.

with view_def as (
  select view_definition
  from information_schema.views
  where table_schema = 'public'
    and table_name = 'org_units'
), counts as (
  select
    (select count(*) from core.org_units) as core_count,
    (select count(*) from public.org_units) as public_count
), drift as (
  select count(*) as drift_count
  from (
    select id from core.org_units
    except
    select id from public.org_units
    union all
    select id from public.org_units
    except
    select id from core.org_units
  ) d
), rpc_exists as (
  select exists (
    select 1
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.proname = 'rpc_org_units_core_lookup_v1'
  ) as exists_value
)
select 'views' as section, 'public_org_units_exists' as check_key,
  exists(select 1 from view_def) as passed,
  'public.org_units compatibility view exists' as note
union all
select 'views', 'public_org_units_uses_core',
  exists(select 1 from view_def where view_definition ilike '%core.org_units%'),
  'public.org_units must read from core.org_units'
union all
select 'views', 'public_org_units_not_cache_backed',
  exists(select 1 from view_def where view_definition not ilike '%pwf_org_units_cache%' and view_definition not ilike '%org_units_cache%'),
  'public.org_units must not read from public org-unit caches'
union all
select 'data', 'core_public_org_units_counts_match',
  core_count = public_count,
  'core_count=' || core_count || '; public_count=' || public_count
from counts
union all
select 'data', 'core_public_org_units_id_drift_zero',
  drift_count = 0,
  'drift_count=' || drift_count
from drift
union all
select 'rpc', 'rpc_org_units_core_lookup_v1_exists',
  exists_value,
  'Core-backed lookup RPC exists'
from rpc_exists
union all
select 'sovereign_boundary', 'no_waq_assets_mutation_in_this_script', true,
  'Read-only UAT only; no waqf/waqf_assets/awqaf_system DML.';
