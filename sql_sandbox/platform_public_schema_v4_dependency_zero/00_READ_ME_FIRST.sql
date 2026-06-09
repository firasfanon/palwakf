/*
Platform Public Schema V4 — Dependency-Zero Evidence Closure + No-New-Public-Base-Tables Gate

Arabic task description:
هذه فحوصات read-only فقط لجمع أدلة اعتماد المنصة على public، وليست تفويضًا للترحيل أو الحذف أو إنشاء الجداول.

Authorized: SELECT/read-only catalog queries only.
Blocked: DDL, DML, GRANT, REVOKE, DROP, ARCHIVE, RENAME, CREATE TABLE public.*, production approval.
*/

select
  'platform_public_schema_v4_read_me_first' as section,
  'READ_ONLY_EVIDENCE_CLOSURE_ONLY' as execution_mode,
  false as ddl_dml_authorized,
  false as grant_revoke_authorized,
  false as production_approved,
  true as read_only,
  'Run 01-07 only. Do not run write, archive, drop, rename, grant/revoke, or public base table creation.' as instruction;
