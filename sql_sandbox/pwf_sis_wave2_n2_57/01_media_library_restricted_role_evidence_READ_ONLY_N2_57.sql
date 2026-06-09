/*
PWF-SIS Wave 2 / N2.57
Media Library Restricted Role Evidence Helper
READ ONLY — no DDL, no DML.

Purpose:
- help inspect whether route/access contract tables exist,
- inspect media-center-related route/access records where present,
- preserve sovereign boundaries.
*/

with sovereign_boundary as (
  select
    'sovereign_boundary'::text as section,
    'no_waq_assets_mutation_in_this_script'::text as check_key,
    true as passed,
    'Read-only evidence only; no DDL/DML; no waqf/waqf_assets/awqaf_system mutation.'::text as note
),
route_presence as (
  select
    'route_presence'::text as section,
    'media_library_route_text_presence'::text as check_key,
    exists (
      select 1
      from information_schema.routines r
      where r.specific_schema not in ('pg_catalog', 'information_schema')
        and coalesce(r.routine_definition, '') ilike '%/admin/media-center/media-library%'
    ) as passed,
    'Best-effort text discovery in routine definitions only; Flutter route evidence remains primary.'::text as note
),
table_presence as (
  select
    'table_presence'::text as section,
    'platform_registry_tables_discovery'::text as check_key,
    exists (
      select 1
      from information_schema.tables
      where table_schema = 'platform'
        and table_name in ('system_registry', 'system_sections')
    ) as passed,
    'Checks whether platform registry tables exist.'::text as note
)
select * from sovereign_boundary
union all
select * from route_presence
union all
select * from table_presence;
