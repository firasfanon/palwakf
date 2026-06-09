select * from (
  select 'activities_wrapper_nonzero' as check_key,
         (select count(*) from public.v_media_activities_compat_v1)::bigint as value,
         case when (select count(*) from public.v_media_activities_compat_v1) > 0 then 'candidate_after_browser_uat' else 'blocked_zero_public_wrapper_rows' end as decision
  union all
  select 'gallery_wrapper_nonzero', (select count(*) from public.v_media_gallery_compat_v1),
         case when (select count(*) from public.v_media_gallery_compat_v1) > 0 then 'candidate_after_asset_mapping_uat' else 'blocked_until_asset_content_mapping' end
  union all
  select 'content_assets_rows', (select count(*) from media_center.content_assets),
         case when (select count(*) from media_center.content_assets) > 0 then 'asset_mapping_available' else 'asset_mapping_missing' end
  union all
  select 'public_gallery_rows', (select count(*) from public.media_gallery_items),
         'source_inventory_only_no_reroute_decision_by_itself'
) s
order by check_key;
