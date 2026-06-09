-- PalWakf / Document Intelligence
-- 05 — Real Engine Adapter + File-Type UAT Evidence patch
-- الهدف: تثبيت عقد محول المحرك، حفظ display_label/score للروابط، وتسجيل Evidence UAT لكل نوع ملف.
-- public يبقى RPC wrappers فقط؛ التخزين في assistant.*.

begin;

alter table assistant.document_candidate_links
  add column if not exists display_label text,
  add column if not exists score numeric;

create table if not exists assistant.document_file_type_uat_evidence (
  id uuid primary key default gen_random_uuid(),
  job_id uuid not null references assistant.document_jobs(id) on delete cascade,
  file_family text not null,
  file_extension text null,
  engine_profile text not null,
  observed_fields_count int not null default 0,
  observed_uncertain_segments_count int not null default 0,
  observed_candidate_links_count int not null default 0,
  result_status text not null default 'recorded',
  evidence_payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_document_file_type_uat_evidence_job_id
  on assistant.document_file_type_uat_evidence(job_id);

create index if not exists idx_document_file_type_uat_evidence_file_family
  on assistant.document_file_type_uat_evidence(file_family);

alter table assistant.document_file_type_uat_evidence enable row level security;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'assistant'
      and tablename = 'document_file_type_uat_evidence'
      and policyname = 'document_file_type_uat_evidence_select_authenticated_v1'
  ) then
    create policy document_file_type_uat_evidence_select_authenticated_v1
      on assistant.document_file_type_uat_evidence
      for select
      to authenticated
      using (true);
  end if;
end $$;

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
  v_skipped_links jsonb := '[]'::jsonb;
  v_uuid_pattern constant text := '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$';
begin
  delete from assistant.document_pages where job_id = p_job_id;
  delete from assistant.document_transcriptions where job_id = p_job_id;
  delete from assistant.document_structured_fields where job_id = p_job_id;
  delete from assistant.document_uncertain_segments where job_id = p_job_id;
  delete from assistant.document_candidate_links where job_id = p_job_id;

  for v_page in select value from jsonb_array_elements(coalesce(p_pages, '[]'::jsonb)) loop
    insert into assistant.document_pages(
      job_id, page_no, width_px, height_px, has_handwriting, has_table, has_stamp, has_signature, page_confidence
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
      job_id, page_no, printed_text, handwritten_text, full_text, document_confidence
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
      job_id, field_name, raw_value, normalized_value, confidence, page_no, region_id, bbox
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
      job_id, page_no, region_id, raw_text, reason, confidence, bbox
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
    if (v_link->>'entity_type') in (
      'waqf_asset', 'case', 'billing_record', 'task', 'historical_reference', 'map_evidence_snapshot'
    ) and coalesce(v_link->>'entity_id', '') ~* v_uuid_pattern then
      insert into assistant.document_candidate_links(
        job_id, entity_type, entity_id, match_basis, display_label, score, confidence, requires_review
      ) values (
        p_job_id,
        coalesce(v_link->>'entity_type', 'case'),
        (v_link->>'entity_id')::uuid,
        coalesce(v_link->'match_basis', '[]'::jsonb),
        nullif(v_link->>'display_label', ''),
        nullif(v_link->>'score', '')::numeric,
        coalesce(nullif(v_link->>'confidence', ''), 'medium'),
        coalesce((v_link->>'requires_review')::boolean, true)
      );
    else
      v_skipped_links := v_skipped_links || jsonb_build_array(v_link);
    end if;
  end loop;

  update assistant.document_jobs
  set document_type_primary = coalesce(p_document_type_primary, document_type_primary),
      status = coalesce(p_status, 'needs_review'),
      processed_at = now(),
      metadata = coalesce(metadata, '{}'::jsonb)
        || coalesce(p_metadata_patch, '{}'::jsonb)
        || jsonb_build_object(
          'candidate_links_policy', 'uuid_only_sovereign_links',
          'skipped_candidate_links_count', jsonb_array_length(v_skipped_links)
        )
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
      'candidate_links_count', jsonb_array_length(coalesce(p_candidate_links, '[]'::jsonb)),
      'skipped_candidate_links_count', jsonb_array_length(v_skipped_links),
      'engine_profile', p_metadata_patch->>'engine_profile',
      'file_type_uat_scenario', p_metadata_patch->>'file_type_uat_scenario'
    )
  );

  if jsonb_array_length(v_skipped_links) > 0 then
    insert into assistant.document_audit_events(job_id, event_type, actor_id, event_payload)
    values (
      p_job_id,
      'candidate_links_skipped',
      auth.uid(),
      jsonb_build_object(
        'reason', 'non_uuid_or_unsupported_entity_type',
        'policy', 'uuid_only_sovereign_links',
        'items', v_skipped_links
      )
    );
  end if;

  select public.rpc_document_job_result_v1(p_job_id) into v_result;
  return v_result;
