
-- PALWAKF_FILE_CENTER_HOME_NEWS_PUBLIC_API_EDGE_MEGA_BATCH
-- AUTHORIZED APPLY CANDIDATE: explicit file-center assignment/mapping workflow.
--
-- Public schema policy:
-- - public functions below are API-edge facades only.
-- - source of truth remains platform_documents.file_object_registry.
-- - no public base tables are created.
--
-- Boundaries:
-- - No file deletion.
-- - No storage.objects mutation.
-- - No fake owner records.
-- - No media-gallery object is made public automatically.
-- - No RLS mutation.
-- - No service_role usage.
-- - No production approval.

begin;

create table if not exists platform_documents.file_object_mapping_events (
  id uuid primary key default gen_random_uuid(),
  file_object_id uuid not null references platform_documents.file_object_registry(id) on delete cascade,
  event_type text not null
    check (event_type in (
      'unit_assignment',
      'owner_record_mapping',
      'visibility_change_blocked',
      'review_note'
    )),
  actor_user_id uuid null references auth.users(id),
  old_record jsonb null,
  new_record jsonb null,
  reason text not null,
  created_at timestamptz not null default now()
);

comment on table platform_documents.file_object_mapping_events is
  'Audit trail for explicit unit assignment and owner record mapping of governed storage objects.';

create index if not exists idx_file_object_mapping_events_file_object_id
  on platform_documents.file_object_mapping_events(file_object_id);

create index if not exists idx_file_object_mapping_events_type_created
  on platform_documents.file_object_mapping_events(event_type, created_at desc);

