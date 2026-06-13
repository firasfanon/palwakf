
# PALWAKF_PLATFORM_IDENTITY_RBAC_AUTHORITY_CONSOLIDATION_MEGA_BATCH

## التفويض

تم استلام التفويض لتنفيذ Mega Batch واحدة تشمل:

```text
- FK بين platform_access.admin_users.id و auth.users.id
- verification read-only بعد التنفيذ
- rollback SQL
- تحديث smoke/tests/docs
- لا service_role في Flutter
- لا production approval تلقائي
```

## ما جهزته الحزمة

```text
1. Pre-apply guard read-only
2. Authorized FK apply SQL
3. Post-apply verification SQL
4. Rollback SQL
5. Smoke/browser regression docs
6. Test plan
7. Decision record
```

## لم يتم تنفيذه من طرف المساعد

لم يتم تنفيذ SQL فعليًا داخل Supabase من طرفي.  
التنفيذ يتم عندك في Supabase SQL Editor.

## ترتيب التشغيل

```text
1. 00_PRE_APPLY_GUARD_READ_ONLY.sql
2. 01_AUTHORIZED_APPLY_platform_access_admin_users_auth_users_fk.sql
3. 01_POST_APPLY_VERIFY_RBAC_AUTH_USERS_FK.sql
4. flutter analyze
5. flutter test test/core/contracts/cms_payload_contracts_test.dart
6. dart run tools/smoke/palwakf_smoke_suite.dart
```

## القرار الحالي

```text
operator-apply-pending
```
