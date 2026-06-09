# PalWakf Governing Contract Appendix — N2.18 Execution Evidence Rule

## قاعدة حاكمة جديدة

فتح صفحة إدارة أو ظهور نماذج الإدخال لا يكفي لإعلان جاهزية Dynamic System Registry أو System Module Kit.

## معيار الاعتماد

أي نظام أو قسم ديناميكي لا يُعد معتمدًا إلا بعد إثبات:

1. حفظ سجل فعلي في `platform.system_registry`.
2. حفظ سجل فعلي في `platform.system_sections` عند وجود أقسام.
3. ظهور العنصر للمستخدم المصرح في Sidebar/Dashboard.
4. فتح route الديناميكي الصحيح.
5. إخفاء العنصر أو منع الوصول لمستخدم غير مصرح مثل `bthusr1`.
6. تسجيل أو إتاحة read-only SQL evidence بعد الإنشاء.
7. عدم وجود أخطاء حرجة في Browser Console.

## قاعدة أدلة المساعد الداخلي

دليل المساعد الداخلي role-scoped. صورة `bthusr1` لا تثبت تجربة superuser/admin. يجب فصل الأدلة:

- `assistant-scoped-evidence-accepted-for-bthusr1-only`
- `admin-assistant-evidence-pending`

## قاعدة تحديث الملفات

أي تصحيح في الحكم يجب أن ينعكس في:

- العقد الحاكم أو ملحقه.
- ملف التعليمات.
- ملف الحوكمة.
- نطاق المساعد الداخلي.
- نطاق الشات العام.
- Changelog / Handoff / ZIP عند الحاجة.
