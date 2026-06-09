-- Platform External Services Prayer Times Resilience UAT Result Intake
-- READ ONLY MARKER ONLY
-- No DDL. No DML. No GRANT. No DROP.
-- No mutation on waqf, waqf_assets, awqaf_system, GIS, public.services, or public.home_services.
select
  'platform_external_services_prayer_times_resilience_uat_result_intake' as section,
  'READ_ONLY_MARKER_ONLY' as action,
  true as no_sql_production_change,
  true as no_destructive_sql,
  true as no_waqf_assets_mutation,
  true as production_not_approved;
