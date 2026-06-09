-- Read-only UAT matrix marker.
select * from (values
  ('RECOVERY_HASH_001','open recovery link with ?code before hash','callback reads Uri.base.queryParameters.code','pending'),
  ('RECOVERY_HASH_002','from preserved in hash route query','safeFrom remains /admin/dashboard','pending'),
  ('RECOVERY_HASH_003','exchangeRecoveryCode success','route to /reset-password?fresh=1','pending'),
  ('RECOVERY_HASH_004','password update','signOut then /login?fresh=1','pending'),
  ('RECOVERY_HASH_005','login after reset','RBAC/system/unit scope checked before dashboard','pending')
) as t(test_key, scenario, expected_result, status);
