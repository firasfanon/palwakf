-- PalWakf Platform — N2.31
-- 47_wave_b_cache_quarantine_rollback_DRAFT_NOT_RUN_N2_31.sql
-- DRAFT NOT RUN.
-- Purpose: Rollback draft if cache quarantine is executed in N2.32 and must be reversed.

-- Guard: this script intentionally refuses to run unless this setting is explicitly enabled in the same DB session.
-- Example only after approval:
-- select set_config('app.n2_31_rollback_cache_quarantine', 'approved-rollback', false);

do $$
begin
  if current_setting('app.n2_31_rollback_cache_quarantine', true) is distinct from 'approved-rollback' then
    raise exception 'N2.31 rollback draft is blocked. Approve rollback before execution.';
  end if;
end $$;

-- Draft rollback plan after guard approval:
-- 1. drop view if exists public.org_units_cache;
-- 2. drop view if exists public.pwf_org_units_cache;
-- 3. alter table legacy_archive.org_units_cache set schema public;
-- 4. alter table legacy_archive.pwf_org_units_cache set schema public;
-- 5. rerun public.org_units compatibility view UAT to ensure it remains core-backed.

-- The actual commands remain commented until an approved rollback event.
