# palwakf_shared (v0.1.0)

حزمة مشتركة رسمية لمشاريع PalWakf الفرعية.

## الهدف
تقليل أخطاء الدمج عبر توحيد:
- Contracts (Routes / LocalStorage keys)
- Enums (SystemKey / Permission / UserRole)
- Access contract (AccessProfile / AccessRepository)
- Scaffold مشترك (Web + Mobile) كبنية أساسية

## النطاق الحالي
v0.1.0 يثبت **العقود المشتركة** + Scaffold بسيط. هوية HTML التفصيلية (Header/Footer/Tokens المتقدمة) سيتم ترحيلها لاحقًا ضمن إصدار أعلى.

## طريقة الاستخدام (داخل أي نظام فرعي)
1) أضف في pubspec.yaml:
```yaml
dependencies:
  palwakf_shared:
    path: ../packages/palwakf_shared
```
2) استورد:
```dart
import 'package:palwakf_shared/palwakf_shared.dart';
```

## Shared Contracts

- العقود السيادية للمنصة موجودة هنا داخل الحزمة:
  - `shared/contracts/v0_1_0/`
- هذه الملفات هي المرجع الملزم لقرارات: Riverpod / Routing / RPC PWF Key / SystemKey / Versioning.

