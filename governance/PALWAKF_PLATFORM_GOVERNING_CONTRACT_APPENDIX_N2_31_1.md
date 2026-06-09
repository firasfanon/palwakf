# PALWAKF PLATFORM GOVERNING CONTRACT APPENDIX — N2.31.1

## SQL Catalog Inspection Rule
عند فحص function dependencies عبر PostgreSQL catalog لا يجوز استدعاء `pg_get_functiondef()` على كامل `pg_proc` دون تصفية. يجب استبعاد aggregate/window/system functions، وحصر الفحص في ordinary functions/procedures داخل schemas غير نظامية.

## Baseline Hygiene Rule
الـ Runtime Baseline يجب أن يكون نسخة تشغيل نظيفة، لا أرشيفًا زمنيًا مفتوحًا. تحفظ ملفات التاريخ الطويل في أرشيف منفصل أو داخل حزمة handoff لا داخل جذر المشروع.

## Sovereign Boundary
لا تغيّر N2.31.1 أي بيانات أو جداول في `waqf`, `waqf_assets`, أو `awqaf_system`.
