
-- FILE_CENTER_STORAGE_MAPPING_UNIT_AWARE_SCOPE_BEFORE_APPLY
-- AUTHORIZED APPLY CANDIDATE
--
-- Purpose:
-- Create/update neutral file object registry with administrative-unit-aware
-- scoping before mapping existing storage objects.
--
-- Critical governance rules:
-- - Never infer an administrative unit from a file name.
-- - Never mark a storage-only object as broadly visible without evidence.
-- - Default mapping is restricted + unassigned.
-- - Later owner/unit mapping must be explicit and auditable.
--
-- Boundaries:
-- - No file deletion.
-- - No storage.objects mutation.
-- - No fake service_request_attachments insertion.
-- - No fake media_center.content_assets insertion.
-- - No RLS mutation.
-- - No service_role usage.
-- - No production approval.

begin;

create schema if not exists platform_documents;

create table if not exists platform_documents.file_object_registry (
  id uuid primary key default gen_random_uuid(),

  storage_bucket text not null,
  storage_path text not null,
  storage_object_id uuid null,

  source_surface text not null default 'storage.objects',
  source_system text not null,
  source_record_id uuid null,

  document_type_id uuid null references platform_documents.document_types(id),
  retention_class text not null
    check (retention_class in (
      'transient',
      'operational',
      'long_term_reference',
      'legal_evidence',
      'public_media'
    )),
  confidentiality_level text not null
    check (confidentiality_level in ('public', 'internal', 'confidential', 'restricted')),
  lifecycle_status text not null default 'active'
    check (lifecycle_status in ('active', 'archived', 'scheduled_for_delete', 'deleted')),

  title text null,
  mime_type text null,
  file_size_bytes bigint null check (file_size_bytes is null or file_size_bytes >= 0),
  checksum_sha256 text null,

  is_original boolean not null default true,
  is_storage_only boolean not null default true,
  mapping_status text not null default 'storage_only'
    check (mapping_status in (
      'storage_only',
      'mapped_to_owner_record',
      'mapping_required',
      'ignored'
    )),

  notes text null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  unique (storage_bucket, storage_path)
);

alter table platform_documents.file_object_registry
  add column if not exists owner_unit_id uuid null references core.org_units(id),
  add column if not exists governorate_code text null,
  add column if not exists scope_type text not null default 'storage_only'
    check (scope_type in (
      'storage_only',
      'platform',
      'ministry',
      'governorate',
      'unit',
      'service_request',
      'media_content',
      'waqf_asset',
      'case',
      'document_job',
      'unassigned'
    )),
  add column if not exists scope_id uuid null,
  add column if not exists visibility_scope text not null default 'restricted'
    check (visibility_scope in (
      'public',
      'internal',
      'unit',
      'governorate',
      'restricted'
    )),
  add column if not exists unit_assignment_status text not null default 'unassigned'
    check (unit_assignment_status in (
      'unassigned',
      'inferred_blocked',
      'explicitly_assigned',
      'mapped_from_owner_record',
      'requires_review'
    )),
  add column if not exists unit_assignment_reason text null,
  add column if not exists assigned_by uuid null references auth.users(id),
  add column if not exists assigned_at timestamptz null;

comment on table platform_documents.file_object_registry is
  'Neutral governed registry for Supabase storage objects. Unit-aware: files remain restricted/unassigned unless explicitly linked to an administrative scope.';

create index if not exists idx_file_object_registry_storage
  on platform_documents.file_object_registry(storage_bucket, storage_path);

create index if not exists idx_file_object_registry_lifecycle
  on platform_documents.file_object_registry(retention_class, lifecycle_status);

create index if not exists idx_file_object_registry_mapping_status
  on platform_documents.file_object_registry(mapping_status);

create index if not exists idx_file_object_registry_owner_unit
  on platform_documents.file_object_registry(owner_unit_id);

create index if not exists idx_file_object_registry_unit_assignment
  on platform_documents.file_object_registry(unit_assignment_status, visibility_scope);

create index if not exists idx_file_object_registry_scope
  on platform_documents.file_object_registry(scope_type, scope_id);

