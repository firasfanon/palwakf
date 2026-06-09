-- PalWakf / Document Intelligence
-- 2026-05-06 — Full Closure Integrated Batch (Stages 1–10)
-- Status: additive migration. public remains RPC wrappers; assistant stores operational data.
-- Scope: UAT closure, dashboard metrics, production readiness, workflow/audit, assistant knowledge candidates,
-- RBAC-ready helper hooks, and sovereign linking visibility.

begin;

create schema if not exists assistant;
create extension if not exists pgcrypto;

-- 1) UAT + real-engine evidence hardening -------------------------------------------------------
alter table if exists assistant.document_candidate_links
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

-- 2) Workflow / assistant export / governance ---------------------------------------------------
create table if not exists assistant.document_assistant_knowledge_candidates (
  id uuid primary key default gen_random_uuid(),
  job_id uuid not null references assistant.document_jobs(id) on delete cascade,
  candidate_status text not null default 'candidate' check (candidate_status in ('candidate','published','rejected','archived')),
  notes text null,
  payload jsonb not null default '{}'::jsonb,
  created_by uuid null default auth.uid(),
  created_at timestamptz not null default now()
);

create index if not exists idx_document_assistant_knowledge_candidates_job_id
  on assistant.document_assistant_knowledge_candidates(job_id);

create table if not exists assistant.document_operational_actions (
  id uuid primary key default gen_random_uuid(),
  job_id uuid not null references assistant.document_jobs(id) on delete cascade,
  action_type text not null,
  notes text null,
  action_payload jsonb not null default '{}'::jsonb,
  actor_id uuid null default auth.uid(),
  created_at timestamptz not null default now()
);

create index if not exists idx_document_operational_actions_job_id
  on assistant.document_operational_actions(job_id);
create index if not exists idx_document_operational_actions_action_type
  on assistant.document_operational_actions(action_type);

-- Optional platform-facing RBAC shim. Replace bodies with real platform permission helpers when available.
create or replace function assistant.document_can_read_v1()
returns boolean
language sql
stable
security definer
as $$
  select auth.role() in ('authenticated', 'service_role');
$$;

create or replace function assistant.document_can_write_v1()
returns boolean
language sql
stable
security definer
as $$
  select auth.role() in ('authenticated', 'service_role');
$$;

alter table assistant.document_file_type_uat_evidence enable row level security;
alter table assistant.document_assistant_knowledge_candidates enable row level security;
alter table assistant.document_operational_actions enable row level security;

do $$
begin
  if not exists (select 1 from pg_policies where schemaname='assistant' and tablename='document_file_type_uat_evidence' and policyname='document_file_type_uat_evidence_select_v1') then
    create policy document_file_type_uat_evidence_select_v1 on assistant.document_file_type_uat_evidence for select to authenticated using (assistant.document_can_read_v1());
  end if;
  if not exists (select 1 from pg_policies where schemaname='assistant' and tablename='document_file_type_uat_evidence' and policyname='document_file_type_uat_evidence_write_v1') then
    create policy document_file_type_uat_evidence_write_v1 on assistant.document_file_type_uat_evidence for all to authenticated using (assistant.document_can_write_v1()) with check (assistant.document_can_write_v1());
  end if;
  if not exists (select 1 from pg_policies where schemaname='assistant' and tablename='document_assistant_knowledge_candidates' and policyname='document_assistant_knowledge_candidates_select_v1') then
    create policy document_assistant_knowledge_candidates_select_v1 on assistant.document_assistant_knowledge_candidates for select to authenticated using (assistant.document_can_read_v1());
  end if;
  if not exists (select 1 from pg_policies where schemaname='assistant' and tablename='document_assistant_knowledge_candidates' and policyname='document_assistant_knowledge_candidates_write_v1') then
    create policy document_assistant_knowledge_candidates_write_v1 on assistant.document_assistant_knowledge_candidates for all to authenticated using (assistant.document_can_write_v1()) with check (assistant.document_can_write_v1());
  end if;
  if not exists (select 1 from pg_policies where schemaname='assistant' and tablename='document_operational_actions' and policyname='document_operational_actions_select_v1') then
    create policy document_operational_actions_select_v1 on assistant.document_operational_actions for select to authenticated using (assistant.document_can_read_v1());
  end if;
  if not exists (select 1 from pg_policies where schemaname='assistant' and tablename='document_operational_actions' and policyname='document_operational_actions_write_v1') then
    create policy document_operational_actions_write_v1 on assistant.document_operational_actions for all to authenticated using (assistant.document_can_write_v1()) with check (assistant.document_can_write_v1());
  end if;
