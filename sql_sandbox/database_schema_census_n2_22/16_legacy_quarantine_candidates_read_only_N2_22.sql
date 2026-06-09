-- N2.22 READ ONLY — quarantine candidate classifier
-- No DML. No DDL.

select
  table_schema,
  table_name,
  case
    when table_schema in ('auth','storage','realtime','extensions','vault','supabase_migrations') then 'supabase_managed_do_not_touch'
    when table_name ilike 'stg_%' or table_name ilike '%staging%' then 'staging_archive_candidate'
    when table_name ilike '%backup%' or table_name ilike '%old%' then 'legacy_archive_candidate'
    when table_name ilike '%cache%' then 'cache_deprecate_before_archive'
    when table_name ilike '%uat%' or table_name ilike '%test%' then 'governance_evidence_or_test_review'
    when table_name ilike '%legacy%' then 'legacy_archive_candidate'
    else 'manual_review'
  end as recommended_classification
from information_schema.tables
where table_schema not in ('pg_catalog','information_schema')
  and table_type = 'BASE TABLE'
  and (
    table_schema in ('auth','storage','realtime','extensions','vault','supabase_migrations')
    or table_name ilike 'stg_%'
    or table_name ilike '%staging%'
    or table_name ilike '%temp%'
    or table_name ilike '%tmp%'
    or table_name ilike '%legacy%'
    or table_name ilike '%cache%'
    or table_name ilike '%backup%'
    or table_name ilike '%old%'
    or table_name ilike '%uat%'
    or table_name ilike '%test%'
  )
order by recommended_classification, table_schema, table_name;

select
  'production_gate' as section,
  'database_quarantine_plan_only' as check_key,
  true as passed,
  'This script classifies candidates but does not move or delete objects.' as note;
