-- NOT AUTHORIZED FOR EXECUTION.
-- This file documents the future move pattern only.
-- It is intentionally inert and raises no changes.
-- Future authorized pattern per table:
--   create schema if not exists <target_schema>;
--   alter table public.<table> set schema <target_schema>;
--   create or replace view public.<table> as select * from <target_schema>.<table>;
--   validate functions, Flutter, RLS, grants, views;
--   keep rollback: drop view if exists public.<table>; alter table <target_schema>.<table> set schema public;
--
-- NO DDL/DML is executed by this skeleton.
select
  'future_single_consolidated_move_apply_pack_not_authorized' as section,
  false as apply_authorized,
  false as destructive_sql_authorized,
  false as production_approved,
  true as read_only;