end $$;

-- 3) Ingest remains UUID-only and records richer audit -----------------------------------------
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
    insert into assistant.document_pages(job_id, page_no, width_px, height_px, has_handwriting, has_table, has_stamp, has_signature, page_confidence)
    values (
      p_job_id,
      coalesce(nullif(v_page->>'page_no', '')::int, 1),
      nullif(v_page->>'width_px', '')::int,
      nullif(v_page->>'height_px', '')::int,
      coalesce(nullif(v_page->>'has_handwriting', '')::boolean, false),
      coalesce(nullif(v_page->>'has_table', '')::boolean, false),
      coalesce(nullif(v_page->>'has_stamp', '')::boolean, false),
      coalesce(nullif(v_page->>'has_signature', '')::boolean, false),
      nullif(v_page->>'page_confidence', '')
    );
  end loop;

  for v_transcription in select value from jsonb_array_elements(coalesce(p_transcriptions, '[]'::jsonb)) loop
    insert into assistant.document_transcriptions(job_id, page_no, printed_text, handwritten_text, full_text, document_confidence)
    values (
      p_job_id,
      coalesce(nullif(v_transcription->>'page_no', '')::int, 1),
      nullif(v_transcription->>'printed_text', ''),
      nullif(v_transcription->>'handwritten_text', ''),
      nullif(v_transcription->>'full_text', ''),
      nullif(v_transcription->>'document_confidence', '')
    );
  end loop;

  for v_field in select value from jsonb_array_elements(coalesce(p_structured_fields, '[]'::jsonb)) loop
    insert into assistant.document_structured_fields(job_id, field_name, raw_value, normalized_value, confidence, page_no, region_id, bbox)
    values (
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
    insert into assistant.document_uncertain_segments(job_id, page_no, region_id, raw_text, reason, confidence, bbox)
    values (
      p_job_id,
      coalesce(nullif(v_segment->>'page_no', '')::int, 1),
      coalesce(v_segment->>'region_id', gen_random_uuid()::text),
      coalesce(v_segment->>'raw_text', ''),
      coalesce(v_segment->>'reason', 'requires_review'),
      coalesce(nullif(v_segment->>'confidence', ''), 'medium'),
      v_segment->'bbox'
    );
  end loop;

  for v_link in select value from jsonb_array_elements(coalesce(p_candidate_links, '[]'::jsonb)) loop
    if (v_link->>'entity_type') in ('waqf_asset','case','billing_record','task','historical_reference','map_evidence_snapshot')
       and coalesce(v_link->>'entity_id', '') ~* v_uuid_pattern then
      insert into assistant.document_candidate_links(job_id, entity_type, entity_id, match_basis, display_label, score, confidence, requires_review)
      values (
        p_job_id,
        coalesce(v_link->>'entity_type', 'case'),
        (v_link->>'entity_id')::uuid,
        coalesce(v_link->'match_basis', '[]'::jsonb),
        nullif(v_link->>'display_label', ''),
        nullif(v_link->>'score', '')::numeric,
        coalesce(nullif(v_link->>'confidence', ''), 'medium'),
        coalesce(nullif(v_link->>'requires_review', '')::boolean, true)
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
          'skipped_candidate_links_count', jsonb_array_length(v_skipped_links),
          'document_center_full_closure_batch', '2026-05-06'
        )
  where id = p_job_id;

  insert into assistant.document_audit_events(job_id, event_type, actor_id, event_payload)
  values (p_job_id, 'processing_result_ingested', auth.uid(), jsonb_build_object(
    'status', p_status,
    'document_type_primary', p_document_type_primary,
    'pages_count', jsonb_array_length(coalesce(p_pages, '[]'::jsonb)),
    'structured_fields_count', jsonb_array_length(coalesce(p_structured_fields, '[]'::jsonb)),
    'uncertain_segments_count', jsonb_array_length(coalesce(p_uncertain_segments, '[]'::jsonb)),
    'candidate_links_count', jsonb_array_length(coalesce(p_candidate_links, '[]'::jsonb)),
    'skipped_candidate_links_count', jsonb_array_length(v_skipped_links),
    'engine_profile', p_metadata_patch->>'engine_profile',
    'file_type_uat_scenario', p_metadata_patch->>'file_type_uat_scenario'
  ));

  if jsonb_array_length(v_skipped_links) > 0 then
    insert into assistant.document_audit_events(job_id, event_type, actor_id, event_payload)
    values (p_job_id, 'candidate_links_skipped', auth.uid(), jsonb_build_object('reason','non_uuid_or_unsupported_entity_type','policy','uuid_only_sovereign_links','items',v_skipped_links));
  end if;

  select public.rpc_document_job_result_v1(p_job_id) into v_result;
  return v_result;
end;
$$;

grant execute on function public.rpc_document_job_ingest_result_v1(uuid, text, text, jsonb, jsonb, jsonb, jsonb, jsonb, jsonb) to authenticated, service_role;

-- 4) Evidence record + coverage -----------------------------------------------------------------
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

  insert into assistant.document_file_type_uat_evidence(job_id, file_family, file_extension, engine_profile, observed_fields_count, observed_uncertain_segments_count, observed_candidate_links_count, result_status, evidence_payload)
  values (p_job_id, coalesce(nullif(p_file_family, ''), 'unknown'), nullif(p_file_extension, ''), coalesce(nullif(p_engine_profile, ''), 'unknown_engine_profile'), coalesce(v_fields_count,0), coalesce(v_uncertain_count,0), coalesce(v_links_count,0), 'recorded', coalesce(p_evidence_payload, '{}'::jsonb))
  returning * into v_row;

  insert into assistant.document_audit_events(job_id, event_type, actor_id, event_payload)
  values (p_job_id, 'file_type_uat_evidence_recorded', auth.uid(), jsonb_build_object(
    'file_family', p_file_family,
    'file_extension', p_file_extension,
    'engine_profile', p_engine_profile,
    'observed_fields_count', v_fields_count,
    'observed_uncertain_segments_count', v_uncertain_count,
    'observed_candidate_links_count', v_links_count
  ));

  return v_row;
