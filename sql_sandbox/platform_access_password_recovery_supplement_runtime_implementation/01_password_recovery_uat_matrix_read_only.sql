with tests(test_key, route_or_scenario, expected_result) as (
  values
    ('PR_001','/forgot-password','unified recovery page renders'),
    ('PR_002','empty recovery email','Arabic required-field validation'),
    ('PR_003','invalid recovery email','Arabic invalid-email validation'),
    ('PR_004','valid recovery request','non-enumerating success message'),
    ('PR_005','/auth/recovery-callback?code=...','code/session exchange then reset page'),
    ('PR_006','expired/invalid callback','Arabic invalid/expired-link message'),
    ('PR_007','weak password','Arabic password policy message'),
    ('PR_008','confirmation mismatch','Arabic mismatch message'),
    ('PR_009','successful reset','fresh login required'),
    ('PR_010','post recovery no role','forbidden with reason'),
    ('PR_011','post recovery valid role','authorized system opens'),
    ('PR_012','post recovery wrong unit','forbidden with requested route/unit')
)
select *, 'pending_browser_uat' as status from tests;
