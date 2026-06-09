-- Database Wave B-1A Media Public View Publication Safety — READ ONLY
select 'media_public_view_publication_safety' as section,
  'media_center.v_content_items_public_v1' as contract_name,
  to_regclass('media_center.v_content_items_public_v1') is not null as contract_exists,
  case when to_regclass('media_center.v_content_items_public_v1') is not null then (select count(*) from media_center.v_content_items_public_v1) else 0 end as visible_row_count,
  'Published-only facade exists; after empty bootstrap visible_row_count should normally be 0.' as note;
