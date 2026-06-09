-- N2.26 READ ONLY: Media + Services Ownership Audit
select
  'media_services_ownership_wave2' as section,
  case
    when t.table_name in ('activities','announcement_items','announcements','breaking_news','media_gallery_items','news','news_articles','news_items','media_center_audit_events','media_center_editorial_events','media_center_editorial_roles','media_center_publishing_governance_rules','media_center_permission_uat_events') then 'media'
    when t.table_name in ('home_services','servicepoints','serviceproviders','services','servicetypes') then 'services'
    else 'manual'
  end as family,
  t.table_schema,
  t.table_name,
  t.table_type,
  case
    when t.table_name in ('activities','announcement_items','announcements','breaking_news','media_gallery_items','news','news_articles','news_items','media_center_audit_events','media_center_editorial_events','media_center_editorial_roles','media_center_publishing_governance_rules') then 'media_center'
    when t.table_name='media_center_permission_uat_events' then 'media_center_or_governance'
    when t.table_name in ('services') then 'platform_services'
    when t.table_name='home_services' then 'platform_services_or_platform_content'
    when t.table_name in ('servicepoints','serviceproviders','servicetypes') then 'platform_services_or_facilities_module'
    else 'manual_review'
  end as proposed_owner,
  coalesce((select count(*) from pg_policies p where p.schemaname=t.table_schema and p.tablename=t.table_name),0) as rls_policy_count,
  case
    when coalesce((select count(*) from pg_policies p where p.schemaname=t.table_schema and p.tablename=t.table_name),0) > 0 then 'do_not_move_without_rls_migration_plan'
    else 'manual_review_before_move'
  end as movement_gate
from information_schema.tables t
where t.table_schema='public'
  and t.table_name in (
    'activities','announcement_items','announcements','breaking_news','media_gallery_items','news','news_articles','news_items',
    'media_center_audit_events','media_center_editorial_events','media_center_editorial_roles','media_center_publishing_governance_rules','media_center_permission_uat_events',
    'home_services','servicepoints','serviceproviders','services','servicetypes'
  )
order by family, t.table_name;
