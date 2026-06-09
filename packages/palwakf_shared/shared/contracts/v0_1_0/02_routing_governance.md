# Routing Governance — v0.1.0

## 1) النسخة المعتمدة
- تثبيت go_router على ^17.0.1.

## 2) قاعدة استخراج المسار (Sovereign Path Resolver)
الهدف: دعم path routing و hash routing بدون اجتهادات.

القاعدة:
1) اقرأ `Uri.base.path`
2) إذا كان فارغًا أو "/" → استخدم `Uri.base.fragment`
3) نظّف fragment:
   - احذف أي جزء بعد "?"
   - إن لم يبدأ بـ "/" أضف "/"
4) الناتج هو المسار السيادي المعتمد للـ redirect/guards.

## 3) Allowlist سيادية (تُفحص دائمًا قبل /:unitSlug)
- /login
- /systems
- /switch
- /under-construction

قاعدة إلزامية:
- أي تعريف أو match لمسار `/:unitSlug/...` يجب أن يأتي بعد allowlist.
- الواجهة العامة تربط دخول الموظفين إلى /login فقط.

## 4) قواعد منع تلقائية (CI)
- منع تعريف `/:unitSlug` قبل allowlist.
- منع أي نظام فرعي من تعديل helper/allowlist دون تحديث العقود.
- منع مسارات بديلة لدخول الموظفين من الواجهة العامة.

## 5) اختبارات (لاحقًا داخل المنصة)
يُضاف اختباران على الأقل:
- عندما path موجود → يُستخدم path
- عندما path فارغ → يُستخدم fragment بعد التنظيف