end;
$$;

grant execute on function public.rpc_document_file_type_uat_evidence_record_v1(uuid, text, text, text, jsonb) to authenticated, service_role;

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
      ('image_or_pdf', 'PDF / صور', 'uat_pdf_image_ocr_review', array['.pdf','.png','.jpg','.jpeg','.tif','.tiff']::text[]),
      ('word_processing', 'DOC/DOCX/ODT/RTF/TXT', 'uat_word_text_context_extraction', array['.doc','.docx','.odt','.rtf','.txt']::text[]),
      ('spreadsheet', 'XLS/XLSX/CSV/ODS', 'uat_spreadsheet_header_mapping', array['.xls','.xlsx','.csv','.ods']::text[]),
      ('cad', 'DWG/DXF', 'uat_cad_spatial_verification_stub', array['.dwg','.dxf']::text[])
  ), aggregated as (
    select file_family,
           count(*)::bigint as evidence_count,
           sum(coalesce(observed_fields_count,0))::bigint as observed_fields_count,
           sum(coalesce(observed_uncertain_segments_count,0))::bigint as observed_uncertain_segments_count,
           sum(coalesce(observed_candidate_links_count,0))::bigint as observed_candidate_links_count
    from assistant.document_file_type_uat_evidence
    group by file_family
  )
  select x.file_family,
         x.label_ar,
         x.uat_scenario,
         x.expected_extensions,
         coalesce(a.evidence_count,0)::bigint,
         coalesce(a.observed_fields_count,0)::bigint,
         coalesce(a.observed_uncertain_segments_count,0)::bigint,
         coalesce(a.observed_candidate_links_count,0)::bigint,
         latest.engine_profile,
         latest.created_at,
         coalesce(a.evidence_count,0) > 0 as is_closed
  from expected x
  left join aggregated a on a.file_family=x.file_family
  left join lateral (
    select engine_profile, created_at
    from assistant.document_file_type_uat_evidence e
    where e.file_family=x.file_family
    order by created_at desc
    limit 1
  ) latest on true
  order by array_position(array['image_or_pdf','word_processing','spreadsheet','cad']::text[], x.file_family);
