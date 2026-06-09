with wave3(public_table, target_schema, target_table, sensitivity, proposed_wave_after_retest, gate_status_after_retest) as (
  values
    ('assistant_conversations', 'assistant', 'assistant_conversations', 'medium', 'WAVE_3_COLLISION_RESOLUTION_REQUIRED', 'EXCLUDED_FROM_WAVE1_TARGET_TABLE_COLLISION'),
    ('assistant_messages', 'assistant', 'assistant_messages', 'medium', 'WAVE_3_COLLISION_RESOLUTION_REQUIRED', 'EXCLUDED_FROM_WAVE1_TARGET_TABLE_COLLISION'),
    ('chatbot_conversations', 'assistant', 'chatbot_conversations', 'medium', 'WAVE_3_COLLISION_RESOLUTION_REQUIRED', 'EXCLUDED_FROM_WAVE1_TARGET_TABLE_COLLISION'),
    ('chatbot_intents', 'assistant', 'chatbot_intents', 'medium', 'WAVE_3_COLLISION_RESOLUTION_REQUIRED', 'EXCLUDED_FROM_WAVE1_TARGET_TABLE_COLLISION'),
    ('chatbot_messages', 'assistant', 'chatbot_messages', 'medium', 'WAVE_3_COLLISION_RESOLUTION_REQUIRED', 'EXCLUDED_FROM_WAVE1_TARGET_TABLE_COLLISION'),
    ('chatbot_retention_policies', 'assistant', 'chatbot_retention_policies', 'medium-high', 'WAVE_3_COLLISION_RESOLUTION_REQUIRED', 'EXCLUDED_FROM_WAVE1_TARGET_TABLE_COLLISION'),
    ('org_units_cache', 'core', 'org_units_cache', 'high', 'WAVE_3_COLLISION_RESOLUTION_REQUIRED', 'EXCLUDED_FROM_WAVE1_TARGET_TABLE_COLLISION'),
    ('pwf_org_units_cache', 'core', 'pwf_org_units_cache', 'high', 'WAVE_3_COLLISION_RESOLUTION_REQUIRED', 'EXCLUDED_FROM_WAVE1_TARGET_TABLE_COLLISION'),
    ('locations', 'gis', 'locations', 'high', 'WAVE_3_COLLISION_RESOLUTION_REQUIRED', 'EXCLUDED_FROM_WAVE1_TARGET_TABLE_COLLISION')
)
select
  'v4_wave3_collision_exclusion_matrix' as section,
  public_table,
  target_schema,
  target_table,
  sensitivity,
  proposed_wave_after_retest,
  gate_status_after_retest,
  'EXCLUDED_FROM_WAVE1_REQUIRES_COMPARE_MERGE_SKIP_OR_RENAME_DECISION' as required_decision,
  false as apply_authorized_by_this_script,
  false as production_approved,
  true as read_only
from wave3
order by target_schema, public_table;