end;
$$;

grant execute on function public.rpc_document_job_ingest_result_v1(uuid, text, text, jsonb, jsonb, jsonb, jsonb, jsonb, jsonb) to authenticated, service_role;

create or replace function public.rpc_document_file_type_uat_evidence_record_v1(
  p_job_id uuid,
  p_file_family text,
  p_file_extension text default null,
  p_engine_profile text default 'unknown_engine_profile',
  p_evidence_payload jsonb default '{}'::jsonb
)
returns assistant.document_file_type_uat_evidence
language plpgsql
security definer
set search_path = public, assistant
as $$
declare
  v_row assistant.document_file_type_uat_evidence;
  v_fields_count int;
  v_uncertain_count int;
  v_links_count int;
begin
  select count(*) into v_fields_count from assistant.document_structured_fields where job_id = p_job_id;
  select count(*) into v_uncertain_count from assistant.document_uncertain_segments where job_id = p_job_id;
  select count(*) into v_links_count from assistant.document_candidate_links where job_id = p_job_id;

  insert into assistant.document_file_type_uat_evidence(
    job_id,
    file_family,
    file_extension,
    engine_profile,
    observed_fields_count,
    observed_uncertain_segments_count,
    observed_candidate_links_count,
    result_status,
    evidence_payload
  ) values (
    p_job_id,
    coalesce(nullif(p_file_family, ''), 'unknown'),
    nullif(p_file_extension, ''),
    coalesce(nullif(p_engine_profile, ''), 'unknown_engine_profile'),
    coalesce(v_fields_count, 0),
    coalesce(v_uncertain_count, 0),
    coalesce(v_links_count, 0),
    'recorded',
    coalesce(p_evidence_payload, '{}'::jsonb)
  ) returning * into v_row;

  insert into assistant.document_audit_events(job_id, event_type, actor_id, event_payload)
  values (
    p_job_id,
    'file_type_uat_evidence_recorded',
    auth.uid(),
    jsonb_build_object(
      'file_family', p_file_family,
      'file_extension', p_file_extension,
      'engine_profile', p_engine_profile,
      'observed_fields_count', v_fields_count,
      'observed_uncertain_segments_count', v_uncertain_count,
      'observed_candidate_links_count', v_links_count
    )
  );

  return v_row;
end;
$$;

grant execute on function public.rpc_document_file_type_uat_evidence_record_v1(uuid, text, text, text, jsonb) to authenticated, service_role;