$$;

grant execute on function public.rpc_document_file_type_uat_coverage_v1() to authenticated, service_role;

create or replace function public.rpc_document_event_label_ar_v1(p_event_type text)
returns text
language sql
immutable
as $$
  select case p_event_type
    when 'processing_result_ingested' then 'إدخال مخرجات المعالجة'
    when 'candidate_links_skipped' then 'تخطي روابط غير سيادية'
    when 'file_type_uat_evidence_recorded' then 'تسجيل Evidence UAT'
    when 'review_submit' then 'حفظ قرار مراجعة'
    when 'reprocess_requested' then 'طلب إعادة معالجة'
    when 'assistant_knowledge_candidate_created' then 'ترشيح معرفة للمساعد'
    when 'operational_action_recorded' then 'تسجيل إجراء تشغيلي'
    else coalesce(p_event_type, 'حدث غير محدد')
  end;
$$;

grant execute on function public.rpc_document_event_label_ar_v1(text) to authenticated, service_role;

-- 5) Result reader includes reviews, audit, UAT, assistant candidates ---------------------------
create or replace function public.rpc_document_job_result_v1(p_job_id uuid)
returns jsonb
language sql
security definer
as $$
  select jsonb_build_object(
    'job_id', p_job_id,
    'transcriptions', coalesce((select jsonb_agg(to_jsonb(t) order by t.page_no asc) from assistant.document_transcriptions t where t.job_id=p_job_id), '[]'::jsonb),
    'uncertain_segments', coalesce((select jsonb_agg(to_jsonb(u) order by u.page_no asc, u.created_at asc) from assistant.document_uncertain_segments u where u.job_id=p_job_id), '[]'::jsonb),
    'structured_fields', coalesce((select jsonb_agg(to_jsonb(s) order by s.created_at asc) from assistant.document_structured_fields s where s.job_id=p_job_id), '[]'::jsonb),
    'candidate_links', coalesce((select jsonb_agg(to_jsonb(c) order by c.created_at asc) from assistant.document_candidate_links c where c.job_id=p_job_id), '[]'::jsonb),
    'reviews', coalesce((select jsonb_agg(to_jsonb(r) order by r.created_at desc) from assistant.document_reviews r where r.job_id=p_job_id), '[]'::jsonb),
    'uat_evidence', coalesce((select jsonb_agg(to_jsonb(e) order by e.created_at desc) from assistant.document_file_type_uat_evidence e where e.job_id=p_job_id), '[]'::jsonb),
    'audit_events', coalesce((select jsonb_agg(jsonb_build_object('event_type', a.event_type, 'event_label_ar', public.rpc_document_event_label_ar_v1(a.event_type), 'event_payload', a.event_payload, 'created_at', a.created_at) order by a.created_at desc) from assistant.document_audit_events a where a.job_id=p_job_id), '[]'::jsonb),
    'assistant_citations', coalesce((select jsonb_agg(to_jsonb(k) order by k.created_at desc) from assistant.document_assistant_knowledge_candidates k where k.job_id=p_job_id), '[]'::jsonb)
  );
$$;

grant execute on function public.rpc_document_job_result_v1(uuid) to authenticated, service_role;

