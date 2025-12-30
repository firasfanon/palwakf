// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class SAr extends S {
  SAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'نظام إدارة الأوقاف';

  @override
  String get systemDescription => 'نظام لإدارة وتسجيل العقارات الوقفية';

  @override
  String get registerNewProperty => 'تسجيل عقار وقفي جديد';

  @override
  String get viewProperties => 'عرض العقارات';

  @override
  String get comingSoon => 'قريباً';

  @override
  String get featureInDevelopment => 'هذه الميزة قيد التطوير حالياً';

  @override
  String get systemInfo => 'معلومات النظام';

  @override
  String get ministry => 'وزارة الأوقاف والشؤون الإسلامية';

  @override
  String get rights => 'جميع الحقوق محفوظة';

  @override
  String get propertyRegistration => 'تسجيل عقار وقفي';

  @override
  String get step1 => 'الخطوة 1';

  @override
  String get step2 => 'الخطوة 2';

  @override
  String get step3 => 'الخطوة 3';

  @override
  String get step4 => 'الخطوة 4';

  @override
  String get previous => 'السابق';

  @override
  String get next => 'التالي';

  @override
  String get save => 'حفظ';

  @override
  String get propertyType => 'نوع العقار';

  @override
  String get selectPropertyType => 'اختر نوع العقار';

  @override
  String get pleaseSelectPropertyType => 'الرجاء اختيار نوع العقار';

  @override
  String get location => 'الموقع';

  @override
  String get governorate => 'المحافظة';

  @override
  String get pleaseSelectGovernorate => 'الرجاء اختيار المحافظة';

  @override
  String get sequenceNumber => 'الرقم التسلسلي';

  @override
  String get sequenceValidation => 'يجب أن يكون بين 1 و 999';

  @override
  String get pleaseEnterSequence => 'الرجاء إدخال الرقم التسلسلي';

  @override
  String get pleaseEnterLocation => 'الرجاء إدخال تفاصيل الموقع';

  @override
  String get coordinates => 'الإحداثيات';

  @override
  String get longitude => 'خط الطول';

  @override
  String get latitude => 'خط العرض';

  @override
  String get propertyDetails => 'تفاصيل العقار';

  @override
  String get propertyName => 'اسم العقار';

  @override
  String get pleaseEnterPropertyName => 'الرجاء إدخال اسم العقار';

  @override
  String get area => 'المساحة';

  @override
  String get registrationDate => 'تاريخ التسجيل';

  @override
  String get selectDate => 'اختر تاريخ';

  @override
  String get deedNumber => 'رقم الصك';

  @override
  String get description => 'الوصف';

  @override
  String get notes => 'ملاحظات';

  @override
  String get nationalId => 'الرقم الوطني';

  @override
  String get registrationDetails => 'تفاصيل التسجيل';

  @override
  String successMessage(Object nationalId) {
    return 'تم تسجيل العقار بنجاح برقم وطني: $nationalId';
  }

  @override
  String errorMessage(Object error) {
    return 'خطأ: $error';
  }
}
