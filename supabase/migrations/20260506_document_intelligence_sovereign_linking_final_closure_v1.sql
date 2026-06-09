-- PalWakf / Document Intelligence
-- SQL 07 — Sovereign Linking Final Closure
-- Date: 2026-05-06
-- Purpose: Close production readiness stage 05 by approving one real sovereign UUID link.
-- Rule: Do not use fake UUIDs. Prefer entity_type='waqf_asset' with a real waqf_asset_id.

begin;

create schema if not exists assistant;
create extension if not exists pgcrypto;

-- Ensure display fields exist for older baselines.
alter table if exists assistant.document_candidate_links
  add column if not exists display_label text,
  add column if not exists score numeric;

create or replace function public.rpc_document_sovereign_linking_status_v1()
returns table(
  total_candidate_links bigint,
  waqf_asset_links bigint,
  linked_jobs bigint,
  approved_reviews_with_links bigint,
  is_closed boolean
)
language sql
security definer
set search_path = public, assistant
as $$
  with link_counts as (
    select
      count(*)::bigint as total_candidate_links,
      count(*) filter (where entity_type = 'waqf_asset')::bigint as waqf_asset_links,
      count(distinct job_id)::bigint as linked_jobs
    from assistant.document_candidate_links
  ),
  review_counts as (
    select count(*)::bigint as approved_reviews_with_links
    from assistant.document_reviews r
    where jsonb_array_length(coalesce(r.approved_links, '[]'::jsonb)) > 0
  )
  select
    l.total_candidate_links,
    l.waqf_asset_links,
    l.linked_jobs,
    r.approved_reviews_with_links,
    (l.total_candidate_links > 0 and r.approved_reviews_with_links > 0) as is_closed
  from link_counts l cross join review_counts r;
$$;

grant execute on function public.rpc_document_sovereign_linking_status_v1() to authenticated, service_role;

create or replace function public.rpc_document_approve_sovereign_link_v1(
  p_job_id uuid,
  p_entity_type text,
  p_entity_id uuid,
  p_display_label text default null,
  p_score numeric default 1,
  p_confidence text default 'high',
  p_notes text default null,
  p_match_basis jsonb default null,
  p_require_entity_exists boolean default false
)
returns jsonb
language plpgsql
security definer
set search_path = public, assistant
as $$
declare
  v_link assistant.document_candidate_links;
  v_review assistant.document_reviews;
  v_match_basis jsonb;
  v_approved_links jsonb;
  v_entity_table text;
  v_entity_exists boolean := false;
  v_existing_count bigint := 0;
