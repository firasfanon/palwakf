# Platform 11K — Hotfix صلاحيات جدول core_locations

## الخطأ

```text
ERROR 42501: permission denied for table core_locations
HINT: GRANT SELECT ON core.core_locations TO authenticated;
```

## التفسير

منح SELECT على الـ views لم يكن كافيًا لأن الـ RPC/view path يعمل بصلاحيات `authenticated` ويحتاج قراءة base table.

## التصحيح

يضيف hotfix:

```sql
grant usage on schema core to authenticated;
grant select on core.core_locations to authenticated;
grant select on core.core_lgus to authenticated;
```

ويعيد تأكيد grants السابقة على views/RPCs.

## القيود

لا DML، لا Flutter، لا ملفات أوقاف، لا إعادة `public.locations`، لا إنشاء `gis.locations_boundary`، لا تعديل `waqf.waqf_assets`.
