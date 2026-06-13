# منصة PalWakf — إغلاق لوحة الخدمات التقنية

## طبيعة الدفعة

هذه دفعة تطوير وإغلاق تشغيلي للوحة الخدمات التقنية، وليست SQL apply جديدًا.

الدفعة تربط ما كان موجودًا في الـ Backend ضمن `platform_technical` مع الواجهة:

- Evidence
- Notifications
- Operation Decisions
- Audit Events
- Backend status
- Metrics

## ماذا تغير؟

1. نموذج `PwfTechnicalServicesDashboard` أصبح يقرأ:
   - `evidence`
   - `notifications`
   - `operation_decisions`

2. لوحة Overview تعرض الآن:
   - شريط إغلاق تقني
   - مركز الأدلة والتنبيهات والقرارات
   - عدد الأدلة
   - عدد التنبيهات
   - عدد قرارات التشغيل

3. صفحة Audit تعرض أيضًا مركز الإغلاق التشغيلي.

## ما لم يتغير؟

- لا SQL جديد.
- لا RLS جديد.
- لا service_role.
- لا تنفيذ backup/restore من Flutter.
- لا إغلاق تلقائي للموقع.
- لا production approval.

## النتيجة

اللوحة أصبحت أقرب إلى الإغلاق التشغيلي لأنها لا تعرض metrics فقط، بل تعرض أيضًا طبقة الإثبات والقرارات والتنبيهات المطلوبة لمشروع التخرج والتشغيل الحكومي.
