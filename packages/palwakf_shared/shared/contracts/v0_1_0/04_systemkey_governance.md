# SystemKey Governance — v0.1.0

## 1) الهدف
تثبيت تعريفات SystemKey لمنع تضارب الأسماء بين الأنظمة الفرعية على مستوى routing/RBAC/logging.

## 2) القرار
- awqaf_system يمثل SystemKey.adminData
- "awqaf_system" هو alias توثيقي فقط (لا يُضاف كمفتاح enum جديد).

## 3) قواعد إضافة نظام جديد
- لا يُضاف SystemKey جديد إلا عبر:
  - PR يضيفه في المنصة
  - تحديث العقود
  - توثيق alias إن لزم
