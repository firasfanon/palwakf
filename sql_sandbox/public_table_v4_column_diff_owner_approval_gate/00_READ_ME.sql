-- Public Table Functional Reclassification v4 — Column Diff + Owner Approval Gate
-- READ ONLY. No DDL, DML, GRANT, DROP, archive, rename, or production approval.
-- Run 01 -> 06. Paste results before any apply pack is drafted.
select
  'public_table_v4_column_diff_owner_approval_gate_readme' as section,
  'Run 01 to 06. All scripts are read-only. Any future apply pack remains blocked until owner approvals and column diffs are resolved.' as note,
  false as destructive_sql_authorized,
  false as production_approved,
  true as read_only;
