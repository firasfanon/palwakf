-- Mega Batch N2.29
-- Read-only UAT for schema inventory contract stabilization.

select
  'inventory_contract' as section,
  'schema_inventory_decisions_exists' as check_key,
  to_regclass('platform.schema_inventory_decisions') is not null as passed,
  'Inventory decision table must exist.' as note
union all
select
  'inventory_contract',
  'source_schema_column_exists',
  exists (select 1 from information_schema.columns where table_schema='platform' and table_name='schema_inventory_decisions' and column_name='source_schema'),
  'Use source_schema, not schema_name.'
union all
select
  'inventory_contract',
  'object_name_column_exists',
  exists (select 1 from information_schema.columns where table_schema='platform' and table_name='schema_inventory_decisions' and column_name='object_name'),
  'Use object_name, not table_name.'
union all
select
  'inventory_contract',
  'notes_ar_column_exists',
  exists (select 1 from information_schema.columns where table_schema='platform' and table_name='schema_inventory_decisions' and column_name='notes_ar'),
  'Use notes_ar for Arabic notes.'
union all
select
  'inventory_contract',
  'compatibility_view_optional',
  true,
  'If 39 is applied, platform.v_schema_inventory_decisions_contract_v1 should exist; if not, table contract still governs.'
union all
select
  'domain_program',
  'site_content_schema_exists',
  to_regnamespace('site_content') is not null,
  'site_content schema exists if N2.27 bootstrap draft was applied.'
union all
select
  'domain_program',
  'media_center_schema_exists',
  to_regnamespace('media_center') is not null,
  'media_center schema exists if N2.27 bootstrap draft was applied.'
union all
select
  'sovereign_boundary',
  'no_waq_assets_mutation_in_this_script',
  true,
  'Read-only UAT only; no waqf/waqf_assets/awqaf_system DML.';
