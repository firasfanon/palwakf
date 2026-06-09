-- N2.28 READ ONLY
-- Dependency matrix for Wave 1 candidates. No mutations.
with candidates(table_schema, table_name, proposed_owner) as (
  values
    ('public','site_pages','site_content'),
    ('public','homepage_sections','site_content'),
    ('public','home_config','site_content'),
    ('public','header_settings','site_content'),
    ('public','footer_settings','site_content'),
    ('public','hero_slides','site_content'),
    ('public','home_hero_slides','site_content'),
    ('public','home_stats','site_content'),
    ('public','site_settings','site_content'),
    ('public','app_settings','site_content'),
    ('public','activities','media_center'),
    ('public','announcements','media_center'),
    ('public','announcement_items','media_center'),
    ('public','breaking_news','media_center'),
    ('public','media_gallery_items','media_center'),
    ('public','news','media_center'),
    ('public','news_articles','media_center'),
    ('public','news_items','media_center'),
    ('public','services','platform_services'),
    ('public','home_services','platform_services_or_platform_content'),
    ('public','servicepoints','platform_services_or_facilities_module'),
    ('public','serviceproviders','platform_services_or_facilities_module'),
    ('public','servicetypes','platform_services_or_facilities_module')
), cls as (
  select n.nspname, c.relname, c.oid
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
)
select
  cand.table_schema,
  cand.table_name,
  cand.proposed_owner,
  coalesce((select count(*) from pg_policies p where p.schemaname=cand.table_schema and p.tablename=cand.table_name),0) as rls_policy_count,
  coalesce((
    select count(*)
    from pg_depend d
    join pg_rewrite r on r.oid = d.objid
    join pg_class dv on dv.oid = r.ev_class
    join pg_namespace dns on dns.oid = dv.relnamespace
    join cls src on src.oid = d.refobjid
    where src.nspname = cand.table_schema and src.relname = cand.table_name
  ),0) as dependent_view_count,
  coalesce((
    select count(*)
    from information_schema.constraint_column_usage ccu
    where ccu.table_schema = cand.table_schema
      and ccu.table_name = cand.table_name
  ),0) as referenced_by_fk_count,
  'READ_ONLY_NO_MOVEMENT' as movement_gate
from candidates cand
order by proposed_owner, table_name;
