# Awqaf Asset Detail — PostGIS GeoJSON Function Qualification Hotfix

## التفويض

تم تفويض:

`Awqaf Asset Detail — PostGIS GeoJSON Function Qualification Hotfix`

## سبب الدفعة

PostGIS موجود في schema:

`extensions`

ودالة `waqf.rpc_waqf_asset_detail_v1` كانت تستدعي:

`st_asgeojson(...)`

بدون تأهيل schema، بينما `search_path` لا يحتوي `extensions`.

## التصحيح

استبدال:

```sql
st_asgeojson(g.geom)
st_asgeojson(g.centroid)
```

بـ:

```sql
extensions.st_asgeojson(g.geom)
extensions.st_asgeojson(g.centroid)
```

## النطاق

- تعديل دالة واحدة فقط: `waqf.rpc_waqf_asset_detail_v1(uuid)`
- لا DML
- لا تعديل RBAC
- لا GRANT على `waqf.waqf_assets`
- لا تعديل أصول الوقف
- لا Flutter
- لا ملفات Awqaf System

## الاختبار

بعد التطبيق، يتم smoke عبر:

`public.rpc_waqf_asset_detail_v1('721abf33-b243-4bd2-9ece-577128c2fdf4'::uuid)`
