select 'pwf_sis_polish_execution_decision' as section,
       'PWF_SIS_POLISH_EXECUTED_BROWSER_UAT_REQUIRED' as decision,
       jsonb_build_object(
         'gallery_guard', 'not certified complete while public.v_media_gallery_compat_v1 = 0',
         'zakat_guard', 'official config/source gap must remain visible',
         'chat_guard', 'public source allowlist must remain visible',
         'browser_console_uat_required', true,
         'production_not_approved_by_sql_alone', true
       ) as decision_payload;
