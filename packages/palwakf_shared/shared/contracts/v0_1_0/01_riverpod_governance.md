# Riverpod Governance — v0.1.0

## 1) النسخة المعتمدة على مستوى المنصة
- اعتماد Riverpod 3.x.
- تثبيت flutter_riverpod على ^3.2.0 (ضمن SemVer policy).

## 2) سياسة Legacy
- داخل shared (palwakf_shared): ممنوع استخدام legacy providers.
- داخل الأنظمة المنتقلة (legacy code): مسموح فقط عبر:
  - `package:flutter_riverpod/legacy.dart`
- ممنوع أي import آخر للـ legacy داخل shared.

## 3) سبب القرار
- في Riverpod 3 تم نقل:
  - StateProvider / StateNotifierProvider / ChangeNotifierProvider
  إلى import legacy لإظهار أنها غير مفضلة، لكنها مدعومة للتوافق.

## 4) ملاحظات تشغيلية مهمّة (لتجنب مفاجآت UI)
أ) Filtering بالتساوي (==)
- في Riverpod 3 أصبحت كل providers تستخدم `==` لتصفية الإشعارات.
- أثر ذلك:
  - قيم Stream/Async قد تُفلتر إذا كانت `==` تُرجع true.
  - يلزم الانتباه لنماذج البيانات (value equality) أو تخصيص updateShouldNotify في Notifier عند الضرورة.

ب) autoDispose عند code generation
- عند استخدام code generation، providers تكون autoDispose افتراضيًا.
- هذا قد يؤثر على caching إن لم تُضبط الاستراتيجية (keepAlive/refs) في المواضع الحساسة.

## 5) قواعد التزام للمشاريع الفرعية
- أي StateNotifier legacy يجب أن يبقى داخل حدود النظام الفرعي فقط.
- shared يلتزم Notifier/AsyncNotifier الحديثة.
- أي PR يغيّر سياسة Riverpod يجب أن يرفع نسخة العقود.
