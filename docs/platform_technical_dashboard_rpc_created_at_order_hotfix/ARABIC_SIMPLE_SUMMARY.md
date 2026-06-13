# Platform Technical Services — Dashboard RPC created_at Order Hotfix

## السبب

ظهر الخطأ:

`ERROR 42703: column x.created_at does not exist`

داخل:

`public.rpc_platform_technical_services_dashboard_v1`

السبب أن مجموعة `backups` كانت تستخدم:

`order by x.created_at desc`

لكن subquery الخاص بالـ backups لم يكن يرجع `created_at`.

## التصحيح

تم استبدال جسم الدالة فقط وإضافة `created_at` في backup rows، مع تثبيت ترتيب واضح في كل القوائم.

## النطاق

- تعديل RPC واحدة فقط.
- لا تعديل جداول.
- لا تعديل RLS.
- لا إضعاف auth.
- لا backup/restore execution.
- لا maintenance activation.
- لا تعديل بيانات سيادية.
