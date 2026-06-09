# PALWAKF_PLATFORM_COMPREHENSIVE_GUIDE — Update N2.31.1

## Update
اعتماد قاعدة فحص catalog الآمن وقاعدة Runtime Baseline Cleanliness.

## Catalog Safety
لا تستخدم `pg_get_functiondef()` على aggregate/window/system functions. استخدم `prokind in ('f','p')` واستبعد `pg_catalog` و`information_schema` و`pg_toast%`.

## Baseline Cleanliness
الـ baseline الكامل يجب أن يكون قابلًا للتشغيل والمراجعة، وليس مستودعًا لكل ملفات الجلسات القديمة. توثيق التاريخ ينتقل إلى حزمة Handoff/Archive منفصلة.

## Status
N2.31.1 تصحيح read-only فقط، ولا يعتمد الإنتاج.
