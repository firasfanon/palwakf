# تحديث التعليمات — N2.20/N2.21

1. ابدأ أي تطوير من العقد الحاكم والـ handoff والـ baseline.
2. لا تستخدم `public.org_units` كمصدر حاكم إلا إذا كان view فوق `core.org_units`.
3. لا تستخدم org-unit caches كمصدر في Dashboard/Users/RBAC/Sidebar/Assistant.
4. أي تعديل مشابه في مصدر بيانات سيادي يتطلب Audit شامل قبل التصحيح.
5. لا production gate قبل SQL UAT وFlutter analyzer وBrowser Role UAT.