create or replace function public.rpc_file_object_assign_unit_scope_v1(
  p_file_object_id uuid,
  p_owner_unit_id uuid,
  p_scope_type text default 'unit',
  p_scope_id uuid default null,
  p_visibility_scope text default 'unit',
  p_reason text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, platform_documents, core, auth, pg_temp
as $$
declare
  v_actor uuid := auth.uid();
  v_old jsonb;
  v_new jsonb;
begin
  if v_actor is null then
    raise exception 'AUTH_REQUIRED' using errcode = '28000';
  end if;

  if p_file_object_id is null then
    raise exception 'FILE_OBJECT_ID_REQUIRED' using errcode = '22023';
  end if;

  if p_owner_unit_id is null then
    raise exception 'OWNER_UNIT_ID_REQUIRED' using errcode = '22023';
  end if;

  if p_reason is null or length(trim(p_reason)) < 5 then
    raise exception 'ASSIGNMENT_REASON_REQUIRED' using errcode = '22023';
  end if;

  if p_visibility_scope = 'public' then
    raise exception 'PUBLIC_VISIBILITY_NOT_ALLOWED_IN_UNIT_ASSIGNMENT_RPC' using errcode = '42501';
  end if;

  if p_scope_type not in (
    'unit',
    'governorate',
    'service_request',
    'media_content',
    'waqf_asset',
    'case',
    'document_job'
  ) then
    raise exception 'UNSUPPORTED_SCOPE_TYPE: %', p_scope_type using errcode = '22023';
  end if;

  if p_visibility_scope not in ('internal', 'unit', 'governorate', 'restricted') then
    raise exception 'UNSUPPORTED_VISIBILITY_SCOPE: %', p_visibility_scope using errcode = '22023';
  end if;

  if not exists (select 1 from core.org_units where id = p_owner_unit_id) then
    raise exception 'OWNER_UNIT_NOT_FOUND' using errcode = '23503';
  end if;

  select to_jsonb(r)
    into v_old
  from platform_documents.file_object_registry r
  where r.id = p_file_object_id
  for update;

  if v_old is null then
    raise exception 'FILE_OBJECT_NOT_FOUND' using errcode = '02000';
  end if;

  update platform_documents.file_object_registry
  set
    owner_unit_id = p_owner_unit_id,
    scope_type = p_scope_type,
    scope_id = p_scope_id,
    visibility_scope = p_visibility_scope,
    unit_assignment_status = 'explicitly_assigned',
    unit_assignment_reason = trim(p_reason),
    assigned_by = v_actor,
    assigned_at = now(),
    updated_at = now()
  where id = p_file_object_id
  returning to_jsonb(platform_documents.file_object_registry.*)
  into v_new;

  insert into platform_documents.file_object_mapping_events (
    file_object_id,
    event_type,
    actor_user_id,
    old_record,
    new_record,
    reason
  )
  values (
    p_file_object_id,
    'unit_assignment',
    v_actor,
    v_old,
    v_new,
    trim(p_reason)
  );

  return jsonb_build_object(
    'success', true,
    'file_object_id', p_file_object_id,
    'owner_unit_id', p_owner_unit_id,
    'scope_type', p_scope_type,
    'visibility_scope', p_visibility_scope,
    'unit_assignment_status', 'explicitly_assigned',
    'production_approved', false
  );
end;
$$;

create or replace function public.rpc_file_object_mark_owner_mapping_v1(
  p_file_object_id uuid,
  p_source_system text,
  p_source_surface text,
  p_source_record_id uuid,
  p_scope_type text,
  p_reason text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, platform_documents, auth, pg_temp
as $$
declare
  v_actor uuid := auth.uid();
  v_old jsonb;
  v_new jsonb;
begin
  if v_actor is null then
    raise exception 'AUTH_REQUIRED' using errcode = '28000';
  end if;

  if p_file_object_id is null then
    raise exception 'FILE_OBJECT_ID_REQUIRED' using errcode = '22023';
  end if;

  if p_source_system is null or trim(p_source_system) = '' then
    raise exception 'SOURCE_SYSTEM_REQUIRED' using errcode = '22023';
  end if;

  if p_source_surface is null or trim(p_source_surface) = '' then
    raise exception 'SOURCE_SURFACE_REQUIRED' using errcode = '22023';
  end if;

  if p_source_record_id is null then
    raise exception 'SOURCE_RECORD_ID_REQUIRED' using errcode = '22023';
  end if;

  if p_scope_type not in (
    'service_request',
    'media_content',
    'waqf_asset',
    'case',
    'document_job'
  ) then
    raise exception 'UNSUPPORTED_OWNER_SCOPE_TYPE: %', p_scope_type using errcode = '22023';
  end if;

  if p_reason is null or length(trim(p_reason)) < 5 then
    raise exception 'MAPPING_REASON_REQUIRED' using errcode = '22023';
  end if;

  select to_jsonb(r)
    into v_old
  from platform_documents.file_object_registry r
  where r.id = p_file_object_id
  for update;

  if v_old is null then
    raise exception 'FILE_OBJECT_NOT_FOUND' using errcode = '02000';
  end if;

  update platform_documents.file_object_registry
  set
    source_system = trim(p_source_system),
    source_surface = trim(p_source_surface),
    source_record_id = p_source_record_id,
    scope_type = p_scope_type,
    scope_id = p_source_record_id,
    mapping_status = 'mapped_to_owner_record',
    is_storage_only = false,
    visibility_scope = case
      when visibility_scope = 'public' then 'restricted'
      else visibility_scope
    end,
    updated_at = now()
  where id = p_file_object_id
  returning to_jsonb(platform_documents.file_object_registry.*)
  into v_new;

  insert into platform_documents.file_object_mapping_events (
    file_object_id,
    event_type,
    actor_user_id,
    old_record,
    new_record,
    reason
  )
  values (
    p_file_object_id,
    'owner_record_mapping',
    v_actor,
    v_old,
    v_new,
    trim(p_reason)
  );

  return jsonb_build_object(
    'success', true,
    'file_object_id', p_file_object_id,
    'source_system', trim(p_source_system),
    'source_surface', trim(p_source_surface),
    'source_record_id', p_source_record_id,
    'mapping_status', 'mapped_to_owner_record',
    'public_visibility_granted', false,
    'production_approved', false
  );
end;
$$;

grant execute on function public.rpc_file_object_assign_unit_scope_v1(
  uuid, uuid, text, uuid, text, text
) to authenticated;

grant execute on function public.rpc_file_object_mark_owner_mapping_v1(
  uuid, text, text, uuid, text, text
) to authenticated;

commit;

select
  'file_center_explicit_unit_assignment_workflow_apply_result' as section,
  to_regclass('platform_documents.file_object_mapping_events') is not null as mapping_events_table_present,
  to_regprocedure('public.rpc_file_object_assign_unit_scope_v1(uuid,uuid,text,uuid,text,text)') is not null as assign_unit_rpc_present,
  to_regprocedure('public.rpc_file_object_mark_owner_mapping_v1(uuid,text,text,uuid,text,text)') is not null as mark_owner_mapping_rpc_present,
  false as public_base_table_created,
  false as production_approved;
