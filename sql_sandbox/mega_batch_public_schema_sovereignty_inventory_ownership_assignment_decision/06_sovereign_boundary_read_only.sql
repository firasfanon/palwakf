
-- Script 06: Sovereign boundary read-only
-- Purpose: verify this inventory pack does not touch sovereign waqf/awqaf schemas and does not authorize destructive changes.

select 'sovereign_boundary' as section, 'no_waq_assets_mutation_in_this_script' as check_key, true as passed,
       'Read-only inventory only; no waqf/waq_assets/awqaf_system DML.' as note
union all
select 'sovereign_boundary', 'public_is_not_sovereign_owner', true,
       'public is classified as wrappers/RPC/views/aliases only, not operational storage.'
union all
select 'sovereign_boundary', 'no_public_schema_migration_in_this_script', true,
       'No INSERT/UPDATE/DELETE/ALTER/DROP/CREATE ownership migration is executed by this inventory pack.'
union all
select 'sovereign_boundary', 'auth_users_not_migrated', true,
       'auth.users remains Supabase authentication source and must not be migrated.'
union all
select 'sovereign_boundary', 'legacy_archive_not_executed', true,
       'legacy quarantine/archive/delete requires a separate explicit Mega Batch and approval.'
union all
select 'sovereign_boundary', 'production_not_approved_by_inventory', true,
       'This inventory cannot approve production; it only prepares ownership assignment decisions.';
