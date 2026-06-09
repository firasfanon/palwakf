# تحديث الحوكمة — N2.20/N2.21

تم اعتماد مصفوفة تصنيف Source-of-Truth:

- A: public wrapper فوق schema سيادي — مقبول.
- B: public cache/duplicate كمصدر حاكم — blocker.
- C: transitional table — موثق ومؤجل للترحيل.
- D: historical/Mustakshif-only — مسموح read-only ضمن نطاقه.
- E: يحتاج عقد جديد أو migration مستقل.

N2.21 يعالج B الخاصة بـ org units فقط.
