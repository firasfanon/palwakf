/* Owner schema mapping template. Replace/extend outside SQL execution after reviewing inventory. Read-only static output. */

select * from (
  values
    ('<public_table_name>', '<owner_schema>', '<classification>', '<compatibility_surface>', 'pending', 'Replace this template row with actual mapping evidence.')
) as t(public_table, proposed_owner_schema, classification, compatibility_surface, remediation_status, notes);
