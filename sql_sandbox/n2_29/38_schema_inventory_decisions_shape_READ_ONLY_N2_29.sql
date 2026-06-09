-- Mega Batch N2.29
-- Read-only shape discovery for platform.schema_inventory_decisions.
-- Purpose: prevent schema_name/table_name contract drift from recurring.

select
  column_name,
  data_type,
  ordinal_position,
  is_nullable,
  column_default
from information_schema.columns
where table_schema = 'platform'
  and table_name = 'schema_inventory_decisions'
order by ordinal_position;

select
  'schema_inventory_contract_shape' as section,
  'uses_source_schema_not_schema_name' as check_key,
  exists (
    select 1 from information_schema.columns
    where table_schema = 'platform'
      and table_name = 'schema_inventory_decisions'
      and column_name = 'source_schema'
  ) as passed,
  'Contract column must be source_schema.' as note
union all
select
  'schema_inventory_contract_shape',
  'uses_object_name_not_table_name',
  exists (
    select 1 from information_schema.columns
    where table_schema = 'platform'
      and table_name = 'schema_inventory_decisions'
      and column_name = 'object_name'
  ),
  'Contract column must be object_name.'
union all
select
  'schema_inventory_contract_shape',
  'notes_ar_exists',
  exists (
    select 1 from information_schema.columns
    where table_schema = 'platform'
      and table_name = 'schema_inventory_decisions'
      and column_name = 'notes_ar'
  ),
  'Arabic notes column exists.'
union all
select
  'sovereign_boundary',
  'no_waq_assets_mutation_in_this_script',
  true,
  'Read-only shape discovery only; no waqf/waqf_assets/awqaf_system DML.';
