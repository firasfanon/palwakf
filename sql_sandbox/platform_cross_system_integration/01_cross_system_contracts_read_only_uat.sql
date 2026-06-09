-- Mega Batch E — Cross-System Integration Around Approved Contracts
-- Read-only UAT. No DDL/DML. No waqf_assets mutation.

with contract_matrix as (
  select * from (values
    ('awqaf_system', 'waqf_asset_id', 'integration-intake only', 'awqaf_system owns waqf_assets workflow'),
    ('document_intelligence', 'document_id + candidate waqf_asset_id', 'evidence/reference linking', 'defer sovereign linking until approved asset contract'),
    ('cases', 'waqf_asset_id', 'case references', 'case privacy/RBAC required'),
    ('tasks', 'waqf_asset_id / case_id / document_id', 'follow-up references', 'task closure is not sovereign approval'),
    ('billing_system', 'waqf_asset_id + ledger/account reference', 'financial reference only', 'compliance/provider readiness required'),
    ('assistant', 'citations + scoped references', 'knowledge/reference only', 'no sovereign data mutation'),
    ('mustakshif', 'spatial feature reference + waqf_asset_id', 'read-only spatial analysis', 'not master data')
  ) as t(system_key, anchor_field, platform_mode, governing_rule)
)
select
  'cross_system_contract_matrix' as section,
  system_key,
  anchor_field,
  platform_mode,
  governing_rule
from contract_matrix
order by system_key;

select
  'waqf_assets_do_not_mutate_guard' as section,
  'platform must not create/update/approve waqf_assets or parcel links' as rule,
  'manual/static verification required: inspect changed files and SQL for DML/DDL' as verification_note;

select
  'contract_columns_probe' as section,
  table_schema,
  table_name,
  column_name
from information_schema.columns
where (table_schema, table_name, column_name) in (
  ('waqf', 'waqf_assets', 'id'),
  ('waqf', 'waqf_assets', 'approval_status'),
  ('waqf', 'waqf_assets', 'public_visibility'),
  ('waqf', 'waqf_asset_review_events', 'id'),
  ('public', 'services', 'id'),
  ('public', 'homepage_sections', 'section_name')
)
order by table_schema, table_name, column_name;
