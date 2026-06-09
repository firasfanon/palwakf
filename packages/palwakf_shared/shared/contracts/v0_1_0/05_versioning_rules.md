# Versioning Rules — v0.1.0

## 1) SemVer إلزامي
- MAJOR: تغييرات breaking
- MINOR: إضافة متوافقة
- PATCH: إصلاحات بدون كسر

## 2) سياسة التغييرات breaking
أي breaking change يجب أن يتضمن:
- رفع MAJOR
- changelog واضح
- نافذة Deprecation (لا تقل عن دورة إصدار واحدة للأنظمة الفرعية الأساسية)

## 3) قواعد تحديث العقود
- أي تغيير في routing/rbac/rpc/systemkey/riverpod/go_router = تحديث العقود
- ممنوع “تغيير صامت” في shared دون زيادة النسخة