-- 6) Metrics, production readiness, operational actions -----------------------------------------
create or replace function public.rpc_document_dashboard_metrics_v1()
returns jsonb
language sql
security definer
set search_path = public, assistant
as $$
  with coverage as (select * from public.rpc_document_file_type_uat_coverage_v1()),
       linked_jobs as (select distinct job_id from assistant.document_candidate_links),
       evidence_jobs as (select distinct job_id from assistant.document_file_type_uat_evidence)
  select jsonb_build_object(
    'total_jobs', (select count(*) from assistant.document_jobs),
    'needs_review', (select count(*) from assistant.document_jobs where status='needs_review'),
    'approved', (select count(*) from assistant.document_jobs where status='approved'),
    'rejected', (select count(*) from assistant.document_jobs where status='rejected'),
    'with_sovereign_links', (select count(*) from linked_jobs),
    'with_uat_evidence', (select count(*) from evidence_jobs),
    'closed_file_families', (select count(*) from coverage where is_closed),
    'missing_file_families', (select count(*) from coverage where not is_closed),
    'engine_profile_label', coalesce((select latest_engine_profile from coverage where latest_engine_profile is not null order by latest_recorded_at desc nulls last limit 1), 'غير محدد')
  );
$$;

grant execute on function public.rpc_document_dashboard_metrics_v1() to authenticated, service_role;

create or replace function public.rpc_document_production_readiness_v1()
returns table(
  stage_key text,
  stage_title_ar text,
  status_key text,
  status_label_ar text,
  evidence_ar text,
  required_next_action_ar text,
  is_closed boolean
)
language sql
security definer
set search_path = public, assistant
as $$
  with coverage as (select count(*) filter (where is_closed) as closed_count from public.rpc_document_file_type_uat_coverage_v1()),
       counts as (
         select
           (select count(*) from assistant.document_jobs) as jobs_count,
           (select count(*) from assistant.document_candidate_links) as links_count,
           (select count(*) from assistant.document_reviews) as reviews_count,
           (select count(*) from assistant.document_file_type_uat_evidence) as evidence_count,
           (select count(*) from assistant.document_assistant_knowledge_candidates) as assistant_candidates_count,
           (select count(*) from assistant.document_audit_events) as audit_count
       )
  select * from (
    values
      ('01_uat_coverage','1. إغلاق UAT الحي لأنواع الملفات', case when (select closed_count from coverage)=4 then 'closed' else 'open' end, case when (select closed_count from coverage)=4 then 'مغلق' else 'مفتوح' end, 'عائلات ملفات مغلقة: ' || (select closed_count from coverage)::text || '/4', 'رفع ومعالجة عينة لكل عائلة', (select closed_count from coverage)=4),
      ('02_analyzer','2. تحليل Flutter وإغلاق الأخطاء', 'implemented_pending_local_run', 'منفذ برمجيًا وينتظر تشغيل محلي', 'لا يمكن قياس flutter analyze من SQL؛ تم توفير baseline وفحص ثابت', 'تشغيل flutter analyze في بيئة التطوير', false),
      ('03_real_engine','3. محول المحرك الحقيقي', case when (select evidence_count from counts)>0 then 'adapter_ready' else 'open' end, case when (select evidence_count from counts)>0 then 'Adapter جاهز' else 'بانتظار Evidence' end, 'Evidence مسجلة: ' || (select evidence_count from counts)::text, 'ضبط PWF_DOCUMENT_ENGINE_MODE=supabase_rpc عند ربط المحرك', (select evidence_count from counts)>0),
      ('04_extraction_quality','4. جودة الاستخراج والمقاطع غير المؤكدة', case when (select jobs_count from counts)>0 then 'active' else 'open' end, case when (select jobs_count from counts)>0 then 'فعّال' else 'بانتظار وظائف' end, 'وظائف مسجلة: ' || (select jobs_count from counts)::text, 'مراجعة الحقول والمقاطع لكل وظيفة', (select jobs_count from counts)>0),
      ('05_sovereign_linking','5. الربط السيادي مع كيانات المنصة', case when (select links_count from counts)>0 then 'active' else 'open' end, case when (select links_count from counts)>0 then 'فعّال' else 'بانتظار روابط UUID' end, 'روابط مرشحة: ' || (select links_count from counts)::text, 'اعتماد الروابط عبر شاشة الربط', (select links_count from counts)>0),
      ('06_review_workflow','6. دورة المراجعة البشرية', case when (select reviews_count from counts)>0 then 'active' else 'open' end, case when (select reviews_count from counts)>0 then 'فعّالة' else 'بانتظار قرارات' end, 'قرارات مراجعة: ' || (select reviews_count from counts)::text, 'اعتماد/رفض/إعادة معالجة الوثائق', (select reviews_count from counts)>0),
      ('07_ui_center','7. واجهة مركز الوثائق', 'implemented', 'منفذة', 'لوحات Dashboard/Details/Readiness/Workflow/RBAC/Assistant', 'اختبار UI يدويًا بعد التحليل', true),
      ('08_rls_rbac','8. RLS/RBAC والصلاحيات', 'shim_ready', 'جاهز للربط', 'document_can_read_v1/document_can_write_v1', 'استبدال shim بدوال RBAC السيادية', true),
      ('09_assistant_integration','9. التكامل مع المساعد الداخلي', case when (select assistant_candidates_count from counts)>0 then 'active' else 'ready' end, case when (select assistant_candidates_count from counts)>0 then 'فعّال' else 'جاهز' end, 'ترشيحات معرفة: ' || (select assistant_candidates_count from counts)::text, 'ترشيح الوثائق المعتمدة فقط', true),
      ('10_production_docs','10. التوثيق والتسليم النهائي', 'implemented', 'منفذ', 'Migration + Handoff + Changelog + Baseline', 'تشغيل التحقق المحلي والحي', true)
  ) as t(stage_key, stage_title_ar, status_key, status_label_ar, evidence_ar, required_next_action_ar, is_closed);
