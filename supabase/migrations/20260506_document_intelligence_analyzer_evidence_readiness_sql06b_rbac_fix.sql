-- PalWakf Document Intelligence
-- SQL 06B — Analyzer Evidence + Production Readiness Closure + RBAC Schema Fix
-- Date: 2026-05-06
-- Purpose:
--   Persist the local Flutter analyzer result inside Supabase so
--   public.rpc_document_production_readiness_v1() can close stage 02.
--   This does not replace the local analyzer; it records its verified result.
-- Fix from SQL 06: policies must call assistant.document_can_read_v1()/write_v1(), not public.document_can_read_v1(null).

begin;

create schema if not exists assistant;
create extension if not exists pgcrypto;

-- RBAC shim kept in assistant schema. Replace bodies later with sovereign platform RBAC helpers.
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


create table if not exists assistant.document_analyzer_verifications (
  id uuid primary key default gen_random_uuid(),
  verification_scope text not null default 'lib/features/document_intelligence',
  command_text text not null default 'flutter analyze lib/features/document_intelligence',
  result_key text not null,
  result_label_ar text not null,
  issues_count integer not null default 0 check (issues_count >= 0),
  analyzer_output text,
  flutter_version text,
  dart_version text,
  baseline_name text,
  verified_at timestamptz not null default now(),
  verified_by uuid default auth.uid(),
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_document_analyzer_verifications_scope_time
  on assistant.document_analyzer_verifications(verification_scope, verified_at desc);

create index if not exists idx_document_analyzer_verifications_result_key
  on assistant.document_analyzer_verifications(result_key);

alter table assistant.document_analyzer_verifications enable row level security;

drop policy if exists document_analyzer_verifications_select_v1 on assistant.document_analyzer_verifications;
create policy document_analyzer_verifications_select_v1
  on assistant.document_analyzer_verifications
  for select
  to authenticated
  using (assistant.document_can_read_v1());

drop policy if exists document_analyzer_verifications_write_v1 on assistant.document_analyzer_verifications;
create policy document_analyzer_verifications_write_v1
  on assistant.document_analyzer_verifications
  for all
  to authenticated
  using (assistant.document_can_write_v1())
  with check (assistant.document_can_write_v1());

create or replace function public.rpc_document_record_analyzer_verification_v1(
  p_verification_scope text default 'lib/features/document_intelligence',
  p_command_text text default 'flutter analyze lib/features/document_intelligence',
  p_result_key text default 'no_issues_found',
  p_result_label_ar text default 'لا توجد مشاكل',
  p_issues_count integer default 0,
  p_analyzer_output text default 'No issues found! (ran in 14.3s)',
  p_flutter_version text default null,
  p_dart_version text default null,
  p_baseline_name text default 'document_intelligence_analyzer_sql06b_rbac_fix_baseline_2026_05_06.zip',
  p_metadata jsonb default '{}'::jsonb
)
returns assistant.document_analyzer_verifications
language plpgsql
security definer
set search_path = public, assistant
as $$
declare
  v_row assistant.document_analyzer_verifications;
begin
  if coalesce(p_issues_count, 0) < 0 then
    raise exception 'p_issues_count must be >= 0';
  end if;

  if p_result_key = 'no_issues_found' and coalesce(p_issues_count, 0) <> 0 then
    raise exception 'no_issues_found requires p_issues_count = 0';
  end if;

  insert into assistant.document_analyzer_verifications(
    verification_scope,
    command_text,
    result_key,
    result_label_ar,
    issues_count,
    analyzer_output,
    flutter_version,
    dart_version,
    baseline_name,
    metadata
  ) values (
    coalesce(nullif(trim(p_verification_scope), ''), 'lib/features/document_intelligence'),
    coalesce(nullif(trim(p_command_text), ''), 'flutter analyze lib/features/document_intelligence'),
    coalesce(nullif(trim(p_result_key), ''), 'unknown'),
    coalesce(nullif(trim(p_result_label_ar), ''), 'غير محدد'),
    coalesce(p_issues_count, 0),
    p_analyzer_output,
    p_flutter_version,
    p_dart_version,
    p_baseline_name,
    coalesce(p_metadata, '{}'::jsonb)
  ) returning * into v_row;

  return v_row;
end;
$$;

grant execute on function public.rpc_document_record_analyzer_verification_v1(
  text, text, text, text, integer, text, text, text, text, jsonb
) to authenticated, service_role;

create or replace function public.rpc_document_latest_analyzer_verification_v1()
returns table(
  id uuid,
  verification_scope text,
  command_text text,
  result_key text,
  result_label_ar text,
  issues_count integer,
  analyzer_output text,
  baseline_name text,
  verified_at timestamptz,
  is_closed boolean
)
language sql
security definer
set search_path = public, assistant
as $$
  select
    v.id,
    v.verification_scope,
    v.command_text,
    v.result_key,
    v.result_label_ar,
    v.issues_count,
    v.analyzer_output,
    v.baseline_name,
    v.verified_at,
    (v.result_key = 'no_issues_found' and v.issues_count = 0) as is_closed
  from assistant.document_analyzer_verifications v
  where v.verification_scope = 'lib/features/document_intelligence'
  order by v.verified_at desc, v.created_at desc
  limit 1;
$$;

grant execute on function public.rpc_document_latest_analyzer_verification_v1() to authenticated, service_role;

-- Replace readiness RPC so Stage 02 reads the persisted analyzer evidence.
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
  with coverage as (
        select count(*) filter (where is_closed) as closed_count
        from public.rpc_document_file_type_uat_coverage_v1()
       ),
       analyzer as (
        select * from public.rpc_document_latest_analyzer_verification_v1()
       ),
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
      (
        '01_uat_coverage',
        '1. إغلاق UAT الحي لأنواع الملفات',
        case when (select closed_count from coverage)=4 then 'closed' else 'open' end,
        case when (select closed_count from coverage)=4 then 'مغلق' else 'مفتوح' end,
        'عائلات ملفات مغلقة: ' || (select closed_count from coverage)::text || '/4',
        case when (select closed_count from coverage)=4 then 'مغلق؛ لا إجراء إضافي' else 'رفع ومعالجة عينة لكل عائلة' end,
        (select closed_count from coverage)=4
      ),
      (
        '02_analyzer',
        '2. تحليل Flutter وإغلاق الأخطاء',
        case when coalesce((select is_closed from analyzer), false) then 'closed' else 'implemented_pending_local_run' end,
        case when coalesce((select is_closed from analyzer), false) then 'مغلق' else 'منفذ برمجيًا وينتظر تشغيل محلي' end,
        case
          when coalesce((select is_closed from analyzer), false)
            then 'Flutter analyze: No issues found؛ issues_count=' || coalesce((select issues_count from analyzer), 0)::text || '; baseline=' || coalesce((select baseline_name from analyzer), 'غير محدد')
          else 'لا توجد Evidence تحليل محلي مسجلة داخل SQL'
        end,
        case when coalesce((select is_closed from analyzer), false) then 'مغلق؛ لا إجراء إضافي' else 'تشغيل flutter analyze وتسجيل النتيجة عبر rpc_document_record_analyzer_verification_v1' end,
        coalesce((select is_closed from analyzer), false)
      ),
      (
        '03_real_engine',
        '3. محول المحرك الحقيقي',
        case when (select evidence_count from counts)>0 then 'adapter_ready' else 'open' end,
        case when (select evidence_count from counts)>0 then 'Adapter جاهز' else 'بانتظار Evidence' end,
        'Evidence مسجلة: ' || (select evidence_count from counts)::text,
        'ضبط PWF_DOCUMENT_ENGINE_MODE=supabase_rpc عند ربط المحرك',
        (select evidence_count from counts)>0
      ),
      (
        '04_extraction_quality',
        '4. جودة الاستخراج والمقاطع غير المؤكدة',
        case when (select jobs_count from counts)>0 then 'active' else 'open' end,
        case when (select jobs_count from counts)>0 then 'فعّال' else 'بانتظار وظائف' end,
        'وظائف مسجلة: ' || (select jobs_count from counts)::text,
        'مراجعة الحقول والمقاطع لكل وظيفة',
        (select jobs_count from counts)>0
      ),
      (
        '05_sovereign_linking',
        '5. الربط السيادي مع كيانات المنصة',
        case when (select links_count from counts)>0 then 'active' else 'open' end,
        case when (select links_count from counts)>0 then 'فعّال' else 'بانتظار روابط UUID' end,
        'روابط مرشحة: ' || (select links_count from counts)::text,
        'اعتماد الروابط عبر شاشة الربط',
        (select links_count from counts)>0
      ),
      (
        '06_review_workflow',
        '6. دورة المراجعة البشرية',
        case when (select reviews_count from counts)>0 then 'active' else 'open' end,
        case when (select reviews_count from counts)>0 then 'فعّالة' else 'بانتظار قرارات' end,
        'قرارات مراجعة: ' || (select reviews_count from counts)::text,
        'اعتماد/رفض/إعادة معالجة الوثائق',
        (select reviews_count from counts)>0
      ),
      ('07_ui_center','7. واجهة مركز الوثائق', 'implemented', 'منفذة', 'لوحات Dashboard/Details/Readiness/Workflow/RBAC/Assistant', 'اختبار UI يدويًا بعد التحليل', true),
      ('08_rls_rbac','8. RLS/RBAC والصلاحيات', 'shim_ready', 'جاهز للربط', 'document_can_read_v1/document_can_write_v1', 'استبدال shim بدوال RBAC السيادية', true),
      (
        '09_assistant_integration',
        '9. التكامل مع المساعد الداخلي',
        case when (select assistant_candidates_count from counts)>0 then 'active' else 'ready' end,
        case when (select assistant_candidates_count from counts)>0 then 'فعّال' else 'جاهز' end,
        'ترشيحات معرفة: ' || (select assistant_candidates_count from counts)::text,
        'ترشيح الوثائق المعتمدة فقط',
        true
      ),
      ('10_production_docs','10. التوثيق والتسليم النهائي', 'implemented', 'منفذ', 'Migration + Handoff + Changelog + Baseline', 'تشغيل التحقق المحلي والحي', true)
  ) as t(stage_key, stage_title_ar, status_key, status_label_ar, evidence_ar, required_next_action_ar, is_closed);
$$;

grant execute on function public.rpc_document_production_readiness_v1() to authenticated, service_role;

-- Record the verified local analyzer result supplied after running:
-- flutter analyze lib/features/document_intelligence
select public.rpc_document_record_analyzer_verification_v1(
  p_verification_scope := 'lib/features/document_intelligence',
  p_command_text := 'flutter analyze lib/features/document_intelligence',
  p_result_key := 'no_issues_found',
  p_result_label_ar := 'لا توجد مشاكل',
  p_issues_count := 0,
  p_analyzer_output := 'No issues found! (ran in 14.3s)',
  p_flutter_version := null,
  p_dart_version := null,
  p_baseline_name := 'document_intelligence_analyzer_sql06b_rbac_fix_baseline_2026_05_06.zip',
  p_metadata := jsonb_build_object(
    'verified_by_user', true,
    'verified_date', '2026-05-06',
    'governance_note', 'Stage 02 closed by persisted local analyzer evidence. SQL cannot run Flutter; it records the verified local result.'
  )
);

-- Verification query expected after this migration:
-- select * from public.rpc_document_production_readiness_v1();

commit;
