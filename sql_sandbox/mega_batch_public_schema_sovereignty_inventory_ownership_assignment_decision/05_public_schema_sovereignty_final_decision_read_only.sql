
-- Script 05: Final public schema sovereignty decision read-only
-- Purpose: emit one decision row. No migration is authorized here.

with inv as (
  select
    count(*) filter (where c.relkind = 'r') as public_tables,
    count(*) filter (where c.relkind = 'v') as public_views,
    count(*) filter (where c.relkind = 'm') as public_materialized_views,
    count(*) filter (where c.relkind = 'S') as public_sequences
  from pg_catalog.pg_class c
  join pg_catalog.pg_namespace n on n.oid = c.relnamespace
  where n.nspname = 'public'
), funcs as (
  select count(*) as public_functions
  from pg_catalog.pg_proc p
  join pg_catalog.pg_namespace n on n.oid = p.pronamespace
  where n.nspname = 'public'
)
select
  'public_schema_sovereignty_final_decision' as section,
  'PUBLIC_SCHEMA_SOVEREIGNTY_INVENTORY_COMPLETE_OWNERSHIP_ASSIGNMENT_DECISION_ONLY' as decision,
  jsonb_build_object(
    'public_tables', inv.public_tables,
    'public_views', inv.public_views,
    'public_materialized_views', inv.public_materialized_views,
    'public_sequences', inv.public_sequences,
    'public_functions', funcs.public_functions,
    'platform_pages_target_owner', 'platform',
    'users_profiles_target_owner', 'core',
    'access_rbac_target_owner', 'platform',
    'media_owner', 'media_center',
    'services_owner', 'platform_services',
    'zakat_owner', 'zakat',
    'billing_owner', 'billing_system',
    'public_role', 'wrappers_rpc_views_aliases_only',
    'next_action', 'controlled migration pack after explicit approval',
    'destructive_sql_authorized', false
  ) as decision_payload,
  'No migration, archive, delete, drop, ownership transfer, or Flutter runtime change is performed by this pack.' as note
from inv, funcs;
