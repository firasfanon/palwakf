select * from (values
  ('ORC_POS_001','platform superuser central route','render_console_read_only','pending'),
  ('ORC_POS_002','unit scoped positive','render_scoped_console','pending'),
  ('ORC_NEG_001','logged out direct route','redirect_login_or_forbidden_with_from','pending'),
  ('ORC_NEG_002','wrong unit negative','forbidden_arabic_reason_route_origin','pending'),
  ('ORC_NEG_003','no awqaf permission','forbidden_no_payload','pending'),
  ('ORC_ID_001','actor identity semantics','correct_role_labels_no_unit_admin_superuser','pending'),
  ('ORC_RO_001','read-only network','read_rpcs_200_no_write','pending'),
  ('ORC_WRITE_001','write boundary','create_review_add_apply_disabled','pending')
) as t(evidence_key, scenario, expected_result, status);
