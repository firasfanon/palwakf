-- Zakat public page PWF-SIS visual harmonization UAT result intake marker.
-- Read-only/no-op marker. No DDL/DML is executed.
select 'zakat_pwf_sis_visual_harmonization_uat_result_intaken' as section,
       'FINAL_ZAKAT_RUNTIME_VISUAL_CERTIFICATION_ACCEPTED_WITH_CONFIG_WRAPPER_PENDING' as decision,
       true as no_waq_assets_mutation,
       true as no_sql_production_change;
