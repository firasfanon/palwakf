# Awqaf Asset Detail — Explicit Assignment Renewal Hotfix

## التفويض

تم تفويض:

`Awqaf Asset Detail — Explicit Assignment Renewal Hotfix`

## السبب

الـ RPC:

`public.rpc_waqf_asset_detail_v1`

كان يرجع 403 لأن المستخدم يملك assignment:

`waqf.assets.super_admin`

لكنه منتهي الصلاحية.

## المستهدف

- المستخدم: `96f6cdc2-67f9-4352-b9f8-775ef509fed8`
- الصلاحية: `waqf.assets.super_admin`
- النطاق: عام `null/null`
- أصل smoke: `721abf33-b243-4bd2-9ece-577128c2fdf4`

## ما تفعله الحزمة

- تجدد assignment المعروف إذا وجد.
- أو تضيف assignment بديل فقط إذا لا يوجد assignment فعال.
- تتحقق من `has_waqf_asset_read_access_v1`.
- تختبر `rpc_waqf_asset_detail_v1` بسياق authenticated محاكى.

## ما لا تفعله

- لا تعدل دوال RBAC.
- لا تمنح SELECT على جدول الأصول.
- لا تعدل `waqf.waqf_assets`.
- لا تضيف Flutter.
- لا تضيف ملفات Awqaf System.
