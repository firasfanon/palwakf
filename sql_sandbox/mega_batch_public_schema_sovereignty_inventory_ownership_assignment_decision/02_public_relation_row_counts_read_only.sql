
-- Script 02: Public table/view row-count profile read-only
-- Purpose: exact counts for public relations using guarded dynamic read-only calls.

with rels as (
  select
    n.nspname,
    c.relname,
    case c.relkind
      when 'r' then 'table'
      when 'p' then 'partitioned_table'
      when 'v' then 'view'
      when 'm' then 'materialized_view'
      else c.relkind::text
    end as object_type,
    c.relkind
  from pg_catalog.pg_class c
  join pg_catalog.pg_namespace n on n.oid = c.relnamespace
  where n.nspname = 'public'
    and c.relkind in ('r','p','v','m')
), counts as (
  select
    rels.object_type,
    rels.relname as object_name,
    case
      when rels.relkind in ('r','p','v','m') then
        coalesce((xpath('/row/count/text()', query_to_xml(format('select count(*) as count from %I.%I', rels.nspname, rels.relname), false, true, '')))[1]::text::bigint, 0)
      else null::bigint
    end as exact_row_count
  from rels
)
select
  'public_relation_row_counts' as section,
  object_type,
  object_name,
  exact_row_count,
  case
    when object_name like 'v_%' then 'wrapper_or_view_candidate'
    when exact_row_count = 0 then 'empty_or_reference_candidate'
    else 'data_present_requires_owner_assignment'
  end as inventory_note
from counts
order by object_type, object_name;
