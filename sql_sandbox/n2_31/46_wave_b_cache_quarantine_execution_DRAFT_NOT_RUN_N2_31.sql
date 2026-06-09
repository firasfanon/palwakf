-- PalWakf Platform — N2.31
-- 46_wave_b_cache_quarantine_execution_DRAFT_NOT_RUN_N2_31.sql
-- DRAFT NOT RUN.
-- Purpose: Candidate quarantine draft for public.org_units_cache and public.pwf_org_units_cache.
-- DO NOT RUN unless SQL 45 is reviewed and an explicit N2.32 execution decision is issued.

-- Guard: this script intentionally refuses to run unless this setting is explicitly enabled in the same DB session.
-- Example only after approval:
-- select set_config('app.n2_31_execute_cache_quarantine', 'approved-n2-32', false);

do $$
begin
  if current_setting('app.n2_31_execute_cache_quarantine', true) is distinct from 'approved-n2-32' then
    raise exception 'N2.31 draft is blocked. Run SQL 45, review dependencies, and approve N2.32 before execution.';
  end if;
end $$;

-- Draft execution plan after guard approval:
-- 1. create schema if not exists legacy_archive;
-- 2. alter table public.org_units_cache set schema legacy_archive;
-- 3. alter table public.pwf_org_units_cache set schema legacy_archive;
-- 4. create compatibility views in public, read-only by default:
--    create or replace view public.org_units_cache as select * from legacy_archive.org_units_cache;
--    create or replace view public.pwf_org_units_cache as select * from legacy_archive.pwf_org_units_cache;
-- 5. comment migrated objects and views.

-- The actual commands remain commented until N2.32 approval.
