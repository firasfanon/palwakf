import 'package:flutter/material.dart';

class SharedContentFamily {
  const SharedContentFamily({
    required this.key,
    required this.label,
    required this.description,
    required this.icon,
    required this.homeBehavior,
    required this.slugBehavior,
    this.note,
  });

  final String key;
  final String label;
  final String description;
  final IconData icon;
  final String homeBehavior;
  final String slugBehavior;
  final String? note;
}

class SharedContentRegistry {
  const SharedContentRegistry._();

  static const families = <SharedContentFamily>[
    SharedContentFamily(
      key: 'news',
      label: 'الأخبار',
      description:
          'محتوى تحريري يظهر في الصفحة الرئيسية عند home ويظهر في نفس القالب الديناميكي عند slug الوحدة.',
      icon: Icons.newspaper_outlined,
      homeBehavior: 'أخبار الوزارة / PalWakf',
      slugBehavior: 'أخبار الوحدة حسب slug',
    ),
    SharedContentFamily(
      key: 'announcements',
      label: 'الإعلانات',
      description:
          'إعلانات وتنبيهات تشغيلية أو جماهيرية مرتبطة بسياق الوزارة أو الوحدة.',
      icon: Icons.campaign_outlined,
      homeBehavior: 'إعلانات وزارة / منصة',
      slugBehavior: 'إعلانات الوحدة',
    ),
    SharedContentFamily(
      key: 'activities',
      label: 'الأنشطة',
      description:
          'أنشطة الوحدة أو الوزارة ذات الطابع الدوري أو التشغيلي أو التوعوي.',
      icon: Icons.event_note_outlined,
      homeBehavior: 'أنشطة عامة للوزارة',
      slugBehavior: 'أنشطة الوحدة',
    ),
    SharedContentFamily(
      key: 'events',
      label: 'الفعاليات',
      description:
          'في هذه المرحلة تُدار الفعاليات عبر نفس جدول الأنشطة لكن بفلترة أنواع أقرب للفعاليات.',
      icon: Icons.celebration_outlined,
      homeBehavior: 'فعاليات وزارة / منصة',
      slugBehavior: 'فعاليات الوحدة',
      note:
          'مرحلة انتقالية: الفعاليات ليست جدولًا سياديًا منفصلًا بعد، لكنها مُدارة داخل لوحة التحكم من نفس مسار الأنشطة.',
    ),
    SharedContentFamily(
      key: 'gallery_photos',
      label: 'معرض الصور',
      description:
          'إدارة أصول الصور الخاصة بالوزارة أو الوحدة فوق نفس طبقة الرفع الموحدة للمحتوى المشترك.',
      icon: Icons.photo_library_outlined,
      homeBehavior: 'صور الوزارة / الصفحة الرئيسية',
      slugBehavior: 'صور الوحدة حسب slug',
      note: 'يعاد استعمال uploader الموحد نفسه بدل بناء مسار رفع منفصل للمعرض.',
    ),
    SharedContentFamily(
      key: 'gallery_videos',
      label: 'الفيديوهات',
      description:
          'إدارة الفيديوهات وروابطها أو ملفاتها داخل نفس العقد الحاكم للمحتوى المشترك.',
      icon: Icons.ondemand_video_outlined,
      homeBehavior: 'فيديوهات الوزارة / الصفحة الرئيسية',
      slugBehavior: 'فيديوهات الوحدة حسب slug',
      note:
          'يبقى دعم الرابط الخارجي متاحًا، مع توحيد الرفع المحلي تحت نفس طبقة الوسائط.',
    ),
    SharedContentFamily(
      key: 'quick_links',
      label: 'الروابط السريعة',
      description:
          'روابط مختصرة تُدار بحسب home أو slug وتغذي عناصر الربط السريعة في الصفحة الديناميكية.',
      icon: Icons.link_outlined,
      homeBehavior: 'روابط سريعة للوزارة / الصفحة الرئيسية',
      slugBehavior: 'روابط سريعة للوحدة حسب slug',
      note:
          'تُقرأ من إعدادات footer scoped وتنعكس أيضًا داخل عناصر الربط العامة.',
    ),
    SharedContentFamily(
      key: 'quick_services',
      label: 'الخدمات السريعة',
      description:
          'بطاقات الخدمات السريعة الظاهرة في الصفحة العامة وفق النطاق الحالي.',
      icon: Icons.miscellaneous_services_outlined,
      homeBehavior: 'خدمات سريعة مركزية للوزارة',
      slugBehavior: 'خدمات سريعة مرتبطة بالوحدة',
      note: 'تُدار فوق نفس footer scoped settings بدل بناء جدول جديد منفصل.',
    ),
    SharedContentFamily(
      key: 'stats',
      label: 'الإحصائيات',
      description:
          'عدادات وإحصائيات تُعرض في الصفحة الديناميكية بحسب home أو slug.',
      icon: Icons.bar_chart_outlined,
      homeBehavior: 'إحصائيات الوزارة / الصفحة الرئيسية',
      slugBehavior: 'إحصائيات الوحدة حسب slug',
      note:
          'تُحفظ كـ section settings scoped داخل homepage_sections بدل إعادة تعريف بنية جديدة.',
    ),
    SharedContentFamily(
      key: 'eservices',
      label: 'بوابة الخدمات الإلكترونية',
      description:
          'خدمات وبطاقات إلكترونية مشتركة تُدار بحسب home أو slug وتُعرض في القسم الخاص ببوابة الخدمات.',
      icon: Icons.miscellaneous_services,
      homeBehavior: 'خدمات الوزارة / الصفحة الرئيسية',
      slugBehavior: 'خدمات الوحدة حسب slug',
      note: 'تُدار كقسم homepage scoped بدل تركها static بالكامل.',
    ),
    SharedContentFamily(
      key: 'feature_highlights',
      label: 'Feature Highlights',
      description:
          'بطاقات إبراز موجزة تتغير بحسب home أو slug داخل نفس الصفحة الديناميكية.',
      icon: Icons.auto_awesome_outlined,
      homeBehavior: 'إبرازات الوزارة / الصفحة الرئيسية',
      slugBehavior: 'إبرازات الوحدة حسب slug',
      note:
          'القالب نفسه ثابت، بينما المحتوى يُدار scoped من homepage_sections.',
    ),
    SharedContentFamily(
      key: 'mini_map_teaser',
      label: 'Mini Map Teaser',
      description:
          'قسم تمهيدي للخريطة التفاعلية ضمن الصفحة العامة، مع ربط لاحق بـ Mustakshif/GIS.',
      icon: Icons.map_outlined,
      homeBehavior: 'معاينة خريطة الوزارة / الصفحة الرئيسية',
      slugBehavior: 'معاينة خريطة الوحدة حسب slug',
      note:
          'يبقى الربط النهائي مع المستكشف مكانيًا، لكن الإظهار والعناوين تُدار من المنصة.',
    ),
  ];

  static final List<SharedContentFamily> mediaFamilies = families
      .take(6)
      .toList(growable: false);

  static final List<SharedContentFamily> platformSurfaceFamilies = families
      .skip(6)
      .toList(growable: false);
}
