-- NOT AUTHORIZED. Skeleton only.
-- Future single consolidated apply pack must not run until:
-- 1) column diff is reviewed for every sensitive table;
-- 2) owner approvals are provided;
-- 3) 53 structural view dependencies are rewritten or accepted as wrappers;
-- 4) Flutter direct dependency scan is clean;
-- 5) backup/reversal reference is recorded;
-- 6) RLS/Role UAT passes.
select
  'future_single_apply_pack_skeleton_not_authorized' as section,
  false as create_schema_authorized,
  false as create_table_authorized,
  false as insert_authorized,
  false as update_authorized,
  false as delete_authorized,
  false as drop_authorized,
  false as archive_authorized,
  false as production_approved,
  true as read_only;
