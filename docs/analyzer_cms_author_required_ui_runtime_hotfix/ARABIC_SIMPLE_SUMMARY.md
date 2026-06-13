# Analyzer + CMS Author Required Hotfix

## سبب الدفعة

نتيجة `flutter analyze` أظهرت:

- أخطاء syntax داخل `lib/features/platform/technical_services/domain/models/pwf_technical_service_operations_models.dart`.
- تحذيرات Riverpod بسبب استخدام `state` من extension خارج `AsyncNotifier`.
- محاولة CMS Add News أصبحت direct table access إلى `news_articles` لكنها فشلت بسبب `23502`: العمود `author` لا يقبل null.

## التصحيح

1. إصلاح موديلات Technical Services operations.
2. إزالة الوصول المباشر إلى `state` من extension files واستبداله باستدعاء `refresh()`.
3. إضافة fallback إلزامي لـ `news_articles.author = إدارة المحتوى`.
4. الإبقاء على CMS write كـ direct table access وعدم تحويله إلى RPC.

## الحدود

لا SQL، لا RLS، لا service_role، لا production approval.
