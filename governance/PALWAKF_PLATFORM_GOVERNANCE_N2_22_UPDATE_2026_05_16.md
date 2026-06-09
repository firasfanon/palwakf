# Governance Update — N2.22

## Board decisions required

1. اعتماد قائمة owner systems لكل schema.
2. اعتماد schema للأرشفة: `legacy_archive` و`staging_archive` أو بديل واحد مرحليًا.
3. اعتماد سياسة retention لأدلة UAT.
4. اعتماد Migration waves وعدم تنفيذ النقل دفعة واحدة.
5. اعتماد RBAC migration كمسار مستقل بعد source-of-truth closure.

## Production gate block

يُمنع إعلان Production-ready لأي مسار جديد قبل:

- إغلاق blocker `public.org_units`.
- تصنيف `public.locations`.
- إقرار خطة public schema reduction.
