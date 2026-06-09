-- Read-only public content category inventory. This script is shape-aware.
do $$ begin end $$;
with v as (
  select to_regclass('public.v_platform_center_content') as rel
), cols as (
  select column_name
  from information_schema.columns
  where table_schema='public' and table_name='v_platform_center_content'
), result as (
  select
    'public.v_platform_center_content'::text as contract_name,
    (select rel is not null from v) as present,
    exists(select 1 from cols where column_name in ('category_key','category')) as has_category_column,
    exists(select 1 from cols where column_name in ('status','publication_status')) as has_status_column,
    exists(select 1 from cols where column_name in ('title_ar','title')) as has_title_column
)
select 'platform_center_public_page_content_shape' as section, * from result;
