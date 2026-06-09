-- Platform Database Ownership Closure Master Pack — 08
-- DESTRUCTIVE STEP BLOCKER READ-ONLY.
select 'legacy_archive_delete_blocker' as section,
       false as archive_delete_authorized,
       false as drop_legacy_public_tables_authorized,
       false as exact_public_table_name_replacement_authorized,
       'BLOCKED until dependency-zero + backup + explicit governance approval' as decision;
