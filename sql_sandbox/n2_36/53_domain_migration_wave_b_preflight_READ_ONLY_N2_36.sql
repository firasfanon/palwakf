-- Mega Batch N2.36
-- 53_domain_migration_wave_b_preflight_READ_ONLY_N2_36.sql
-- Purpose: one read-only result set for cache quarantine + first real migration candidate selection.
-- Safety: READ ONLY. No DDL, no DML, no waqf/waqf_assets/awqaf_system mutation.

with target_objects as (
  select * from (values
    ('cache_quarantine'::text, 'public'::text, 'org_units_cache'::text, 'legacy_archive'::text, 'quarantine_if_strict_gate_passes'::text),
    ('cache_quarantine'::text, 'public'::text, 'pwf_org_units_cache'::text, 'legacy_archive'::text, 'quarantine_if_strict_gate_passes'::text),
    ('site_content_migration'::text, 'public'::text, 'header_settings'::text, 'site_content'::text, 'first_real_migration_candidate'::text),
    ('site_content_migration'::text, 'public'::text, 'footer_settings'::text, 'site_content'::text, 'first_real_migration_candidate'::text),
    ('media_center_review'::text, 'public'::text, 'media_gallery_items'::text, 'media_center'::text, 'defer_wave_c_dependency_review'::text),
    ('media_center_review'::text, 'public'::text, 'news_articles'::text, 'media_center'::text, 'defer_wave_c_editorial_contract_review'::text),
    ('services_review'::text, 'public'::text, 'services'::text, 'platform_services'::text, 'defer_service_taxonomy_review'::text),
    ('services_review'::text, 'public'::text, 'servicepoints'::text, 'platform_services_or_facilities_module'::text, 'manual_ownership_review'::text),
    ('services_review'::text, 'public'::text, 'serviceproviders'::text, 'platform_services_or_facilities_module'::text, 'manual_ownership_review'::text),
    ('services_review'::text, 'public'::text, 'servicetypes'::text, 'platform_services_or_facilities_module'::text, 'manual_ownership_review'::text)
  ) as v(domain_key, source_schema, object_name, recommended_owner_schema, intended_action)
), relation_state as (
  select
    t.*,
    c.oid as relation_oid,
    c.relkind,
    case c.relkind
      when 'r' then 'table'
      when 'p' then 'partitioned_table'
      when 'v' then 'view'
      when 'm' then 'materialized_view'
      else coalesce(c.relkind::text, 'missing')
    end as relation_kind,
    c.oid is not null as relation_exists
  from target_objects t
  left join pg_namespace n on n.nspname = t.source_schema
  left join pg_class c on c.relnamespace = n.oid and c.relname = t.object_name
), view_deps as (
  select
    rs.domain_key,
    rs.source_schema,
    rs.object_name,
    count(distinct dep_view.oid) filter (where dep_view.relkind = 'v') as view_dependency_count,
    count(distinct dep_view.oid) filter (where dep_view.relkind = 'm') as matview_dependency_count
  from relation_state rs
  left join pg_depend d on d.refobjid = rs.relation_oid
  left join pg_rewrite r on r.oid = d.objid
  left join pg_class dep_view on dep_view.oid = r.ev_class and dep_view.oid <> rs.relation_oid
  group by rs.domain_key, rs.source_schema, rs.object_name
), fk_deps as (
  select
    rs.domain_key,
    rs.source_schema,
    rs.object_name,
    count(*) filter (where con.oid is not null) as fk_dependency_count
  from relation_state rs
  left join pg_constraint con
    on con.contype = 'f'
   and (con.conrelid = rs.relation_oid or con.confrelid = rs.relation_oid)
  group by rs.domain_key, rs.source_schema, rs.object_name
), policy_state as (
  select
    rs.domain_key,
    rs.source_schema,
    rs.object_name,
    count(pol.oid) as policy_count
  from relation_state rs
  left join pg_policy pol on pol.polrelid = rs.relation_oid
  group by rs.domain_key, rs.source_schema, rs.object_name
), trigger_state as (
  select
    rs.domain_key,
    rs.source_schema,
    rs.object_name,
    count(tg.oid) filter (where tg.oid is not null and not tg.tgisinternal) as trigger_count
  from relation_state rs
  left join pg_trigger tg on tg.tgrelid = rs.relation_oid
  group by rs.domain_key, rs.source_schema, rs.object_name
), function_hits as (
  select
    rs.domain_key,
    rs.source_schema,
    rs.object_name,
    count(distinct p.oid) as function_text_hit_count
  from relation_state rs
  left join pg_proc p
    on p.prokind in ('f','p')
   and exists (
     select 1
     from pg_namespace pn
     where pn.oid = p.pronamespace
       and pn.nspname not in ('pg_catalog','information_schema')
       and pn.nspname not like 'pg_toast%'
       and coalesce(pg_get_functiondef(p.oid), '') ~* ('\\m' || rs.object_name || '\\M')
   )
  group by rs.domain_key, rs.source_schema, rs.object_name
), column_state as (
  select
    rs.domain_key,
    rs.source_schema,
    rs.object_name,
    count(a.attnum) filter (where a.attnum > 0 and not a.attisdropped) as column_count,
    string_agg(a.attname, ', ' order by a.attnum) filter (where a.attnum > 0 and not a.attisdropped) as column_order
  from relation_state rs
  left join pg_attribute a on a.attrelid = rs.relation_oid
  group by rs.domain_key, rs.source_schema, rs.object_name
), public_org_units_view as (
  select
    exists (
      select 1
      from information_schema.views v
      where v.table_schema = 'public'
        and v.table_name = 'org_units'
        and not (coalesce(v.view_definition, '') ~* '\\morg_units_cache\\M')
        and not (coalesce(v.view_definition, '') ~* '\\mpwf_org_units_cache\\M')
    ) as public_org_units_not_cache_backed
), sovereign_boundary as (
  select true as no_waq_assets_mutation_in_this_script
)
select
  rs.domain_key as section,
  rs.object_name as check_key,
  rs.source_schema,
  rs.recommended_owner_schema,
  rs.intended_action,
  rs.relation_exists,
  rs.relation_kind,
  coalesce(cs.column_count, 0) as column_count,
  coalesce(cs.column_order, '') as column_order,
  coalesce(vd.view_dependency_count, 0) as view_dependency_count,
  coalesce(vd.matview_dependency_count, 0) as matview_dependency_count,
  coalesce(fd.fk_dependency_count, 0) as fk_dependency_count,
  coalesce(ps.policy_count, 0) as policy_count,
  coalesce(ts.trigger_count, 0) as trigger_count,
  coalesce(fh.function_text_hit_count, 0) as function_text_hit_count,
  (select public_org_units_not_cache_backed from public_org_units_view) as public_org_units_not_cache_backed,
  case
    when rs.domain_key = 'cache_quarantine' then
      rs.relation_exists
      and rs.relkind in ('r','p')
      and coalesce(vd.view_dependency_count, 0) = 0
      and coalesce(vd.matview_dependency_count, 0) = 0
      and coalesce(fd.fk_dependency_count, 0) = 0
      and coalesce(ps.policy_count, 0) = 0
      and coalesce(ts.trigger_count, 0) = 0
      and coalesce(fh.function_text_hit_count, 0) = 0
      and (select public_org_units_not_cache_backed from public_org_units_view)
    when rs.domain_key = 'site_content_migration' then
      rs.relation_exists
      and rs.relkind in ('r','p')
      and coalesce(vd.view_dependency_count, 0) = 0
      and coalesce(vd.matview_dependency_count, 0) = 0
    else false
  end as execute_candidate_gate_passed,
  (select no_waq_assets_mutation_in_this_script from sovereign_boundary) as no_waq_assets_mutation_in_this_script,
  case
    when rs.domain_key = 'cache_quarantine' then 'Run SQL54 only if this row gate is true for both cache candidates.'
    when rs.domain_key = 'site_content_migration' then 'Run SQL55 only for the selected site_content candidates if both site rows pass.'
    when rs.domain_key = 'media_center_review' then 'Deferred: media workflow and editorial contracts need Wave C.'
    when rs.domain_key = 'services_review' then 'Deferred: services ownership remains split with facilities_module/manual review.'
    else 'review'
  end as note
from relation_state rs
left join view_deps vd using (domain_key, source_schema, object_name)
left join fk_deps fd using (domain_key, source_schema, object_name)
left join policy_state ps using (domain_key, source_schema, object_name)
left join trigger_state ts using (domain_key, source_schema, object_name)
left join function_hits fh using (domain_key, source_schema, object_name)
left join column_state cs using (domain_key, source_schema, object_name)
order by
  case rs.domain_key
    when 'cache_quarantine' then 1
    when 'site_content_migration' then 2
    when 'media_center_review' then 3
    when 'services_review' then 4
    else 9
  end,
  rs.object_name;
