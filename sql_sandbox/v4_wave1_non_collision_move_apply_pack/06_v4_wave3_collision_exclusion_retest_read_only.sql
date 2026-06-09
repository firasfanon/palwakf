-- 06_v4_wave3_collision_exclusion_retest_read_only.sql
-- Verify Wave3 collisions remain excluded and untouched by Wave1. Read-only.
with collision_exclusions(public_table, target_schema, target_table, sensitivity) as (
  values
    ('assistant_conversations', 'assistant', 'assistant_conversations', 'medium'),
    ('assistant_messages', 'assistant', 'assistant_messages', 'medium'),
    ('chatbot_conversations', 'assistant', 'chatbot_conversations', 'medium'),
    ('chatbot_intents', 'assistant', 'chatbot_intents', 'medium'),
    ('chatbot_messages', 'assistant', 'chatbot_messages', 'medium'),
    ('chatbot_retention_policies', 'assistant', 'chatbot_retention_policies', 'medium-high'),
    ('org_units_cache', 'core', 'org_units_cache', 'high'),
    ('pwf_org_units_cache', 'core', 'pwf_org_units_cache', 'high'),
    ('locations', 'gis', 'locations', 'high')
)
select
  'v4_wave3_collision_exclusion_retest_summary' as section,
  count(*) as excluded_collision_count,
  count(*) filter (where to_regclass(format('public.%I', public_table)) is not null) as excluded_public_tables_present,
  count(*) filter (where to_regclass(format('%I.%I', target_schema, target_table)) is not null) as excluded_target_tables_present,
  (count(*) filter (where to_regclass(format('public.%I', public_table)) is not null) = 9
    and count(*) filter (where to_regclass(format('%I.%I', target_schema, target_table)) is not null) = 9
  ) as collision_exclusions_still_intact,
  false as apply_authorized_by_this_script,
  false as production_approved,
  true as read_only
from collision_exclusions;

with collision_exclusions(public_table, target_schema, target_table, sensitivity) as (
  values
    ('assistant_conversations', 'assistant', 'assistant_conversations', 'medium'),
    ('assistant_messages', 'assistant', 'assistant_messages', 'medium'),
    ('chatbot_conversations', 'assistant', 'chatbot_conversations', 'medium'),
    ('chatbot_intents', 'assistant', 'chatbot_intents', 'medium'),
    ('chatbot_messages', 'assistant', 'chatbot_messages', 'medium'),
    ('chatbot_retention_policies', 'assistant', 'chatbot_retention_policies', 'medium-high'),
    ('org_units_cache', 'core', 'org_units_cache', 'high'),
    ('pwf_org_units_cache', 'core', 'pwf_org_units_cache', 'high'),
    ('locations', 'gis', 'locations', 'high')
)
select
  'v4_wave3_collision_exclusion_retest_detail' as section,
  public_table,
  target_schema,
  target_table,
  sensitivity,
  to_regclass(format('public.%I', public_table)) is not null as public_table_present,
  to_regclass(format('%I.%I', target_schema, target_table)) is not null as target_table_present,
  'WAVE3_REQUIRES_COMPARE_MERGE_SKIP_OR_RENAME_DECISION_NOT_INCLUDED_IN_WAVE1' as decision,
  true as read_only
from collision_exclusions
order by target_schema, public_table;
