-- Database Ownership Phase B — Media counts/visibility gate. READ ONLY.
-- Uses only catalog-safe output in this first Phase B pack. Row counts are intentionally deferred
-- unless the target/source relations are confirmed by SQL 01/03 and a subsequent exact-count script is approved.

with t(section, gate_key, note, passed) as (
  values
    ('phase_b_media_counts_visibility'::text, 'source_presence_first'::text, 'Run SQL 01 and 03; do not count or sync missing objects.'::text, false),
    ('phase_b_media_counts_visibility', 'published_only_visibility_required', 'Public media compatibility must expose published/public content only.', false),
    ('phase_b_media_counts_visibility', 'legacy_public_preserved', 'Legacy public media tables remain preserved; no archive/delete/drop.', true),
    ('phase_b_media_counts_visibility', 'media_center_owner_target', 'media_center remains the target source-of-truth schema.', true),
    ('phase_b_media_counts_visibility', 'browser_uat_required', '/home, /home/news, detail routes, /home/announcements, and admin media routes must be clean before closure.', false)
)
select
  section,
  gate_key,
  passed,
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
