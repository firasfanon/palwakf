# PalWakf Governing Contract Appendix — Session Close N2.30

## قاعدة الجلسة الجديدة

بدءًا من الجلسة التالية، يكون برنامج إعادة تنظيم قاعدة البيانات وملكية الجداول أعلى أولوية من أي Production Gate جديد.

## القواعد الحاكمة المضافة

### 1. Database Ownership Gate

لا يُعتمد أي نظام إنتاجيًا إذا كانت الجداول التي يعتمد عليها غير مصنفة الملكية أو ما زالت في public كمصدر تشغيل غير مبرر.

### 2. Public Schema Rule

`public` يجب أن يقتصر قدر الإمكان على:

```text
views
RPC wrappers
compatibility contracts
```

وأي public table تشغيلي يجب أن يكون transitional بقرار موثق في `platform.schema_inventory_decisions`.

### 3. Schema Inventory Contract Rule

العقد الحقيقي لجدول `platform.schema_inventory_decisions` يستخدم:

```text
source_schema
object_name
notes_ar
action_status
```

ولا يجوز استخدام `schema_name` أو `table_name` أو `notes` أو `action_required` إلا عبر view توافقية معتمدة.

### 4. Movement Gate

لا نقل ولا حذف قبل:

```text
dependency audit
RLS migration plan
RPC compatibility wrappers
Flutter usage matrix
rollback plan
SQL UAT
Browser UAT
```

### 5. View Safety Rule

عند تعديل public view قائم:

```text
حافظ على ترتيب الأعمدة القائمة
حافظ على أنواع الأعمدة القائمة
أضف أعمدة جديدة في النهاية فقط
أو أصدر view جديدًا بعقد جديد
```

### 6. Sovereign Boundary

لا تعديل على:

```text
waqf_assets
schema waqf
awqaf_system internal logic
```

إلا عبر دفعة مخصصة بعقد واضح.

### 7. System Domains

```text
site_content = إدارة صفحات الموقع
media_center = المركز الإعلامي
platform_services = مركز الخدمات
facilities_module = مرافق/نقاط خدمة وفواتير عند الحاجة
core = org_units/source-of-truth التنظيمي
platform = Dynamic Registry/System Module Kit
assistant = المعرفة والمساعد
waqf = الأصول الوقفية السيادية
```

