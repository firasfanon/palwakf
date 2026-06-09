-- N2.25 - Public Schema Quarantine Wave 2 Candidate Audit
-- READ ONLY. No DML.

with public_tables as (
  select table_schema, table_name
  from information_schema.tables
  where table_schema='public'
    and table_type='BASE TABLE'
),
signals as (
  select
    p.table_schema,
    p.table_name,
    case
      when p.table_name ilike '%cache%' then 'cache'
      when p.table_name ilike '%backup%' or p.table_name ilike '%old%' or p.table_name ilike '%legacy%' then 'legacy'
      when p.table_name ilike '%uat%' or p.table_name ilike '%test%' then 'uat_evidence'
      when p.table_name in ('news','news_articles','news_items','announcements','announcement_items','activities','media_gallery_items','breaking_news') then 'media_candidate'
      when p.table_name in ('services','servicepoints','serviceproviders','servicetypes','home_services') then 'services_candidate'
      when p.table_name in ('platform_systems','platform_permissions','user_system_roles','user_system_permissions') then 'rbac_transitional'
      when p.table_name = 'locations' then 'locations_unresolved'
      else 'manual_review'
    end as classification_signal
  from public_tables p
)
select
  'public_quarantine_wave2' as section,
  table_schema,
  table_name,
  classification_signal,
  case
    when classification_signal='cache' then 'archive_candidate_after_dependency_and_flutter_check'
    when classification_signal='media_candidate' then 'target_media_center_after_migration_plan'
    when classification_signal='services_candidate' then 'target_platform_services_after_mapping_plan'
    when classification_signal='rbac_transitional' then 'do_not_move_before_rbac_migration'
    when classification_signal='locations_unresolved' then 'locations_deep_audit_required'
    else 'manual_review'
  end as recommended_gate
from signals
order by classification_signal, table_name;
