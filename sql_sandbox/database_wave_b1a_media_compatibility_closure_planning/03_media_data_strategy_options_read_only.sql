-- Database Wave B-1A Media Compatibility Closure Planning Pack
-- 03_media_data_strategy_options_read_only.sql
-- READ ONLY: strategy options, not an apply script.

select * from (values
  ('media_data_strategy_options','legacy_fallback_wrapper','allowed_for_planning','read-only normalized fallback to legacy public media while media_center remains empty','requires wrapper redesign and row parity UAT'),
  ('media_data_strategy_options','controlled_media_import_seed','allowed_for_planning','controlled copy/map into media_center without deleting legacy public tables','requires field mapping, duplicate strategy, RLS UAT, rollback plan'),
  ('media_data_strategy_options','direct_flutter_reroute_now','blocked','would point runtime to empty media_center-backed wrappers','not allowed'),
  ('media_data_strategy_options','wave_b1b_extraction','blocked','selective sovereign extraction remains unauthorized','not allowed')
) as t(section,strategy_key,planning_state,description,requirement);
