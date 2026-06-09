-- PalWakf / Document Intelligence
-- Upload + source-file registration + processing output ingestion patch
-- Safe to run after the base SQL/RPC patch.

begin;

alter table if exists assistant.document_files
  add column if not exists original_file_name text,
  add column if not exists file_size_bytes bigint;

insert into storage.buckets (id, name, public)
select 'document-intelligence', 'document-intelligence', false
where not exists (
  select 1 from storage.buckets where id = 'document-intelligence'
);

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'storage' and tablename = 'objects' and policyname = 'document_intelligence_storage_select_v1'
  ) then
    create policy document_intelligence_storage_select_v1
      on storage.objects for select to authenticated
      using (bucket_id = 'document-intelligence');
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'storage' and tablename = 'objects' and policyname = 'document_intelligence_storage_insert_v1'
  ) then
    create policy document_intelligence_storage_insert_v1
      on storage.objects for insert to authenticated
      with check (bucket_id = 'document-intelligence');
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'storage' and tablename = 'objects' and policyname = 'document_intelligence_storage_update_v1'
  ) then
    create policy document_intelligence_storage_update_v1
      on storage.objects for update to authenticated
      using (bucket_id = 'document-intelligence')
      with check (bucket_id = 'document-intelligence');
  end if;
end $$;

create or replace function public.rpc_document_source_file_register_v1(
  p_job_id uuid,
  p_storage_bucket text,
  p_storage_path text,
  p_mime_type text,
  p_page_count int default 1,
  p_original_file_name text default null,
  p_file_size_bytes bigint default null
)
returns assistant.document_files
language plpgsql
security definer
set search_path = public, assistant
as $$
declare
  v_file assistant.document_files;
begin
  insert into assistant.document_files(
    job_id,
    file_role,
    storage_bucket,
    storage_path,
    mime_type,
    page_count,
    original_file_name,
    file_size_bytes
  )
  values (
    p_job_id,
    'original',
    p_storage_bucket,
    p_storage_path,
    p_mime_type,
    greatest(coalesce(p_page_count, 1), 1),
    p_original_file_name,
    p_file_size_bytes
  )
  returning * into v_file;

  update assistant.document_jobs
  set metadata = coalesce(metadata, '{}'::jsonb) || jsonb_build_object(
    'source_file_registered', true,
    'source_file_name', coalesce(p_original_file_name, p_storage_path)
  )
  where id = p_job_id;

  insert into assistant.document_audit_events(job_id, event_type, actor_id, event_payload)
  values (
    p_job_id,
    'source_file_registered',
    auth.uid(),
    jsonb_build_object(
      'storage_bucket', p_storage_bucket,
      'storage_path', p_storage_path,
      'original_file_name', p_original_file_name,
      'file_size_bytes', p_file_size_bytes
    )
  );

  return v_file;
end;
$$;