$$;

grant execute on function public.rpc_document_production_readiness_v1() to authenticated, service_role;

create or replace function public.rpc_document_operational_action_record_v1(
  p_job_id uuid,
  p_action_type text,
  p_notes text default null,
  p_payload jsonb default '{}'::jsonb
)
returns assistant.document_operational_actions
language plpgsql
security definer
set search_path = public, assistant
as $$
declare
  v_row assistant.document_operational_actions;
begin
  insert into assistant.document_operational_actions(job_id, action_type, notes, action_payload, actor_id)
  values (p_job_id, coalesce(nullif(p_action_type,''),'manual_note'), p_notes, coalesce(p_payload,'{}'::jsonb), auth.uid())
  returning * into v_row;

  insert into assistant.document_audit_events(job_id, event_type, actor_id, event_payload)
  values (p_job_id, 'operational_action_recorded', auth.uid(), jsonb_build_object('action_type', p_action_type, 'notes', p_notes, 'payload', coalesce(p_payload,'{}'::jsonb)));

  return v_row;
end;
$$;

grant execute on function public.rpc_document_operational_action_record_v1(uuid, text, text, jsonb) to authenticated, service_role;

create or replace function public.rpc_document_assistant_knowledge_candidate_v1(
  p_job_id uuid,
  p_notes text default null
)
returns assistant.document_assistant_knowledge_candidates
language plpgsql
security definer
set search_path = public, assistant
as $$
declare
  v_job assistant.document_jobs;
  v_row assistant.document_assistant_knowledge_candidates;
begin
  select * into v_job from assistant.document_jobs where id=p_job_id;
  if not found then
    raise exception 'document job not found: %', p_job_id;
  end if;

  if v_job.status <> 'approved' then
    raise exception 'document must be approved before assistant knowledge nomination. current status: %', v_job.status;
  end if;

  insert into assistant.document_assistant_knowledge_candidates(job_id, candidate_status, notes, payload, created_by)
  values (
    p_job_id,
    'candidate',
    p_notes,
    jsonb_build_object(
      'source', 'document_intelligence',
      'document_type_primary', v_job.document_type_primary,
      'source_system', v_job.source_system,
      'waqf_asset_id', v_job.waqf_asset_id,
      'case_id', v_job.case_id,
      'policy', 'reviewed_approved_documents_only'
    ),
    auth.uid()
  ) returning * into v_row;

  insert into assistant.document_audit_events(job_id, event_type, actor_id, event_payload)
  values (p_job_id, 'assistant_knowledge_candidate_created', auth.uid(), jsonb_build_object('candidate_id', v_row.id, 'policy', 'reviewed_approved_documents_only'));

  return v_row;
end;
$$;

grant execute on function public.rpc_document_assistant_knowledge_candidate_v1(uuid, text) to authenticated, service_role;

commit;
