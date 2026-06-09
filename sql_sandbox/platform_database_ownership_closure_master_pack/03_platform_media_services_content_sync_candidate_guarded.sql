-- Platform Database Ownership Closure Master Pack — 03
-- PLATFORM/MEDIA/SERVICES CONTENT SYNC CANDIDATE
-- GUARDED CANDIDATE ONLY. This script intentionally fails closed until an
-- operator replaces the token after SQL 00/01/05/06/07 pass.
do $$
begin
  if coalesce(current_setting('request.palwakf_database_ownership_token', true), '') <> 'PALWAKF_DB_OWNERSHIP_CLOSURE_AUTHORIZED_2026_05_25' then
    raise exception 'BLOCKED: database ownership candidate requires explicit operator token and prior UAT evidence';
  end if;
end $$;

-- Candidate body placeholder:
-- 1. Create/verify owner schemas.
-- 2. Create owner-shadow tables using LIKE INCLUDING DEFAULTS/CONSTRAINTS only after review.
-- 3. Copy data using INSERT ... SELECT with idempotent ON CONFLICT after backup confirmation.
-- 4. Create public compatibility views/RPCs.
-- 5. Do not DROP/DELETE/TRUNCATE public legacy tables.
select 'platform_media_services_content_sync_candidate_guarded' as section,
       'guarded_candidate_not_executed_by_baseline' as decision,
       false as production_approved,
       true as no_auth_users_migration,
       true as no_waqf_assets_mutation;
