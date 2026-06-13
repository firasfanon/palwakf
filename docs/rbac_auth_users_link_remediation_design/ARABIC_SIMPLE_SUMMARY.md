
# RBAC_AUTH_USERS_LINK_REMEDIATION_DESIGN

## سبب الحزمة

آخر دليل أظهر:

```text
Success. No rows returned
```

أي لا يوجد FK فعلي مثبت بين:

```text
platform_access.admin_users.id
auth.users.id
```

## الهدف

تجهيز تصميم معالجة آمن قبل أي تنفيذ.

## المسارات المطروحة

```text
A. إضافة FK فعلي إذا ثبت عدم وجود orphan rows
B. اعتماد عقد منطقي عبر auth.uid() و RPC/RLS
C. إنشاء compatibility view لهوية المدير
D. إنشاء bridge table إذا لم تكن IDs متطابقة
```

## ما تم تجهيزه

- SQL read-only لفحص البيانات والتبعيات.
- SQL drafts فقط، غير مصرح بتطبيقها.
- Decision matrix لاختيار المسار.
- قالب استيعاب نتائج.

## الحدود

```text
لا SQL apply
لا RLS change
لا FK created
لا service_role
لا production approval
```
