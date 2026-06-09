-- 03_duplicate_key_strategy_and_public_visibility_read_only.sql
-- Read-only strategy checks. No DML.
select 'duplicate_visibility_strategy' section,
       'media_center.content_items' object_name,
       to_regclass('media_center.content_items') is not null target_exists,
       exists(select 1 from information_schema.columns where table_schema='media_center' and table_name='content_items' and column_name='metadata') has_metadata_column,
       exists(select 1 from information_schema.columns where table_schema='media_center' and table_name='content_items' and column_name in ('status','workflow_state','publication_status')) has_status_like_column,
       to_regclass('media_center.v_content_items_public_v1') is not null public_view_exists,
       'validate_nonzero_public_rows_after_seed_before_flutter_reroute' planning_decision
union all
select 'duplicate_visibility_strategy','media_center.content_assets',to_regclass('media_center.content_assets') is not null,
       exists(select 1 from information_schema.columns where table_schema='media_center' and table_name='content_assets' and column_name='metadata'),
       false,
       null::boolean,
       'asset_mapping_required_before_import';
