-- Database Ownership Phase B — Media guarded sync candidate.
-- DRAFT_NOT_RUN. This script intentionally fails closed.
-- Do not replace the token unless a later package explicitly approves exact body, backup/restore point, and browser UAT evidence.

do $$
begin
  if coalesce(current_setting('request.palwakf_phase_b_media_token', true), '') <> 'PALWAKF_PHASE_B_MEDIA_CENTER_SYNC_AUTHORIZED_REPLACE_ONLY_AFTER_APPROVAL' then
    raise exception 'BLOCKED: Phase B media sync candidate is not authorized. Run read-only SQL 01/02/03/04/06/07 first and attach approval evidence.';
  end if;
end $$;

-- Candidate body is deliberately not implemented in this entry pack.
-- Future exact body must be generated only after:
-- 1. SQL 01/03 confirm source and owner surfaces.
-- 2. Exact source/target column mapping is reviewed.
-- 3. Backup/restore point is documented.
-- 4. Browser UAT is clean for public/admin media routes.
-- 5. No public legacy drop/archive/exact replacement is authorized.

select
  'phase_b_media_guarded_sync_candidate'::text as section,
  'DRAFT_NOT_RUN_FAIL_CLOSED'::text as decision,
  false as execution_authorized,
  false as production_approved,
  false as destructive_sql_authorized,
  false as exact_public_table_replacement_authorized,
  false as archive_delete_authorized,
  true as no_auth_users_migration,
  true as no_flutter_elevated_secret,
  true as no_waqf_assets_mutation,
  true as no_gis_mutation;
