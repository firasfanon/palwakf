
-- FILE_CENTER_UNIT_AWARE_ORG_UNITS_SCHEMA_SAFE_HOTFIX
-- READ ONLY unit-aware inventory.
--
-- Hotfix:
-- Do not reference optional core.org_units columns directly.
-- The previous diagnostic referenced core.org_units.type and failed when the column was absent.
--
-- No writes.

select
  'storage_object_counts_by_bucket' as section,
  bucket_id,
  count(*)::bigint as object_count
from storage.objects
where bucket_id in ('media-gallery', 'document-intelligence')
group by bucket_id
order by bucket_id;

select
  'storage_objects_sample_for_unit_review' as section,
  o.id,
  o.bucket_id,
  o.name,
  o.owner,
  o.created_at,
  o.updated_at,
  o.metadata
from storage.objects o
where o.bucket_id in ('media-gallery', 'document-intelligence')
order by o.bucket_id, o.created_at
limit 50;

select
  'administrative_unit_authority_presence' as section,
  to_regclass('core.org_units') as core_org_units,
  to_regclass('core.governorates') as core_governorates,
  to_regclass('platform_access.admin_users') as platform_admin_users;

select
  'core_org_units_columns' as section,
  column_name,
  data_type,
  is_nullable
from information_schema.columns
where table_schema = 'core'
  and table_name = 'org_units'
order by ordinal_position;

select
  'org_units_schema_safe_sample' as section,
  ou.id,
  to_jsonb(ou)->>'name_ar' as name_ar,
  to_jsonb(ou)->>'name' as name,
  to_jsonb(ou)->>'slug' as slug,
  to_jsonb(ou)->>'unit_type' as unit_type,
  to_jsonb(ou)->>'type' as legacy_type_if_present,
  to_jsonb(ou)->>'active' as active_if_present,
  to_jsonb(ou) as raw_org_unit
from core.org_units ou
order by coalesce(to_jsonb(ou)->>'name_ar', to_jsonb(ou)->>'name', ou.id::text)
limit 25;

select
  'existing_file_object_registry_unit_columns' as section,
  column_name,
  data_type,
  is_nullable
from information_schema.columns
where table_schema = 'platform_documents'
  and table_name = 'file_object_registry'
  and column_name in (
    'owner_unit_id',
    'governorate_code',
    'scope_type',
    'scope_id',
    'visibility_scope',
    'unit_assignment_status',
    'unit_assignment_reason',
    'assigned_by',
    'assigned_at'
  )
order by ordinal_position;
