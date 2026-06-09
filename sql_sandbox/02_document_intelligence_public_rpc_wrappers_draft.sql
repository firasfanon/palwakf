-- Document Intelligence — public RPC wrappers draft
-- Status: non-production draft / adapt field names and permissions to real platform codebase
-- public is wrappers only

create schema if not exists public;

create or replace function public.rpc_document_job_create_v1(
  p_source_system text,
  p_source_record_id uuid,
  p_mode text,
  p_sensitivity_level text default 'general',
  p_waqf_asset_id uuid default null,
  p_case_id uuid default null,
  p_billing_record_id uuid default null,
  p_task_id uuid default null,
  p_historical_reference_id uuid default null,
  p_map_evidence_snapshot_id uuid default null,
  p_metadata jsonb default '{}'::jsonb
)
returns assistant.document_jobs
language plpgsql
security definer
as $$
declare
  v_row assistant.document_jobs;
begin
  insert into assistant.document_jobs(
    source_system,
    source_record_id,
    mode,
    sensitivity_level,
    waqf_asset_id,
    case_id,
    billing_record_id,
    task_id,
    historical_reference_id,
    map_evidence_snapshot_id,
    metadata,
    status,
    review_required
  )
  values (
    p_source_system,
    p_source_record_id,
    p_mode,
    p_sensitivity_level,
    p_waqf_asset_id,
    p_case_id,
    p_billing_record_id,
    p_task_id,
    p_historical_reference_id,
    p_map_evidence_snapshot_id,
    coalesce(p_metadata, '{}'::jsonb),
    'draft',
    true
  )
  returning * into v_row;

  return v_row;
end;
$$;

create or replace function public.rpc_document_job_get_v1(
  p_job_id uuid
)
returns jsonb
language sql
security definer
as $$
  select jsonb_build_object(
    'job', to_jsonb(j),
    'files', coalesce((
      select jsonb_agg(to_jsonb(f) order by f.created_at asc)
      from assistant.document_files f
      where f.job_id = j.id
    ), '[]'::jsonb)
  )
  from assistant.document_jobs j
  where j.id = p_job_id;
$$;

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
    ), '[]'::jsonb)
  );
$$;

create or replace function public.rpc_document_job_list_v1(
  p_source_system text default null,
  p_mode text default null,
  p_status text default null,
  p_waqf_asset_id uuid default null,
  p_case_id uuid default null
)
returns setof assistant.document_jobs
language sql
security definer
as $$
  select *
  from assistant.document_jobs j
  where (p_source_system is null or j.source_system = p_source_system)
    and (p_mode is null or j.mode = p_mode)
    and (p_status is null or j.status = p_status)
    and (p_waqf_asset_id is null or j.waqf_asset_id = p_waqf_asset_id)
    and (p_case_id is null or j.case_id = p_case_id)
  order by j.requested_at desc;
$$;

create or replace function public.rpc_document_candidate_links_v1(
  p_job_id uuid
)
returns setof assistant.document_candidate_links
language sql
security definer
as $$
  select *
  from assistant.document_candidate_links
  where job_id = p_job_id
  order by created_at asc;
$$;

create or replace function public.rpc_document_job_review_submit_v1(
  p_job_id uuid,
  p_review_status text,
  p_notes text default null,
  p_field_corrections jsonb default '{}'::jsonb,
  p_approved_links jsonb default '[]'::jsonb,
  p_rejected_links jsonb default '[]'::jsonb
)
returns assistant.document_reviews
language plpgsql
security definer
as $$
declare
  v_review assistant.document_reviews;
begin
  insert into assistant.document_reviews(
    job_id,
    review_status,
    reviewed_by,
    reviewed_at,
    notes,
    field_corrections,
    approved_links,
    rejected_links
  )
  values (
    p_job_id,
    p_review_status,
    auth.uid(),
    now(),
    p_notes,
    coalesce(p_field_corrections, '{}'::jsonb),
    coalesce(p_approved_links, '[]'::jsonb),
    coalesce(p_rejected_links, '[]'::jsonb)
  )
  returning * into v_review;

  update assistant.document_jobs
  set status = case
      when p_review_status = 'approved' then 'approved'
      when p_review_status = 'rejected' then 'rejected'
      when p_review_status = 'reviewed' then 'reviewed'
      else 'needs_review'
    end
  where id = p_job_id;

  insert into assistant.document_audit_events(job_id, event_type, actor_id, event_payload)
  values (
    p_job_id,
    'review_submit',
    auth.uid(),
    jsonb_build_object(
      'review_status', p_review_status,
      'notes', p_notes
    )
  );

  return v_review;
end;
$$;

create or replace function public.rpc_document_reprocess_v1(
  p_job_id uuid,
  p_mode text default null,
  p_metadata_patch jsonb default '{}'::jsonb
)
returns assistant.document_jobs
language plpgsql
security definer
as $$
declare
  v_row assistant.document_jobs;
begin
  update assistant.document_jobs
  set mode = coalesce(p_mode, mode),
      status = 'draft',
      processed_at = null,
      metadata = coalesce(metadata, '{}'::jsonb) || coalesce(p_metadata_patch, '{}'::jsonb)
  where id = p_job_id
  returning * into v_row;

  insert into assistant.document_audit_events(job_id, event_type, actor_id, event_payload)
  values (
    p_job_id,
    'reprocess_requested',
    auth.uid(),
    jsonb_build_object(
      'mode', p_mode,
      'metadata_patch', coalesce(p_metadata_patch, '{}'::jsonb)
    )
  );

  return v_row;
end;
$$;
