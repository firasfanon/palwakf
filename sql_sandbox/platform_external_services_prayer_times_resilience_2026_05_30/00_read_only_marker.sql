-- Platform External Services Prayer Times Resilience — 2026-05-30
-- READ ONLY MARKER. No DDL/DML/GRANT/DROP.

select
  'platform_external_services_prayer_times_resilience' as section,
  'read_only_marker' as check_key,
  true as passed,
  'Flutter-only resilience patch for prayer-times external calls; no database mutation.' as note;
