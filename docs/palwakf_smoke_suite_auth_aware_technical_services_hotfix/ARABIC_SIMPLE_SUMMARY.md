
# PalWakf Smoke Suite — Auth-Aware Technical Services Hotfix

## نتيجة الأدلة

تم استيعاب النتائج التالية:

```text
flutter analyze = No issues found
flutter test cms_payload_contracts_test.dart = All tests passed
SMK-05/06/07 = HTTP 200
SMK-08 = HTTP 401 PLATFORM_TECHNICAL_AUTH_REQUIRED
```

## الحكم

فشل `SMK-08` ليس فشل Backend عام.  
الـ RPC محمي ويتطلب مستخدمًا مصادقًا بصلاحية تقنية، بينما smoke suite استخدم anon key فقط.

## التصحيح

تم تعديل smoke suite ليصبح auth-aware:

- إذا لم يوجد token مستخدم مصادق:
  - يصنف `PLATFORM_TECHNICAL_AUTH_REQUIRED` كـ `SKIP/PROTECTED`
  - لا يعتبره `FAIL`
- إذا زودته بـ access token لمستخدم إداري:
  - يتوقع HTTP 200

## المتغيرات الاختيارية

```text
SUPABASE_ACCESS_TOKEN
PALWAKF_SMOKE_ACCESS_TOKEN
PALWAKF_ADMIN_ACCESS_TOKEN
```

## الحدود

- لا SQL.
- لا RLS.
- لا service_role.
- لا production approval.
