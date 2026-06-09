-- N2.26 READ ONLY: Site Content Ownership Audit
select
  'site_content_ownership_audit' as section,
  t.table_schema,
  t.table_name,
  t.table_type,
  case
    when t.table_name in ('site_pages','homepage_sections','home_config','header_settings','footer_settings','hero_slides','home_hero_slides','home_stats','site_settings','app_settings','former_ministers','pwf_former_ministers') then 'site_content_candidate'
    when t.table_name in ('friday_sermons','islamic_terms','social_notices') then 'site_content_or_media_manual_review'
    else 'manual_review'
  end as proposed_owner,
  coalesce((select count(*) from pg_policies p where p.schemaname=t.table_schema and p.tablename=t.table_name),0) as rls_policy_count
from information_schema.tables t
where t.table_schema='public'
  and t.table_name in (
    'site_pages','homepage_sections','home_config','header_settings','footer_settings','hero_slides','home_hero_slides','home_stats','site_settings','app_settings','former_ministers','pwf_former_ministers','friday_sermons','islamic_terms','social_notices'
  )
order by t.table_name;
