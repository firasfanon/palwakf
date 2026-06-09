-- Mega Batch: Public Schema Controlled Ownership Migration + Compatibility Wrappers
-- Script 01: pre-migration contract guard, read-only.
-- Purpose: verify the target schemas can exist and the public source tables are only inspected here.

with target_schemas(schema_name, intended_role) as (
  values
    ('platform', 'platform shell/settings/access owner'),
    ('core', 'user/admin/org linkage owner; auth.users remains auth source'),
    ('assistant', 'assistant/chat owner'),
    ('public', 'compatibility wrappers/RPC/views/aliases only')
), schema_presence as (
  select
    s.schema_name,
    s.intended_role,
    exists(select 1 from information_schema.schemata i where i.schema_name = s.schema_name) as present
  from target_schemas s
), migration_candidates(target_schema, source_table, migration_group, required_guard) as (
  values
    ('platform','app_settings','platform_shell','platform table shadow migration only'),
    ('platform','footer_settings','platform_shell','platform table shadow migration only'),
    ('platform','header_settings','platform_shell','platform table shadow migration only'),
    ('platform','homepage_sections','platform_shell','platform table shadow migration only'),
    ('platform','site_pages','platform_shell','platform table shadow migration only'),
    ('platform','site_settings','platform_shell','platform table shadow migration only'),
    ('platform','home_config','platform_shell','platform table shadow migration only'),
    ('platform','hero_slides','platform_shell','platform table shadow migration only'),
    ('platform','home_stats','platform_shell','platform table shadow migration only'),
    ('platform','home_services','platform_shell','platform table shadow migration only'),
    ('platform','home_hero_slides','platform_shell','platform table shadow migration only'),
    ('platform','breaking_news','platform_shell','platform table shadow migration only'),
    ('platform','platform_permissions','platform_access','platform access registry shadow migration only'),
    ('platform','platform_systems','platform_access','platform system registry shadow migration only'),
    ('platform','user_permissions','platform_access','platform access/RBAC shadow migration only'),
    ('platform','user_system_permissions','platform_access','platform access/RBAC shadow migration only'),
    ('platform','user_system_roles','platform_access','platform access/RBAC shadow migration only'),
    ('core','admin_users','core_identity_linkage','auth-linked administrative user profile shadow migration only'),
    ('core','user_accounts','core_identity_linkage','user account/profile shadow migration only'),
    ('core','org_units_cache','core_org_linkage','deprecated cache shadow migration only'),
    ('core','pwf_org_units_cache','core_org_linkage','deprecated cache shadow migration only'),
    ('assistant','assistant_conversations','assistant','assistant owner shadow migration only'),
    ('assistant','assistant_messages','assistant','assistant owner shadow migration only'),
    ('assistant','chatbot_conversations','assistant','assistant owner shadow migration only'),
    ('assistant','chatbot_messages','assistant','assistant owner shadow migration only'),
    ('assistant','chatbot_intents','assistant','assistant owner shadow migration only'),
    ('assistant','chatbot_retention_policies','assistant','assistant owner shadow migration only')
)
select
  'pre_migration_schema_presence' as section,
  schema_name as contract_name,
  present,
  intended_role as note
from schema_presence
union all
select
  'pre_migration_candidate_presence' as section,
  'public.' || source_table as contract_name,
  to_regclass('public.' || source_table) is not null as present,
  target_schema || ' / ' || migration_group || ' / ' || required_guard as note
from migration_candidates
order by section, contract_name;
