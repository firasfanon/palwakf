-- Read-only permission/audit envelope contract.
select * from (values
('permission_context','user_id,email,role_snapshot,system_scope,route_scope,unit_scope,permission_keys,session_id,request_id','required'),
('audit_envelope','skill_key,system_key,user_id,intent,status,evidence_refs_count,permission_decision,created_at','required'),
('data_minimization','store evidence refs and decision metadata; avoid raw sovereign payloads unless permitted','required'),
('write_guard','assistant cannot execute writes/reviews in beta','required')
) as t(contract_area,minimum_fields_or_rule,status);
