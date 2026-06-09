# PALWAKF_PLATFORM_COMPREHENSIVE_GUIDE_UPDATE — N2.30 Session Close

## المرجع الأعلى

هذه الوثيقة تُضاف إلى الدليل الشامل للمنصة بعد N2.30 وتلخص ما يجب أن يُحفظ قبل حذف/تجاهل ذاكرة المحادثة.

## الحالة الحالية

```text
PalWakf = System-of-Systems Platform
Stack = Flutter Web + Supabase + Riverpod + GoRouter + flutter_map/PostGIS
Design = RTL/i18n + blue/gold + royal red #B22222
Architecture = feature-based + repositories/services + reusable widgets
```

## برنامج قاعدة البيانات

تم تحويل مسار تنظيف قاعدة البيانات من باتشات إلى Development Program:

```text
Inventory Contract Stabilization
Site Content Domain Migration
Media Center Domain Migration
Services Ownership Mapping
Locations Ownership Resolution
Legacy/Staging/Cache Quarantine
RBAC Transitional Migration
Flutter Repository Migration
Public Compatibility Wrappers
Production Certification
```

## ما أُغلق

```text
public.org_units أصبح core-backed compatibility view
unit_type بقي text
schema_inventory_decisions contract stabilized
site_content/media_center bootstrap موجود
Wave A decisions inserted = 33
```

## ما بقي مفتوحًا

```text
Locations ownership unresolved
Media tables not migrated
Site content tables not migrated
Services mapping unresolved for servicepoints/providers/types
RBAC public tables transitional
Dynamic Registry production gate paused
Production not approved
```

## قاعدة إلزامية

أي تحديث مهم لاحق يجب أن يحدّث:

```text
العقد الحاكم
ملف التعليمات
ملف الحوكمة
نطاق المساعد الداخلي
نطاق الشات العام
baseline/changelog/session handoff/ZIP
```
