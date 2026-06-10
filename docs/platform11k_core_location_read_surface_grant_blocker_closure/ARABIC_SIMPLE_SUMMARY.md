# Platform 11K — إغلاق Blocker صلاحيات قراءة Core Locations

## التصنيف

`PLATFORM_CORE_READ_SURFACE_GRANT_BLOCKER`

## السبب

أوقاف سيستم أثبت أن routes تعمل، لكن RPCs تفشل 403 بسبب:

```text
permission denied for view v_core_location_backlog_operational_queue_v1
```

## الحل

تصحيح صلاحيات قراءة فقط:

```sql
grant usage on schema core to authenticated;
grant select on core.v_core_location_backlog_operational_queue_v1 to authenticated;
grant select on core.v_core_locations_with_lgus_v1 to authenticated;
grant execute on function ... to authenticated;
```

## القيود

لا DML، لا Flutter، لا ملفات Awqaf System، لا إعادة `public.locations`، لا إنشاء `gis.locations_boundary`، لا تعديل `waqf.waqf_assets`.
