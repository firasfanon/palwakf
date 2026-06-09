
# Public Schema Sovereignty Inventory + Ownership Assignment Decision

## التشغيل
شغّل السكربتات بالترتيب من 01 إلى 06 فقط. كل السكربتات read-only ولا تحتوي INSERT/UPDATE/DELETE/DROP/ALTER.

## الهدف
- جرد كل objects داخل schema `public`.
- تصنيف ملكية كل object: `platform`, `core`, `platform_access`, `media_center`, `platform_services`, `zakat`, `billing_system`, `cases`, `assistant`, أو `public_wrapper`.
- تثبيت أن `public` ليس مصدرًا سياديًا، بل سطح wrappers/RPC/views/aliases فقط.
- منع أي migration أو حذف قبل حزمة تنفيذ لاحقة وموافقة صريحة.

## القرار المتوقع
`PUBLIC_SCHEMA_SOVEREIGNTY_INVENTORY_COMPLETE_OWNERSHIP_ASSIGNMENT_DECISION_ONLY`