with object_rows as (
  select
    o.id as storage_object_id,
    o.bucket_id as storage_bucket,
    o.name as storage_path,
    o.created_at,
    o.updated_at,
    o.metadata,
    case
      when o.bucket_id = 'media-gallery' then 'media_center'
      when o.bucket_id = 'document-intelligence' then 'document_intelligence'
      else 'platform_documents'
    end as source_system,
    case
      when o.bucket_id = 'media-gallery' then 'MEDIA_ASSET_PUBLIC'
      when o.bucket_id = 'document-intelligence' then 'DOCUMENT_INTELLIGENCE_DERIVED'
      else 'SERVICE_ATTACHMENT_GENERAL'
    end as document_code,
    case
      when o.bucket_id = 'media-gallery' then 'public_media'
      else 'operational'
    end as fallback_retention_class,
    -- Even media-gallery is not automatically public at storage registry level
    -- unless it is mapped to a published media owner record.
    case
      when o.bucket_id = 'media-gallery' then 'internal'
      else 'internal'
    end as fallback_confidentiality_level
  from storage.objects o
  where o.bucket_id in ('media-gallery', 'document-intelligence')
),
mapped as (
  select
    obj.*,
    dt.id as document_type_id,
    coalesce(dt.retention_class, obj.fallback_retention_class) as retention_class,
    case
      when obj.storage_bucket = 'media-gallery' then 'internal'
      else coalesce(dt.confidentiality_level, obj.fallback_confidentiality_level)
    end as confidentiality_level,
    coalesce(
      obj.metadata ->> 'mimetype',
      obj.metadata ->> 'mimeType',
      obj.metadata ->> 'contentType'
    ) as mime_type,
    nullif(obj.metadata ->> 'size', '')::bigint as file_size_bytes
  from object_rows obj
  left join platform_documents.document_types dt
    on dt.system_key = obj.source_system
   and dt.document_code = obj.document_code
)
insert into platform_documents.file_object_registry (
  storage_bucket,
  storage_path,
  storage_object_id,
  source_surface,
  source_system,
  document_type_id,
  retention_class,
  confidentiality_level,
  lifecycle_status,
  title,
  mime_type,
  file_size_bytes,
  is_original,
  is_storage_only,
  mapping_status,
  owner_unit_id,
  governorate_code,
  scope_type,
  scope_id,
  visibility_scope,
  unit_assignment_status,
  unit_assignment_reason,
  notes,
  created_at,
  updated_at
)
select
  m.storage_bucket,
  m.storage_path,
  m.storage_object_id,
  'storage.objects',
  m.source_system,
  m.document_type_id,
  m.retention_class,
  m.confidentiality_level,
  'active',
  split_part(m.storage_path, '/', array_length(string_to_array(m.storage_path, '/'), 1)),
  m.mime_type,
  m.file_size_bytes,
  true,
  true,
  case
    when m.storage_bucket = 'media-gallery' then 'mapping_required'
    else 'storage_only'
  end,
  null::uuid as owner_unit_id,
  null::text as governorate_code,
  'storage_only'::text as scope_type,
  null::uuid as scope_id,
  'restricted'::text as visibility_scope,
  'unassigned'::text as unit_assignment_status,
  'No administrative unit was inferred from storage path. Explicit owner/unit mapping required.'::text,
  case
    when m.storage_bucket = 'media-gallery' then 'Imported from storage.objects; media owner/content mapping required before public/unit scope assignment.'
    when m.storage_bucket = 'document-intelligence' then 'Imported from storage.objects; document intelligence artifact/source file. Administrative scope remains unassigned pending source-job linkage.'
    else 'Imported from storage.objects.'
  end,
  coalesce(m.created_at, now()),
  coalesce(m.updated_at, now())
from mapped m
on conflict (storage_bucket, storage_path) do update
set
  storage_object_id = excluded.storage_object_id,
  document_type_id = coalesce(platform_documents.file_object_registry.document_type_id, excluded.document_type_id),
  retention_class = coalesce(platform_documents.file_object_registry.retention_class, excluded.retention_class),
  confidentiality_level = case
    when platform_documents.file_object_registry.unit_assignment_status = 'explicitly_assigned'
      then platform_documents.file_object_registry.confidentiality_level
    else excluded.confidentiality_level
  end,
  mime_type = coalesce(platform_documents.file_object_registry.mime_type, excluded.mime_type),
  file_size_bytes = coalesce(platform_documents.file_object_registry.file_size_bytes, excluded.file_size_bytes),
  owner_unit_id = platform_documents.file_object_registry.owner_unit_id,
  governorate_code = platform_documents.file_object_registry.governorate_code,
  scope_type = coalesce(platform_documents.file_object_registry.scope_type, 'storage_only'),
  scope_id = platform_documents.file_object_registry.scope_id,
  visibility_scope = case
    when platform_documents.file_object_registry.unit_assignment_status = 'explicitly_assigned'
      then platform_documents.file_object_registry.visibility_scope
    else 'restricted'
  end,
  unit_assignment_status = coalesce(platform_documents.file_object_registry.unit_assignment_status, 'unassigned'),
  unit_assignment_reason = coalesce(
    platform_documents.file_object_registry.unit_assignment_reason,
    'No administrative unit was inferred from storage path. Explicit owner/unit mapping required.'
  ),
  updated_at = now();

drop view if exists public.v_document_center_storage_objects_v1;

create view public.v_document_center_storage_objects_v1 as
select
  r.id,
  r.storage_bucket,
  r.storage_path,
  r.source_system,
  r.source_surface,
  r.source_record_id,
  r.retention_class,
  r.confidentiality_level,
  r.lifecycle_status,
  r.title,
  r.mime_type,
  r.file_size_bytes,
  r.is_original,
  r.is_storage_only,
  r.mapping_status,
  r.owner_unit_id,
  ou.name_ar as owner_unit_name_ar,
  ou.slug as owner_unit_slug,
  r.governorate_code,
  r.scope_type,
  r.scope_id,
  r.visibility_scope,
  r.unit_assignment_status,
  r.unit_assignment_reason,
  r.notes,
  r.created_at,
  r.updated_at
from platform_documents.file_object_registry r
left join core.org_units ou
  on ou.id = r.owner_unit_id
where coalesce(r.lifecycle_status, 'active') <> 'deleted';

grant select on public.v_document_center_storage_objects_v1 to authenticated;

commit;

select
  'file_center_unit_aware_storage_mapping_apply_result' as section,
  to_regclass('platform_documents.file_object_registry') is not null as file_object_registry_present,
  to_regclass('public.v_document_center_storage_objects_v1') is not null as storage_objects_wrapper_present,
  (select count(*)::bigint from platform_documents.file_object_registry) as registry_row_count,
  (select count(*)::bigint from platform_documents.file_object_registry where unit_assignment_status = 'unassigned') as unassigned_count,
  (select count(*)::bigint from platform_documents.file_object_registry where visibility_scope = 'restricted') as restricted_count,
  false as production_approved;
