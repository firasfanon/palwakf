-- Mega Batch N2.29
-- Read-only dependency matrix for Wave A candidates.

with candidate_tables(schema_name, table_name, family) as (
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
    ('public','former_ministers','site_content'),
    ('public','pwf_former_ministers','site_content'),
    ('public','activities','media_center'),
    ('public','announcements','media_center'),
    ('public','breaking_news','media_center'),
    ('public','media_gallery_items','media_center'),
    ('public','news_articles','media_center'),
    ('public','media_center_audit_events','media_center'),
    ('public','media_center_editorial_events','media_center'),
    ('public','media_center_editorial_roles','media_center'),
    ('public','media_center_publishing_governance_rules','media_center'),
    ('public','services','services'),
    ('public','home_services','services'),
    ('public','servicepoints','services'),
    ('public','serviceproviders','services'),
    ('public','servicetypes','services'),
    ('public','locations','locations'),
    ('public','org_units_cache','legacy_cache'),
    ('public','pwf_org_units_cache','legacy_cache')
), base as (
  select
    ct.family,
    ct.schema_name,
    ct.table_name,
    c.oid as table_oid
  from candidate_tables ct
  join pg_namespace n on n.nspname = ct.schema_name
  join pg_class c on c.relnamespace = n.oid and c.relname = ct.table_name
)
select
  b.family,
  b.schema_name,
  b.table_name,
  coalesce((
    select count(*)
    from pg_depend d
    join pg_rewrite r on r.oid = d.objid
    join pg_class v on v.oid = r.ev_class
    where d.refobjid = b.table_oid
      and v.relkind in ('v','m')
  ), 0) as dependent_view_count,
  coalesce((
    select count(*)
    from pg_constraint con
    where con.confrelid = b.table_oid
       or con.conrelid = b.table_oid
  ), 0) as fk_related_count,
  coalesce((
    select count(*)
    from pg_policies pol
    where pol.schemaname = b.schema_name
      and pol.tablename = b.table_name
  ), 0) as rls_policy_count,
  case
    when b.family = 'legacy_cache' then 'archive_candidate_after_usage_zero'
    when coalesce((select count(*) from pg_policies pol where pol.schemaname=b.schema_name and pol.tablename=b.table_name),0) > 0 then 'do_not_move_without_rls_migration_plan'
    else 'manual_review_before_move'
  end as movement_gate
from base b
order by family, schema_name, table_name;

select
  'sovereign_boundary' as section,
  'no_waq_assets_mutation_in_this_script' as check_key,
  true as passed,
  'Read-only dependency audit only; no waqf/waqf_assets/awqaf_system DML.' as note;
