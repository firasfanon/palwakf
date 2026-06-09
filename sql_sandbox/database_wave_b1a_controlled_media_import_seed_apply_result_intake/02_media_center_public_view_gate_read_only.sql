-- 02: Published-only media_center public view validation (read-only).
select 'media_center_public_view_gate' as section,
       count(*)::bigint as public_view_rows,
       count(*) filter (where status = 'published')::bigint as published_rows,
       count(*) filter (where status <> 'published')::bigint as non_published_rows,
       case
         when count(*) filter (where status <> 'published') = 0 then 'published_only_contract_ok'
         else 'published_only_contract_failed'
       end as decision
from media_center.v_content_items_public_v1;
