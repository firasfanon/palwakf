-- Database Wave B-1A — Flutter Media Runtime Reroute Result Intake
-- 01: local runtime evidence result matrix. Read-only values-only matrix.

select * from (values
  ('local_runtime_evidence','flutter_pub_get','passed','Got dependencies; dependency drift warnings are non-blocking.'),
  ('local_runtime_evidence','targeted_dart_format','passed','Formatted 3 files; 2 changed.'),
  ('local_runtime_evidence','flutter_analyze','passed','No issues found.'),
  ('local_runtime_evidence','flutter_run_chrome','passed','Debug service and VM service started.'),
  ('local_runtime_evidence','environment_bootstrap','passed','Environment variables loaded successfully.'),
  ('local_runtime_evidence','storage_bootstrap','passed','Storage service initialized.'),
  ('local_runtime_evidence','supabase_bootstrap','passed','Supabase initialized successfully.'),
  ('local_runtime_evidence','visual_identity_bootstrap','passed','Loaded 2 published overrides.'),
  ('production_gate','decision','not_approved','Browser click-through evidence is still pending.')
) as t(section, check_key, result, note);
