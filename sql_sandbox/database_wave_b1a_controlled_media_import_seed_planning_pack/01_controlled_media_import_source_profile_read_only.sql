-- 01_controlled_media_import_source_profile_read_only.sql
-- Read-only source profile. No DML. No import.
with targets(source_schema, source_object, target_schema, target_object, content_kind, risk_note) as (
  values
    ('public','activities','media_center','content_items','activity','candidate after content type mapping'),
    ('public','announcements','media_center','content_items','announcement','candidate after publication visibility mapping'),
    ('public','breaking_news','media_center','content_items','breaking_news','high-risk visibility semantics review required'),
    ('public','media_gallery_items','media_center','content_assets','gallery_asset','asset mapping required before import'),
    ('public','news','media_center','content_items','news_legacy','review duplicate or legacy shape'),
    ('public','news_articles','media_center','content_items','news','candidate after column mapping and publication state review')
), rels as (
  select t.*, to_regclass(quote_ident(source_schema)||'.'||quote_ident(source_object)) source_regclass,
         to_regclass(quote_ident(target_schema)||'.'||quote_ident(target_object)) target_regclass
  from targets t
)
select 'controlled_media_import_source_profile' section,
       source_schema, source_object, target_schema, target_object, content_kind,
       source_regclass is not null source_exists,
       target_regclass is not null target_exists,
       coalesce(c.reltuples::bigint,0) estimated_source_rows,
       (select count(*) from information_schema.columns cols where cols.table_schema=rels.source_schema and cols.table_name=rels.source_object) source_column_count,
       risk_note,
       case when source_regclass is null then 'blocked_missing_source'
            when target_regclass is null then 'blocked_missing_target_contract'
            when source_object='breaking_news' then 'manual_visibility_semantics_required'
            when source_object='media_gallery_items' then 'asset_mapping_required'
            else 'candidate_for_mapping_review' end planning_decision
from rels left join pg_class c on c.oid=rels.source_regclass
order by source_object;
