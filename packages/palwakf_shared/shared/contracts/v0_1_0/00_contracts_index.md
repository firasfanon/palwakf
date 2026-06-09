# PalWakf Shared Contracts — v0.1.0

هذه العقود هي مرجع سيادي ملزم لكل الأنظمة الفرعية داخل منصة PalWakf.
أي نظام فرعي يُعتبر "غير قابل للدمج" ما لم يلتزم بهذه النسخة أو نسخة أحدث معتمدة رسميًا.

---

## 1) نطاق الالتزام
ينطبق على:
- المنصة (core / shared)
- جميع الأنظمة الفرعية (awqaf_system/adminData، مستكشف الوقف، القضايا، الأراضي، المساجد…).

---

## 2) Gate الدمج (Integration Gate)
يُمنع دمج أي نظام فرعي قبل تحقق التالي:
- وجود هذا المجلد: `shared/contracts/v0_1_0/`
- وجود الملفات الخمسة الأساسية:
  - 01_riverpod_governance.md
  - 02_routing_governance.md
  - 03_rpc_pwf_key.md
  - 04_systemkey_governance.md
  - 05_versioning_rules.md

---

## 3) مصدر الحقيقة
- Markdown = المرجع السيادي للقرار.
- عند أي التباس: نُعدّل العقد نفسها (Patch توثيقي واضح)، ولا نعتمد “تفسير شفهي”.

---

## 4) ما الذي يُعتبر Breaking؟
أي تغيير يسبب:
- كسر التوجيه (routing) أو allowlist أو unitSlug
- تغيير نسخ Riverpod/go_router بطريقة تؤثر على import/behavior
- إضافة/تغيير RPC لتوليد المفتاح الوطني
- تغيير mapping لـ SystemKey

---

## 5) الالتزام الأمني السيادي
- قاعدة بيانات واحدة موحّدة.
- admin_users مصدر الهوية الوحيد + RBAC/RLS.
- أي تغيير بنيوي = Patch SQL معتمد.
- أي نظام فرعي لا يلمس routing/identity خارج إطار shared/contracts.
