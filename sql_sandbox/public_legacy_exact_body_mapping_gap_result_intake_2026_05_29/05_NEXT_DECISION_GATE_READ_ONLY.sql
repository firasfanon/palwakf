select * from (values
  ('next_gate', 'run_exact_runtime_dependency_classifier', 'REQUIRED_BEFORE_ANY_REWRITE'),
  ('next_gate', 'service_catalog_owner_separation', 'REQUIRED_BEFORE_PUBLIC_SERVICES_REWRITE'),
  ('next_gate', 'deletion', 'BLOCKED'),
  ('next_gate', 'production_approval', 'NOT_APPROVED')
) as t(section, gate_key, decision);
