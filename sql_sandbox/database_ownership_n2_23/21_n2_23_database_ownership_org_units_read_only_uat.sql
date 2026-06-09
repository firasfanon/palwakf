-- Mega Batch N2.23 — Read-only UAT
-- Validates Wave 0 inventory governance and N2.21.1 org_units hotfix.
-- READ ONLY. No DML. No waqf/waqf_assets/awqaf_system mutation.

with view_def as (
  select view_definition
  from information_schema.views
  where table_schema = 'public'
    and table_name = 'org_units'
), col_type as (
  select data_type, udt_name, ordinal_position
  from information_schema.columns
  where table_schema = 'public'
    and table_name = 'org_units'
    and column_name = 'unit_type'
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
), inventory_exists as (
  select exists (
    select 1
    from information_schema.tables
    where table_schema = 'platform'
      and table_name = 'schema_inventory_decisions'
  ) as exists_value
), inventory_seed as (
  select count(*) as seed_count
  from platform.schema_inventory_decisions
  where batch_key = 'N2.23'
), cache_comments as (
  select
    obj_description('public.pwf_org_units_cache'::regclass) as pwf_cache_comment,
    obj_description('public.org_units_cache'::regclass) as org_cache_comment
)
select 'inventory' as section, 'schema_inventory_decisions_exists' as check_key,
  exists_value as passed,
  'platform.schema_inventory_decisions exists' as note
from inventory_exists
union all
select 'inventory', 'n2_23_seed_decisions_present',
  seed_count >= 5,
  'seed_count=' || seed_count
from inventory_seed
union all
select 'views', 'public_org_units_exists',
  exists(select 1 from view_def),
  'public.org_units compatibility view exists'
union all
select 'views', 'public_org_units_uses_core',
  exists(select 1 from view_def where view_definition ilike '%core.org_units%'),
  'public.org_units must read from core.org_units'
union all
select 'views', 'public_org_units_not_cache_backed',
  exists(select 1 from view_def where view_definition not ilike '%pwf_org_units_cache%' and view_definition not ilike '%org_units_cache%'),
  'public.org_units must not read from public org-unit caches'
union all
select 'views', 'public_org_units_unit_type_text_contract',
  exists(select 1 from col_type where data_type = 'text' and ordinal_position = 2),
  'public.org_units.unit_type must remain text at column 2 for compatibility'
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
select 'cache', 'org_unit_caches_marked_deprecated',
  coalesce(pwf_cache_comment, '') ilike '%Deprecated%' and coalesce(org_cache_comment, '') ilike '%Deprecated%',
  'Cache comments must mark public org unit caches as deprecated'
from cache_comments
union all
select 'sovereign_boundary', 'no_waq_assets_mutation_in_this_script', true,
  'Read-only UAT only; no waqf/waqf_assets/awqaf_system DML.';
