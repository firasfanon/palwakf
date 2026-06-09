-- Mega Batch N2.36
-- 58_media_services_wave_c_candidate_matrix_READ_ONLY_N2_36.sql
-- Purpose: prepare Wave C candidate matrix without moving media/services tables.
-- Safety: read-only. No waqf/waqf_assets/awqaf_system mutation.

with candidates as (
  select * from (values
    ('media_center'::text, 'public'::text, 'news_articles'::text, 'editorial_content'::text, 'defer_wave_c'),
    ('media_center'::text, 'public'::text, 'announcements'::text, 'editorial_content'::text, 'defer_wave_c'),
    ('media_center'::text, 'public'::text, 'activities'::text, 'editorial_content'::text, 'defer_wave_c'),
    ('media_center'::text, 'public'::text, 'media_gallery_items'::text, 'media_assets'::text, 'defer_wave_c'),
    ('media_center'::text, 'public'::text, 'breaking_news'::text, 'urgent_content'::text, 'defer_wave_c'),
    ('platform_services'::text, 'public'::text, 'services'::text, 'service_catalog'::text, 'candidate_after_taxonomy_review'),
    ('platform_services'::text, 'public'::text, 'home_services'::text, 'homepage_service_cards'::text, 'candidate_after_taxonomy_review'),
    ('platform_services_or_facilities_module'::text, 'public'::text, 'servicepoints'::text, 'physical_service_points'::text, 'manual_review'),
    ('platform_services_or_facilities_module'::text, 'public'::text, 'serviceproviders'::text, 'provider_registry'::text, 'manual_review'),
    ('platform_services_or_facilities_module'::text, 'public'::text, 'servicetypes'::text, 'service_taxonomy'::text, 'manual_review')
  ) as v(recommended_owner_schema, source_schema, object_name, object_family, n2_36_decision)
), relation_state as (
  select
    c.*,
    pc.oid as relation_oid,
    pc.relkind,
    pc.oid is not null as relation_exists
  from candidates c
  left join pg_namespace pn on pn.nspname = c.source_schema
  left join pg_class pc on pc.relnamespace = pn.oid and pc.relname = c.object_name
), function_hits as (
  select
    rs.object_name,
    count(distinct p.oid) as function_text_hit_count
  from relation_state rs
  left join pg_proc p
    on p.prokind in ('f','p')
   and exists (
     select 1 from pg_namespace pn
     where pn.oid = p.pronamespace
       and pn.nspname not in ('pg_catalog','information_schema')
       and pn.nspname not like 'pg_toast%'
       and coalesce(pg_get_functiondef(p.oid), '') ~* ('\m' || rs.object_name || '\M')
   )
  group by rs.object_name
), columns_summary as (
  select
    rs.object_name,
    count(a.attnum) filter (where a.attnum > 0 and not a.attisdropped) as column_count,
    string_agg(a.attname, ', ' order by a.attnum) filter (where a.attnum > 0 and not a.attisdropped) as column_order
  from relation_state rs
  left join pg_attribute a on a.attrelid = rs.relation_oid
  group by rs.object_name
)
select
  rs.recommended_owner_schema as section,
  rs.object_name as check_key,
  rs.source_schema,
  rs.object_family,
  rs.n2_36_decision,
  rs.relation_exists,
  case rs.relkind
    when 'r' then 'table'
    when 'p' then 'partitioned_table'
    when 'v' then 'view'
    when 'm' then 'materialized_view'
    else coalesce(rs.relkind::text, 'missing')
  end as relation_kind,
  coalesce(cs.column_count, 0) as column_count,
  coalesce(cs.column_order, '') as column_order,
  coalesce(fh.function_text_hit_count, 0) as function_text_hit_count,
  false as execute_in_n2_36,
  true as no_waq_assets_mutation_in_this_script,
  case
    when rs.recommended_owner_schema = 'media_center' then 'Wave C only: editorial workflow/RLS/RPC compatibility must be designed before moving.'
    when rs.recommended_owner_schema = 'platform_services' then 'Candidate after service taxonomy and public tracking privacy review.'
    else 'Manual review: may belong to platform_services or facilities_module.'
  end as note
from relation_state rs
left join columns_summary cs using (object_name)
left join function_hits fh using (object_name)
order by rs.recommended_owner_schema, rs.object_name;
