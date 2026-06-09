-- Public Runtime Console Root-Cause Source Contract Audit — READ ONLY
select 'public_runtime_console_source_contract' as section,
       'header_settings' as contract_name,
       exists(select 1 from information_schema.tables where table_schema='public' and table_name='header_settings') as present
union all
select 'public_runtime_console_source_contract','footer_settings',
       exists(select 1 from information_schema.tables where table_schema='public' and table_name='footer_settings')
union all
select 'public_runtime_console_source_contract','v_platform_center_content',
       exists(select 1 from information_schema.views where table_schema='public' and table_name='v_platform_center_content')
union all
select 'public_runtime_console_source_contract','media_gallery_items',
       exists(select 1 from information_schema.tables where table_schema='public' and table_name='media_gallery_items');
