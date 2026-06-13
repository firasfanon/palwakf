
-- FILE_CENTER_STORAGE_MAPPING_UNIT_AWARE_SCOPE_BEFORE_APPLY
-- READ ONLY unit-aware inventory.
--
-- Purpose:
-- Confirm storage objects and available administrative unit authority before
-- applying neutral file-object registry mapping.
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
  'org_units_sample' as section,
  id,
  name_ar,
  slug,
  type,
  active
from core.org_units
order by name_ar
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
