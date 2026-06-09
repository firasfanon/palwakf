-- Database Wave B-1A Media Runtime Strategy Decision
-- 02_media_runtime_strategy_options_read_only.sql
-- Read-only decision matrix.

select * from (values
  ('media_runtime_strategy'::text, 'direct_flutter_reroute', 'blocked', 'public media wrappers are active but may be empty; browser content loss risk'),
  ('media_runtime_strategy', 'legacy_fallback_wrapper', 'transitional_only_not_preferred', 'fast continuity but preserves public legacy as effective runtime source'),
  ('media_runtime_strategy', 'controlled_media_import_seed', 'recommended_next', 'fills media_center before Flutter runtime reroute'),
  ('media_runtime_strategy', 'public_media_extraction', 'blocked', 'Wave B-1B is not authorized'),
  ('media_runtime_strategy', 'locations_wrapper_activation', 'blocked', 'locations authority gate remains open'),
  ('media_runtime_strategy', 'waqf_assets_change', 'forbidden', 'sovereign critical boundary')
) as t(section, strategy_key, decision, note);
