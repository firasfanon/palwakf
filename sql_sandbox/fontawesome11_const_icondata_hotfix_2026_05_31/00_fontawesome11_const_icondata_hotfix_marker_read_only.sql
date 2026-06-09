-- Font Awesome 11 Const/IconData Analyzer Hotfix marker — read-only
-- No DDL/DML/GRANT/DROP. No production approval. No schema mutation.
select
  'fontawesome11_const_icondata_hotfix_2026_05_31'::text as section,
  true as read_only,
  true as no_sql_production_change,
  true as no_waqf_assets_mutation,
  true as production_not_approved,
  'source-only dependency compatibility hotfix; run flutter analyze/chrome locally'::text as note;
