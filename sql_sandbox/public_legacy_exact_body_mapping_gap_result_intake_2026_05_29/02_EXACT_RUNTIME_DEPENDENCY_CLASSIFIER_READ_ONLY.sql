with legacy_tables as (
  select * from (values
    ('media_center', 'public.news_articles'),
    ('media_center', 'public.announcements'),
    ('media_center', 'public.activities'),
    ('media_center', 'public.breaking_news'),
    ('media_center', 'public.media_gallery_items'),
    ('service_center', 'public.services'),
    ('service_center', 'public.servicepoints'),
    ('service_center', 'public.serviceproviders'),
    ('service_center', 'public.servicetypes')
  ) as t(domain_key, legacy_table)
),
safe_routines as (
  select
    p.oid,
    n.nspname as routine_schema,
    p.proname as routine_name,
    n.nspname || '.' || p.proname || '(' || pg_get_function_identity_arguments(p.oid) || ')' as routine_signature,
    lower(pg_get_functiondef(p.oid)) as body_lower
  from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace
  where p.prokind in ('f','p')
    and n.nspname not in ('pg_catalog', 'information_schema')
),
classified as (
  select
    lt.domain_key,
    lt.legacy_table,
    sr.routine_signature,
    case
      when sr.body_lower ~ ('\b(from|join)\s+' || replace(lower(lt.legacy_table), '.', '\.'))
        then 'exact_runtime_read_table_dependency'
      when sr.body_lower ~ ('\b(insert\s+into|update|delete\s+from)\s+' || replace(lower(lt.legacy_table), '.', '\.'))
        then 'exact_runtime_write_table_dependency'
      when sr.body_lower like '%' || lower(lt.legacy_table) || '%'
        and sr.body_lower like '%to_regclass%'
        then 'readiness_or_existence_check_reference'
      when sr.body_lower like '%' || lower(lt.legacy_table) || '%'
        then 'literal_or_textual_reference'
      when sr.body_lower like '%' || split_part(lower(lt.legacy_table), '.', 2) || '%'
        then 'term_match_only_not_exact_table_reference'
      else null
    end as reference_class,
    false as rewrite_authorized_by_this_script,
    false as destructive_sql_authorized,
    false as production_approved,
    true as read_only
  from legacy_tables lt
  join safe_routines sr
    on sr.body_lower like '%' || split_part(lower(lt.legacy_table), '.', 2) || '%'
    or sr.body_lower like '%' || lower(lt.legacy_table) || '%'
)
select *
from classified
where reference_class is not null
order by
  case reference_class
    when 'exact_runtime_write_table_dependency' then 1
    when 'exact_runtime_read_table_dependency' then 2
    when 'readiness_or_existence_check_reference' then 3
    when 'literal_or_textual_reference' then 4
    else 5
  end,
  domain_key,
  legacy_table,
  routine_signature;
