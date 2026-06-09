-- Database Wave B-1A — Controlled Media Import/Seed Contract Review
-- 01: Read-only replay of source/target readiness. No DML.

with targets as (
  select * from (values
    ('public','activities','media_center','content_items','activity','candidate_for_mapping_review'),
    ('public','announcements','media_center','content_items','announcement','candidate_for_mapping_review'),
    ('public','news_articles','media_center','content_items','news','candidate_for_mapping_review'),
    ('public','breaking_news','media_center','content_items','breaking_news','manual_visibility_semantics_required'),
    ('public','media_gallery_items','media_center','content_assets','gallery_asset','asset_mapping_required'),
    ('public','news','media_center','content_items','news_legacy','duplicate_or_legacy_shape_review_required')
  ) as t(source_schema, source_object, target_schema, target_object, content_kind, planning_decision)
), cols as (
  select table_schema, table_name, count(*)::int as column_count
  from information_schema.columns
  group by table_schema, table_name
), estimates as (
  select n.nspname as schema_name, c.relname as object_name, greatest(c.reltuples::bigint, -1) as estimated_rows
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  where c.relkind in ('r','p')
)
select
  'controlled_media_import_contract_review' as section,
  t.source_schema,
  t.source_object,
  t.target_schema,
  t.target_object,
  t.content_kind,
  to_regclass(format('%I.%I', t.source_schema, t.source_object)) is not null as source_exists,
  to_regclass(format('%I.%I', t.target_schema, t.target_object)) is not null as target_exists,
  coalesce(e.estimated_rows, -1) as estimated_source_rows,
  coalesce(c.column_count, 0) as source_column_count,
  t.planning_decision
from targets t
left join cols c on c.table_schema=t.source_schema and c.table_name=t.source_object
left join estimates e on e.schema_name=t.source_schema and e.object_name=t.source_object
order by t.content_kind;
