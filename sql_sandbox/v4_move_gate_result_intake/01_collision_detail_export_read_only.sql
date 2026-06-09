-- Read-only helper: export target table collisions from the move map.
-- This script does not execute DDL/DML and does not authorize movement.
with v4_move_map(public_table, target_schema, target_table) as (
  values
    ('assistant_conversations','assistant','assistant_conversations'),
    ('assistant_messages','assistant','assistant_messages'),
    ('chatbot_conversations','assistant','chatbot_conversations'),
    ('chatbot_intents','assistant','chatbot_intents'),
    ('chatbot_messages','assistant','chatbot_messages'),
    ('chatbot_retention_policies','assistant','chatbot_retention_policies'),
    ('org_units_cache','core','org_units_cache'),
    ('pwf_org_units_cache','core','pwf_org_units_cache'),
    ('locations','gis','locations')
)
select
  'v4_move_inferred_collision_detail' as section,
  m.public_table,
  m.target_schema,
  m.target_table,
  true as collision_resolution_required,
  false as apply_authorized_by_this_script,
  false as production_approved,
  true as read_only
from v4_move_map m
order by m.target_schema, m.public_table;