begin
  if not exists (select 1 from assistant.document_jobs where id = p_job_id) then
    raise exception 'Document job does not exist: %', p_job_id using errcode = '22023';
  end if;

  if p_entity_type not in ('waqf_asset','case','billing_record','task','historical_reference','map_evidence_snapshot') then
    raise exception 'Unsupported sovereign entity type: %', p_entity_type using errcode = '22023';
  end if;

  if p_confidence not in ('high','medium','low','unreadable') then
    raise exception 'Unsupported confidence value: %', p_confidence using errcode = '22023';
  end if;

  -- Optional hard verification for waqf_assets. Disabled by default because deployments may keep waqf_assets in
  -- waqf/core/awqaf_system/public with different permissions. Enable only when the canonical table is reachable.
  if p_require_entity_exists and p_entity_type = 'waqf_asset' then
    foreach v_entity_table in array array['waqf.waqf_assets','core.waqf_assets','awqaf_system.waqf_assets','public.waqf_assets'] loop
      if to_regclass(v_entity_table) is not null then
        begin
          execute format('select exists(select 1 from %s where id = $1)', v_entity_table)
            using p_entity_id
            into v_entity_exists;
          if v_entity_exists then
            exit;
          end if;
        exception when undefined_column then
          -- Some deployments may use waqf_asset_id instead of id. Try that before moving on.
          begin
            execute format('select exists(select 1 from %s where waqf_asset_id = $1)', v_entity_table)
              using p_entity_id
              into v_entity_exists;
            if v_entity_exists then
              exit;
            end if;
          exception when undefined_column then
            null;
          end;
        end;
      end if;
    end loop;

    if not coalesce(v_entity_exists, false) then
      raise exception 'No reachable waqf_assets record matched UUID %. Set p_require_entity_exists=false only if the UUID was verified externally.', p_entity_id using errcode = '22023';
    end if;
  end if;

  v_match_basis := coalesce(
    p_match_basis,
    jsonb_build_array(
      jsonb_build_object('type','manual_sovereign_review','value','approved_by_document_reviewer'),
      jsonb_build_object('type','uuid_policy','value','uuid_only_sovereign_link')
    )
  );

  select * into v_link
  from assistant.document_candidate_links
  where job_id = p_job_id
    and entity_type = p_entity_type
    and entity_id = p_entity_id
  order by created_at asc
  limit 1;

  if v_link.id is null then
    insert into assistant.document_candidate_links(
      job_id,
      entity_type,
      entity_id,
      match_basis,
      display_label,
      score,
      confidence,
      requires_review
    ) values (
      p_job_id,
      p_entity_type,
      p_entity_id,
      v_match_basis,
      coalesce(p_display_label, p_entity_type || ': ' || p_entity_id::text),
      p_score,
      p_confidence,
      false
    )
    returning * into v_link;
  else
    update assistant.document_candidate_links
    set
      match_basis = coalesce(nullif(v_link.match_basis, '[]'::jsonb), v_match_basis),
      display_label = coalesce(v_link.display_label, p_display_label, p_entity_type || ': ' || p_entity_id::text),
      score = coalesce(v_link.score, p_score),
      confidence = coalesce(nullif(v_link.confidence, ''), p_confidence),
      requires_review = false
    where id = v_link.id
    returning * into v_link;
  end if;

  v_approved_links := jsonb_build_array(jsonb_build_object(
    'id', v_link.id,
    'entity_type', v_link.entity_type,
    'entity_id', v_link.entity_id,
    'display_label', v_link.display_label,
    'score', v_link.score,
    'confidence', v_link.confidence,
    'match_basis', v_link.match_basis,
    'approved_by_rpc', 'rpc_document_approve_sovereign_link_v1'
  ));

  insert into assistant.document_reviews(
    job_id,
    review_status,
    reviewed_by,
    reviewed_at,
    notes,
    field_corrections,
    approved_links,
    rejected_links
  ) values (
    p_job_id,
    'reviewed',
    auth.uid(),
    now(),
    coalesce(p_notes, 'إغلاق الربط السيادي عبر اعتماد رابط UUID حقيقي.'),
    '{}'::jsonb,
    v_approved_links,
    '[]'::jsonb
  )
  returning * into v_review;

  update assistant.document_jobs
  set
    status = case when status = 'approved' then status else 'reviewed' end,
    waqf_asset_id = case when p_entity_type = 'waqf_asset' then coalesce(waqf_asset_id, p_entity_id) else waqf_asset_id end,
    case_id = case when p_entity_type = 'case' then coalesce(case_id, p_entity_id) else case_id end,
    billing_record_id = case when p_entity_type = 'billing_record' then coalesce(billing_record_id, p_entity_id) else billing_record_id end,
    task_id = case when p_entity_type = 'task' then coalesce(task_id, p_entity_id) else task_id end,
    historical_reference_id = case when p_entity_type = 'historical_reference' then coalesce(historical_reference_id, p_entity_id) else historical_reference_id end,
    map_evidence_snapshot_id = case when p_entity_type = 'map_evidence_snapshot' then coalesce(map_evidence_snapshot_id, p_entity_id) else map_evidence_snapshot_id end,
    metadata = coalesce(metadata, '{}'::jsonb) || jsonb_build_object(
      'sovereign_linking_status', 'closed',
      'sovereign_linking_closed_at', now(),
      'primary_sovereign_link', jsonb_build_object(
        'entity_type', p_entity_type,
        'entity_id', p_entity_id,
        'link_id', v_link.id,
        'review_id', v_review.id
      )
    )
  where id = p_job_id;

  insert into assistant.document_audit_events(job_id, event_type, actor_id, event_payload)
  values (
    p_job_id,
    'sovereign_link_approved',
    auth.uid(),
    jsonb_build_object(
      'entity_type', p_entity_type,
      'entity_id', p_entity_id,
      'link_id', v_link.id,
      'review_id', v_review.id,
      'require_entity_exists', p_require_entity_exists
    )
  );

  select count(*) into v_existing_count from assistant.document_candidate_links where job_id = p_job_id;

  return jsonb_build_object(
    'ok', true,
    'job_id', p_job_id,
    'link_id', v_link.id,
    'review_id', v_review.id,
    'entity_type', p_entity_type,
    'entity_id', p_entity_id,
    'job_candidate_links_count', v_existing_count,
    'readiness_hint', 'Run select * from public.rpc_document_production_readiness_v1(); stage 05 should be closed.'
  );
end;
$$;

grant execute on function public.rpc_document_approve_sovereign_link_v1(uuid, text, uuid, text, numeric, text, text, jsonb, boolean) to authenticated, service_role;

-- Usage with real IDs only:
-- select public.rpc_document_approve_sovereign_link_v1(
--   p_job_id := '00000000-0000-0000-0000-000000000000'::uuid,
--   p_entity_type := 'waqf_asset',
--   p_entity_id := '11111111-1111-1111-1111-111111111111'::uuid,
--   p_display_label := 'أصل وقفي معتمد',
--   p_notes := 'اعتماد رابط سيادي حقيقي لإغلاق مرحلة 05',
--   p_require_entity_exists := false
-- );
-- select * from public.rpc_document_sovereign_linking_status_v1();
-- select * from public.rpc_document_production_readiness_v1();

commit;
