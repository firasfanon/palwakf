-- Mega Batch K — OPTIONAL SEED CLEANUP
-- Removes optional browser-UAT seed rows inserted by 01_platform_center_content_staging_seed_optional.sql.
-- No waqf schema mutation. No awqaf_system mutation.

begin;

delete from platform_content.center_content_items
where metadata ->> 'seed_batch' = 'mega_batch_k_2026_05_10';

commit;

select
  'remaining_seed_rows' as check_key,
  count(*) as rows_count
from platform_content.center_content_items
where metadata ->> 'seed_batch' = 'mega_batch_k_2026_05_10';
