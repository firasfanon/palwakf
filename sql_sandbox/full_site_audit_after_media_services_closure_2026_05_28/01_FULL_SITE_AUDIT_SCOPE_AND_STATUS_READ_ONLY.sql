select
  'full_site_audit_after_media_services_closure'::text as section,
  'phase_b_media_center_closed'::text as gate_key,
  true as passed,
  'Media Center DB ownership and browser list/admin evidence accepted; SQL02 not run.'::text as note,
  false as execution_authorized_by_this_script,
  false as production_approved,
  false as destructive_sql_authorized,
  false as exact_public_table_replacement_authorized,
  false as archive_delete_authorized,
  true as no_auth_users_migration,
  true as no_flutter_elevated_secret,
  true as no_waqf_assets_mutation,
  true as no_gis_mutation,
  true as read_only
union all
select 'full_site_audit_after_media_services_closure','phase_c_service_center_validated',true,'Service Center DB ownership, public RPC wrappers, RLS/policy surface, and browser rendering evidence accepted with auth-token 400 warning.',false,false,false,false,false,true,true,true,true,true
union all
select 'full_site_audit_after_media_services_closure','auth_token_400_requires_classification_or_clean_retest',false,'Admin console shows POST /auth/v1/token?grant_type=password 400 warning; production remains deferred until cleaned or formally classified.',false,false,false,false,false,true,true,true,true,true
union all
select 'full_site_audit_after_media_services_closure','production_gate',false,'Full Site Audit pack does not approve production.',false,false,false,false,false,true,true,true,true,true;
