-- PalWakf / Document Intelligence
-- 05B — SQL 05 live verification queries
-- يشغّل بعد تطبيق 05_document_engine_adapter_and_file_type_uat_evidence_patch.sql.

-- 1) تحقق وجود جدول Evidence.
select to_regclass('assistant.document_file_type_uat_evidence') as evidence_table;

-- 2) تحقق الأعمدة الجديدة للروابط المرشحة.
select column_name, data_type
from information_schema.columns
where table_schema = 'assistant'
  and table_name = 'document_candidate_links'
  and column_name in ('display_label', 'score')
order by column_name;

-- 3) تحقق وجود RPCs الحاكمة.
select routine_schema, routine_name
from information_schema.routines
where routine_schema = 'public'
  and routine_name in (
    'rpc_document_job_ingest_result_v1',
    'rpc_document_file_type_uat_evidence_record_v1',
    'rpc_document_job_result_v1',
    'rpc_document_file_type_uat_coverage_v1'
  )
order by routine_name;

-- 4) تغطية UAT الحية حسب عائلة الملف.
select * from public.rpc_document_file_type_uat_coverage_v1();

-- 5) حالة الإغلاق العامة: يجب أن تكون missing_families = 0 بعد رفع عينات PDF/DOCX/XLSX/DWG أو DXF.
with coverage as (
  select * from public.rpc_document_file_type_uat_coverage_v1()
)
select
  count(*) filter (where is_closed) as closed_families,
  count(*) filter (where not is_closed) as missing_families,
  jsonb_agg(file_family) filter (where not is_closed) as missing_family_keys
from coverage;
