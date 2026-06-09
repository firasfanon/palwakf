# PalWakf — دفعة Seed مستخدمي الوحدات usr1 و usr2 فقط (v3)

هذه الحزمة مخصصة لإنشاء **حسابات وحدات تجريبية** وربطها مباشرة بوحداتها داخل:
- `auth.users`
- `public.admin_users`

بناءً على البنية الحالية المؤكدة:
- `public.admin_users.id = auth.users.id`
- `public.admin_users` يحتوي الآن على `username` و `unit_id`
- `core.org_units` يحتوي على `login_key`
- دالة `core.fn_can_edit_unit(unit_id)` تم تصحيحها للاعتماد على `admin_users.id = auth.uid()` و `admin_users.unit_id`

## ما تنشئه الحزمة
لكل وحدة فعالة تملك `login_key`:
- `<login_key>admin`
- `<login_key>usr1`
- `<login_key>usr2`

وبريد تجريبي افتراضي:
- `<username>@palwakf.local`

وكلمات مرور افتراضية:
- المدير: `<login_key>123`
- المستخدم 1: `<login_key>456`
- المستخدم 2: `<login_key>456`

## مهم
هذه الحسابات **تجريبية/تشغيلية داخلية** وليست سياسة إنتاج نهائية.
في الإنتاج يجب لاحقًا اعتماد:
- بريد حقيقي
- Confirm email
- وربما MFA أو Phone verification للحسابات الحساسة

## التشغيل
1. انسخ `.env.example` إلى `.env`
2. عبّئ القيم المطلوبة
3. نفّذ:

```bash
npm install
npm run seed:dry
npm run seed:apply
```

## ما يفعله السكربت
- يقرأ الوحدات من `core.org_units`
- يولد 3 حسابات لكل وحدة
- يبحث أولًا عن المستخدم في `auth.users` بالبريد
- إن لم يكن موجودًا ينشئه عبر `auth.admin.createUser()`
- ثم يعمل `upsert` إلى `public.admin_users` مع:
  - `id = auth.users.id`
  - `username`
  - `unit_id`
  - `role`
  - `department`
  - `is_active = true`
  - `is_superuser = false`

## ملاحظات
- لا يغيّر الحسابات المركزية الموجودة مثل `firasfanon` و `mfsh217`
- يتجنب تكرار المستخدمين إن كان البريد موجودًا مسبقًا
- `directorate_id` يترك `NULL` لأنه `integer` ولا يطابق `core.org_units.id` من نوع `uuid`


## تحديث v4
- تم إزالة أي وصول مباشر إلى `auth.users` عبر `.schema('auth')` لأن المشروع لا يعرّض هذا الـ schema عبر PostgREST.
- البحث عن المستخدمين الموجودين في `auth` أصبح عبر `supabase.auth.admin.listUsers(...)`.
- تم تعديل `package.json` ليدعم Windows عبر `cross-env`.

### على Windows
بعد فك الحزمة:
```powershell
npm install
npm run seed:dry
npm run seed:apply
```

### بديل مباشر في PowerShell
```powershell
$env:SEED_MODE="dry"
node .\scripts\seed-unit-admin-users.mjs

$env:SEED_MODE="apply"
node .\scripts\seed-unit-admin-users.mjs
```


## ملاحظة هذه النسخة
هذه النسخة لا تنشئ حسابات admin إطلاقًا. هي محصورة فقط في:
- <login_key>usr1
- <login_key>usr2

لذلك فهي مناسبة بعد نجاح دفعة مدراء الوحدات.


## ملاحظة الدور
القيمة الافتراضية لدور usr1/usr2 هي `employee` ويمكن تغييرها عبر المتغير `USER_ROLE` إلى `viewer` أو `manager` إذا لزم.
