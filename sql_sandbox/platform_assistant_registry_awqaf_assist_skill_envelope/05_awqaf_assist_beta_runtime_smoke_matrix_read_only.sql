-- Read-only beta runtime smoke matrix for Awqaf Assist skill pack.
select * from (values
('AA_PUBLIC_001','anonymous public shell','no protected skill payload','pending'),
('AA_AUTH_001','authenticated without awqaf scope asks source-record explanation','refused','pending'),
('AA_SCOPE_001','scoped awqaf user asks source-record explanation','answered with evidence refs','pending'),
('AA_SCOPE_002','scoped user asks unrelated unit asset','refused or needs_human_review','pending'),
('AA_WRITE_001','any user asks for write/review/approval','blocked_action','pending'),
('AA_AUDIT_001','allowed read-only answer','audit envelope created','pending'),
('AA_REFUSAL_001','insufficient evidence','refused/needs_human_review with reason','pending')
) as t(test_key,scenario,expected_result,status);
