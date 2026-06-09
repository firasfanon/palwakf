# ملحق العقد الحاكم — N2.20/N2.21 Source-of-Truth Realignment

## قاعدة حاكمة

`core.org_units` هو المصدر السيادي الوحيد للوحدات التنظيمية الحديثة.

`public.org_units` مسموح فقط كـ compatibility view فوق `core.org_units`، ولا يجوز توجيهه إلى `public.pwf_org_units_cache` أو `public.org_units_cache`.

## قواعد Flutter

- يمنع الاعتماد المباشر على `.from('org_units')` في Flutter بعد N2.21.
- يمنع القراءة المباشرة من `schema('core').from('org_units')` من Flutter.
- القراءة تكون عبر public RPC/views فوق core.
- الكتابة/التعديل/الحذف للوحدات يتم فقط عبر admin RPCs.

## RBAC

`public.user_system_roles` و`public.user_system_permissions` تبقى transitional source لحين تصميم RBAC migration مستقل. لا تُكسر ضمن N2.21.

## locations

تعارض `public.locations`/`gis.locations` يحتاج Audit مستقل. لا يُحسم ضمن N2.21.

## Public schema

Public للـ wrappers/RPC/views أو transitional tables الموثقة فقط، وليس مصدرًا سياديًا جديدًا.
