# CMS Write/Publish Direct Table Schema Cache Hotfix

## سبب الدفعة

أظهرت لقطة Network بتاريخ 2026-06-11 أن عملية CMS Add/Save لا تستخدم RPC، بل تستخدم direct Supabase REST table access:

```text
/rest/v1/news_articles
/rest/v1/announcements
```

وظهر خطأ:

```text
PGRST204
Could not find the '<column>' column of '<table>' in the schema cache
```

## التصحيح

تم تقوية `SharedContentSaveHelper.saveWithOptionalColumns` ليقوم بالآتي:

1. إزالة الحقول الاختيارية المعروفة بأنها غير مضمونة في جداول legacy قبل أول request.
2. التقاط خطأ PostgREST `PGRST204` أو رسالة schema cache.
3. استخراج اسم العمود غير الموجود من الخطأ.
4. إزالة العمود غير الجوهري وإعادة المحاولة.
5. الحفاظ على core columns وعدم حذفها بصمت.

## ما لم يتم تغييره

- لا SQL.
- لا إضافة أعمدة إلى public tables.
- لا تحويل CMS إلى RPC.
- لا تغيير RLS.
- لا service_role.
- لا production approval.

## التصنيف الأكاديمي بعد هذا الدليل

```text
CMS write/save uses direct Supabase table access.
The observed endpoints are /rest/v1/news_articles and /rest/v1/announcements.
This is not RPC-based for the tested Add/Save operation.
```
