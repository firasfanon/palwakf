-- Database Ownership Phase B — Media owner contract. READ ONLY.

with t(section, contract_key, subject, decision, note) as (
  values
    ('phase_b_media_owner_contract'::text, 'owner_schema'::text, 'media_center'::text, 'ACCEPT_AS_MEDIA_SOURCE_OF_TRUTH_TARGET'::text, 'media_center owns canonical media content going forward; public remains compatibility surface.'::text),
    ('phase_b_media_owner_contract', 'legacy_public_tables', 'public.news_articles/public.announcements/public.activities', 'PRESERVE_LEGACY_PUBLIC_NO_DELETE', 'Legacy tables are preserved until dependency-zero and browser UAT are certified.'),
    ('phase_b_media_owner_contract', 'public_api_surface', 'public.v_media_*_compat_v1 and public.rpc_media_content_compat_v1', 'COMPATIBILITY_SURFACE_ACCEPTED', 'Public wrappers may remain runtime API surfaces during controlled migration.'),
    ('phase_b_media_owner_contract', 'auth_rbac', 'assistant/core/tasks access helpers', 'OUT_OF_SCOPE', 'Wave A access helpers are cancelled in this track and deferred to Auth/RBAC Controlled Migration.'),
    ('phase_b_media_owner_contract', 'waqf_gis', 'waqf/waqf_assets/awqaf_system/gis', 'OUT_OF_SCOPE_NO_MUTATION', 'No mutation or ownership changes for sovereign waqf/GIS systems.'),
    ('phase_b_media_owner_contract', 'execution', 'guarded sync candidate', 'BLOCKED_UNTIL_INVENTORY_BROWSER_BACKUP_APPROVAL', 'No copy/sync/DDL is authorized by this read-only pack.')
)
select
  section,
  contract_key,
  subject,
  decision,
  note,
  false as execution_authorized,
  false as production_approved,
  false as destructive_sql_authorized,
  false as exact_public_table_replacement_authorized,
  false as archive_delete_authorized,
  true as no_auth_users_migration,
  true as no_flutter_elevated_secret,
  true as no_waqf_assets_mutation,
  true as no_gis_mutation,
  true as read_only
from t;