create or replace function public.rpc_document_job_result_v1(
  p_job_id uuid
)
returns jsonb
language sql
security definer
as $$
  select jsonb_build_object(
    'job_id', p_job_id,
    'transcriptions', coalesce((
      select jsonb_agg(to_jsonb(t) order by t.page_no asc)
      from assistant.document_transcriptions t
      where t.job_id = p_job_id
    ), '[]'::jsonb),
    'uncertain_segments', coalesce((
      select jsonb_agg(to_jsonb(u) order by u.page_no asc, u.created_at asc)
      from assistant.document_uncertain_segments u
      where u.job_id = p_job_id
    ), '[]'::jsonb),
    'structured_fields', coalesce((
      select jsonb_agg(to_jsonb(s) order by s.created_at asc)
      from assistant.document_structured_fields s
      where s.job_id = p_job_id
    ), '[]'::jsonb),
    'candidate_links', coalesce((
      select jsonb_agg(to_jsonb(c) order by c.created_at asc)
      from assistant.document_candidate_links c
      where c.job_id = p_job_id
    ), '[]'::jsonb),
    'reviews', coalesce((
      select jsonb_agg(to_jsonb(r) order by r.created_at desc)
      from assistant.document_reviews r
      where r.job_id = p_job_id
    ), '[]'::jsonb),
    'uat_evidence', coalesce((
      select jsonb_agg(to_jsonb(e) order by e.created_at desc)
      from assistant.document_file_type_uat_evidence e
      where e.job_id = p_job_id
    ), '[]'::jsonb)
  );
$$;

grant execute on function public.rpc_document_job_result_v1(uuid) to authenticated, service_role;


create or replace function public.rpc_document_file_type_uat_coverage_v1()
returns table(
  file_family text,
  label_ar text,
  uat_scenario text,
  expected_extensions text[],
  evidence_count bigint,
  observed_fields_count bigint,
  observed_uncertain_segments_count bigint,
  observed_candidate_links_count bigint,
  latest_engine_profile text,
  latest_recorded_at timestamptz,
  is_closed boolean
)
language sql
security definer
set search_path = public, assistant
as $$
  with expected(file_family, label_ar, uat_scenario, expected_extensions) as (
    values
      ('image_or_pdf', 'PDF / صور', 'uat_pdf_image_ocr_review', array['.pdf', '.png', '.jpg', '.jpeg', '.tif', '.tiff']::text[]),
      ('word_processing', 'DOC/DOCX/ODT/RTF/TXT', 'uat_word_text_context_extraction', array['.doc', '.docx', '.odt', '.rtf', '.txt']::text[]),
      ('spreadsheet', 'XLS/XLSX/CSV/ODS', 'uat_spreadsheet_header_mapping', array['.xls', '.xlsx', '.csv', '.ods']::text[]),
      ('cad', 'DWG/DXF', 'uat_cad_spatial_verification_stub', array['.dwg', '.dxf']::text[])
  ), aggregated as (
    select
      e.file_family,
      count(*)::bigint as evidence_count,
      sum(coalesce(e.observed_fields_count, 0))::bigint as observed_fields_count,
      sum(coalesce(e.observed_uncertain_segments_count, 0))::bigint as observed_uncertain_segments_count,
      sum(coalesce(e.observed_candidate_links_count, 0))::bigint as observed_candidate_links_count
    from assistant.document_file_type_uat_evidence e
    group by e.file_family
  )
  select
    x.file_family,
    x.label_ar,
    x.uat_scenario,
    x.expected_extensions,
    coalesce(a.evidence_count, 0)::bigint as evidence_count,
    coalesce(a.observed_fields_count, 0)::bigint as observed_fields_count,
    coalesce(a.observed_uncertain_segments_count, 0)::bigint as observed_uncertain_segments_count,
    coalesce(a.observed_candidate_links_count, 0)::bigint as observed_candidate_links_count,
    latest.engine_profile as latest_engine_profile,
    latest.created_at as latest_recorded_at,
    coalesce(a.evidence_count, 0) > 0 as is_closed
  from expected x
  left join aggregated a on a.file_family = x.file_family
  left join lateral (
    select e.engine_profile, e.created_at
    from assistant.document_file_type_uat_evidence e
    where e.file_family = x.file_family
    order by e.created_at desc
    limit 1
  ) latest on true
  order by array_position(array['image_or_pdf', 'word_processing', 'spreadsheet', 'cad']::text[], x.file_family);
$$;

grant execute on function public.rpc_document_file_type_uat_coverage_v1() to authenticated, service_role;

commit;