create or replace function public.rpc_document_job_ingest_result_v1(
  p_job_id uuid,
  p_document_type_primary text default null,
  p_status text default 'needs_review',
  p_pages jsonb default '[]'::jsonb,
  p_transcriptions jsonb default '[]'::jsonb,
  p_structured_fields jsonb default '[]'::jsonb,
  p_uncertain_segments jsonb default '[]'::jsonb,
  p_candidate_links jsonb default '[]'::jsonb,
  p_metadata_patch jsonb default '{}'::jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, assistant
as $$
declare
  v_page jsonb;
  v_transcription jsonb;
  v_field jsonb;
  v_segment jsonb;
  v_link jsonb;
  v_result jsonb;
begin
  delete from assistant.document_pages where job_id = p_job_id;
  delete from assistant.document_transcriptions where job_id = p_job_id;
  delete from assistant.document_structured_fields where job_id = p_job_id;
  delete from assistant.document_uncertain_segments where job_id = p_job_id;
  delete from assistant.document_candidate_links where job_id = p_job_id;

  for v_page in select value from jsonb_array_elements(coalesce(p_pages, '[]'::jsonb)) loop
    insert into assistant.document_pages(
      job_id,
      page_no,
      width_px,
      height_px,
      has_handwriting,
      has_table,
      has_stamp,
      has_signature,
      page_confidence
    ) values (
      p_job_id,
      coalesce((v_page->>'page_no')::int, 1),
      nullif(v_page->>'width_px', '')::int,
      nullif(v_page->>'height_px', '')::int,
      coalesce((v_page->>'has_handwriting')::boolean, false),
      coalesce((v_page->>'has_table')::boolean, false),
      coalesce((v_page->>'has_stamp')::boolean, false),
      coalesce((v_page->>'has_signature')::boolean, false),
      nullif(v_page->>'page_confidence', '')
    );
  end loop;

  for v_transcription in select value from jsonb_array_elements(coalesce(p_transcriptions, '[]'::jsonb)) loop
    insert into assistant.document_transcriptions(
      job_id,
      page_no,
      printed_text,
      handwritten_text,
      full_text,
      document_confidence
    ) values (
      p_job_id,
      coalesce((v_transcription->>'page_no')::int, 1),
      nullif(v_transcription->>'printed_text', ''),
      nullif(v_transcription->>'handwritten_text', ''),
      nullif(v_transcription->>'full_text', ''),
      nullif(v_transcription->>'document_confidence', '')
    );
  end loop;

  for v_field in select value from jsonb_array_elements(coalesce(p_structured_fields, '[]'::jsonb)) loop
    insert into assistant.document_structured_fields(
      job_id,
      field_name,
      raw_value,
      normalized_value,
      confidence,
      page_no,
      region_id,
      bbox
    ) values (
      p_job_id,
      coalesce(v_field->>'field_name', 'unknown_field'),
      nullif(v_field->>'raw_value', ''),
      nullif(v_field->>'normalized_value', ''),
      coalesce(nullif(v_field->>'confidence', ''), 'medium'),
      nullif(v_field->>'page_no', '')::int,
      nullif(v_field->>'region_id', ''),
      v_field->'bbox'
    );
  end loop;

  for v_segment in select value from jsonb_array_elements(coalesce(p_uncertain_segments, '[]'::jsonb)) loop
    insert into assistant.document_uncertain_segments(
      job_id,
      page_no,
      region_id,
      raw_text,
      reason,
      confidence,
      bbox
    ) values (
      p_job_id,
      coalesce((v_segment->>'page_no')::int, 1),
      coalesce(v_segment->>'region_id', gen_random_uuid()::text),
      coalesce(v_segment->>'raw_text', ''),
      coalesce(v_segment->>'reason', 'requires_review'),
      coalesce(nullif(v_segment->>'confidence', ''), 'medium'),
      v_segment->'bbox'
    );
  end loop;

  for v_link in select value from jsonb_array_elements(coalesce(p_candidate_links, '[]'::jsonb)) loop
    insert into assistant.document_candidate_links(
      job_id,
      entity_type,
      entity_id,
      match_basis,
      confidence,
      requires_review
    ) values (
      p_job_id,
      coalesce(v_link->>'entity_type', 'case'),
      (v_link->>'entity_id')::uuid,
      coalesce(v_link->'match_basis', '[]'::jsonb),
      coalesce(nullif(v_link->>'confidence', ''), 'medium'),
      coalesce((v_link->>'requires_review')::boolean, true)
    );
  end loop;

  update assistant.document_jobs
  set document_type_primary = coalesce(p_document_type_primary, document_type_primary),
      status = coalesce(p_status, 'needs_review'),
      processed_at = now(),
      metadata = coalesce(metadata, '{}'::jsonb) || coalesce(p_metadata_patch, '{}'::jsonb)
  where id = p_job_id;

  insert into assistant.document_audit_events(job_id, event_type, actor_id, event_payload)
  values (
    p_job_id,
    'processing_result_ingested',
    auth.uid(),
    jsonb_build_object(
      'status', p_status,
      'document_type_primary', p_document_type_primary,
      'pages_count', jsonb_array_length(coalesce(p_pages, '[]'::jsonb)),
      'structured_fields_count', jsonb_array_length(coalesce(p_structured_fields, '[]'::jsonb)),
      'uncertain_segments_count', jsonb_array_length(coalesce(p_uncertain_segments, '[]'::jsonb)),
      'candidate_links_count', jsonb_array_length(coalesce(p_candidate_links, '[]'::jsonb))
    )
  );

  select public.rpc_document_job_result_v1(p_job_id) into v_result;
  return v_result;
end;
$$;

grant execute on function public.rpc_document_source_file_register_v1(uuid, text, text, text, int, text, bigint) to authenticated, service_role;
grant execute on function public.rpc_document_job_ingest_result_v1(uuid, text, text, jsonb, jsonb, jsonb, jsonb, jsonb, jsonb) to authenticated, service_role;

commit;
