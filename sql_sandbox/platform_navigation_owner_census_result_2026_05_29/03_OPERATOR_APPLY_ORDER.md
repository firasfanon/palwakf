# Operator Apply Order — guarded review only

Do not run this as a bulk apply. Review each existing guarded file from the previous pack first.

1. `01_CURRENT_PUBLIC_NAVIGATION_CENSUS_READ_ONLY.sql` — already supplied and accepted.
2. `02_PLATFORM_NAVIGATION_SCHEMA_BOOTSTRAP_GUARDED_NOT_RUN.sql` — may be considered for explicit staging apply.
3. `03_CONTROLLED_SEED_FROM_PUBLIC_SERVICES_HOME_SERVICES_GUARDED_NOT_RUN.sql` — only after schema bootstrap passes.
4. `04_COMPATIBILITY_WRAPPERS_DRAFT_NOT_RUN.sql` — only after seed validation design is accepted.
5. `05_MIGRATION_VALIDATION_READ_ONLY.sql` — required after any apply.
6. `06_ARCHIVE_DELETE_GATE_BLOCKED_READ_ONLY.sql` — must remain blocked; no deletion.

Stop on first SQL error. Do not delete, archive, rename, truncate, or replace `public.services` or `public.home_services`.
