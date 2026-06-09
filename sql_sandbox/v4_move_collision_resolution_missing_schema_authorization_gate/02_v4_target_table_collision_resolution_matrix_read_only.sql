with collision_matrix(public_table, target_schema, target_table, recommended_default_decision, required_review) as (
  values
    ('assistant_conversations','assistant','assistant_conversations','PENDING_COMPARE_THEN_SKIP_OR_QUARANTINE_OR_MERGE','Existing assistant table with same name; compare public legacy rows against assistant owner rows before merge/skip/quarantine.'),
    ('assistant_messages','assistant','assistant_messages','PENDING_COMPARE_THEN_SKIP_OR_QUARANTINE_OR_MERGE','Existing assistant table with same name; compare public legacy rows against assistant owner rows before merge/skip/quarantine.'),
    ('chatbot_conversations','assistant','chatbot_conversations','PENDING_COMPARE_THEN_SKIP_OR_QUARANTINE_OR_MERGE','Existing assistant table with same name; compare public legacy rows against assistant owner rows before merge/skip/quarantine.'),
    ('chatbot_intents','assistant','chatbot_intents','PENDING_COMPARE_THEN_SKIP_OR_QUARANTINE_OR_MERGE','Existing assistant table with same name; compare public legacy rows against assistant owner rows before merge/skip/quarantine.'),
    ('chatbot_messages','assistant','chatbot_messages','PENDING_COMPARE_THEN_SKIP_OR_QUARANTINE_OR_MERGE','Existing assistant table with same name; compare public legacy rows against assistant owner rows before merge/skip/quarantine.'),
    ('chatbot_retention_policies','assistant','chatbot_retention_policies','PENDING_COMPARE_THEN_SKIP_OR_QUARANTINE_OR_MERGE','Existing assistant table with same name; compare public legacy rows against assistant owner rows before merge/skip/quarantine.'),
    ('org_units_cache','core','org_units_cache','PENDING_COMPARE_THEN_SKIP_OR_QUARANTINE_OR_MERGE','Existing core cache table with same name; core is likely canonical, public cache needs compare before move/skip/quarantine.'),
    ('pwf_org_units_cache','core','pwf_org_units_cache','PENDING_COMPARE_THEN_SKIP_OR_QUARANTINE_OR_MERGE','Existing core cache table with same name; core is likely canonical, public cache needs compare before move/skip/quarantine.'),
    ('locations','gis','locations','PENDING_COMPARE_THEN_SKIP_OR_QUARANTINE_OR_MERGE','Existing GIS locations table with same name; do not merge blindly, compare geometry/domain semantics first.')
)
select
  'v4_target_table_collision_resolution_matrix' as section,
  public_table,
  target_schema,
  target_table,
  'TARGET_TABLE_NAME_COLLISION' as collision_type,
  recommended_default_decision,
  required_review,
  false as direct_alter_table_move_allowed,
  false as apply_authorized_by_this_script,
  false as destructive_sql_authorized,
  false as production_approved,
  true as read_only
from collision_matrix
order by target_schema, public_table;
