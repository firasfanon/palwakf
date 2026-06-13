-- Platform 12 — Homepage Sections Duplicate Remediation Guarded Pack
-- DO NOT RUN 02 unless explicitly authorized by the platform owner/operator.
-- 01 and 03 are read-only diagnostics.
-- 02 is DML and is intentionally guarded by an approval token.
-- No DDL / GRANT / REVOKE / DROP / TRUNCATE is included.

select
  'platform12_homepage_sections_duplicate_remediation_guarded_read_me' as section,
  false as run_write_without_operator_authorization,
  'Run 01 first. Run 02 only after setting pwf.operator_approval_token to the exact token documented in 02. Run 03 after any authorized write.' as instruction;
