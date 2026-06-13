# Platform Technical Services — SQL Editor Auth / Seed / Smoke Hotfix

## سبب التصحيح

ظهرت نتيجتان:

1. `PLATFORM_TECHNICAL_AUTH_REQUIRED` أثناء seed لأن `04_SEED` استدعى RPC محميًا من SQL Editor بدون `auth.uid()`.
2. `invalid input syntax for type uuid: "<AUTH_USER_UUID_HERE>"` لأن smoke template شُغّل بدون استبدال placeholder.

## التصحيح

- تم تعديل `04_SEED_initial_health_release_records.sql` ليعمل داخل SQL Editor بدون استدعاء RPC محمي.
- تم إضافة `06A_AUTHENTICATED_RPC_SMOKE_KNOWN_USER.sql` للمستخدم المعروف:

`96f6cdc2-67f9-4352-b9f8-775ef509fed8`

- تم إضافة `06B_ADMIN_USER_RESOLUTION_HELPER_read_only.sql` للمساعدة إذا لم يكن هذا UUID هو مفتاح `public.admin_users`.

## ما لم يتغير

- لم نضعف حماية Runtime RPCs.
- لم نسمح بتنفيذ Backup/Restore.
- لم نفعّل Maintenance Mode.
- لم نعدل بيانات سيادية.
- لم نعتمد Production.
