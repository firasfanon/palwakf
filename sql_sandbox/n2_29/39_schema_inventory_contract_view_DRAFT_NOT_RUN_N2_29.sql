-- Mega Batch N2.29
-- DRAFT_NOT_RUN unless approved.
-- Creates a compatibility view over the real platform.schema_inventory_decisions contract.
-- This avoids future scripts using wrong column names such as schema_name/table_name.

create or replace view platform.v_schema_inventory_decisions_contract_v1 as
select
  id,
  batch_key,
  source_schema as schema_name,
  object_name as table_name,
  object_type,
  current_owner_system,
  recommended_owner_system,
  classification,
  decision,
  action_status,
  risk_level,
  dependency_status,
  rls_status,
  rpc_usage_status,
  flutter_usage_status,
  no_auto_drop,
  notes_ar,
  created_at,
  updated_at
from platform.schema_inventory_decisions;

comment on view platform.v_schema_inventory_decisions_contract_v1 is
  'Compatibility view for schema inventory decisions. Exposes schema_name/table_name aliases while preserving the real table contract source_schema/object_name.';

notify pgrst, 'reload schema';
