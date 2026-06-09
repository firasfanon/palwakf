import 'package:flutter/foundation.dart';

@immutable
class PwfSisRolloutGate {
  const PwfSisRolloutGate({
    required this.area,
    required this.requiredEvidenceAr,
    required this.ownerAr,
    required this.status,
    required this.blockerPolicyAr,
  });

  final String area;
  final String requiredEvidenceAr;
  final String ownerAr;
  final PwfSisRolloutStatus status;
  final String blockerPolicyAr;
}

@immutable
class PwfSisClosureItem {
  const PwfSisClosureItem({
    required this.area,
    required this.evidenceAr,
    required this.status,
    required this.decisionAr,
  });

  final String area;
  final String evidenceAr;
  final PwfSisRolloutStatus status;
  final String decisionAr;
}

enum PwfSisRolloutStatus {
  preserved,
  evidenceAccepted,
  readyForUat,
  pendingEvidence,
  conditionallyApproved,
  blocked,
  notApproved,
}

extension PwfSisRolloutStatusX on PwfSisRolloutStatus {
  String get labelAr {
    switch (this) {
      case PwfSisRolloutStatus.preserved:
        return 'محفوظ';
      case PwfSisRolloutStatus.evidenceAccepted:
        return 'دليل مقبول';
      case PwfSisRolloutStatus.readyForUat:
        return 'جاهز للاختبار';
      case PwfSisRolloutStatus.pendingEvidence:
        return 'بانتظار الدليل';
      case PwfSisRolloutStatus.conditionallyApproved:
        return 'اعتماد مشروط';
      case PwfSisRolloutStatus.blocked:
        return 'مانع';
      case PwfSisRolloutStatus.notApproved:
        return 'غير معتمد';
    }
  }
}

class PwfSisRolloutPlan {
  const PwfSisRolloutPlan._();

  static const phaseTitle = 'PWF-SIS-05 Controlled Wave 2 Scope Decision';

  static const rolloutWaves = <PwfSisRolloutGate>[
    PwfSisRolloutGate(
      area: 'Wave 0 — Platform Design System',
      requiredEvidenceAr:
          'فتح معرض المكونات وجسر الهوية وصفحة rollout وأدلة Chrome/analyzer بدون أخطاء.',
      ownerAr: 'Platform UI Governance',
      status: PwfSisRolloutStatus.evidenceAccepted,
      blockerPolicyAr:
          'أي overflow أو render exception لاحق يعيد الموجة إلى review.',
    ),
    PwfSisRolloutGate(
      area: 'Wave 1 — Awqaf Pilot فقط',
      requiredEvidenceAr:
          'Superuser desktop evidence مقبول؛ mobile/tablet/restricted-role ما زالت مطلوبة قبل التعميم خارج pilot.',
      ownerAr: 'Platform + Awqaf Integration',
      status: PwfSisRolloutStatus.conditionallyApproved,
      blockerPolicyAr:
          'الاعتماد محصور في Pilot بصري read-only ولا يربط أو يغير waqf_assets أو runtime أوقاف الفعلي.',
    ),
    PwfSisRolloutGate(
      area: 'Wave 2 — Media Center read-only visual candidate',
      requiredEvidenceAr:
          'اختيار media_center كمرشح منخفض/متوسط المخاطر بشرط read-only visual pilot، responsive evidence، restricted role evidence، وconsole review.',
      ownerAr: 'Platform PMO + Media Center Owner',
      status: PwfSisRolloutStatus.readyForUat,
      blockerPolicyAr:
          'ممنوع التعميم الجماعي أو تعديل workflow/publish/delete قبل UAT مستقل وrollback موثق.',
    ),
    PwfSisRolloutGate(
      area: 'Wave 3 — Rollout تدريجي حسب النظام',
      requiredEvidenceAr:
          'مصفوفة UAT لكل نظام مع rollback وcontrast gate وإثبات responsive مستقل.',
      ownerAr: 'System Owner + Platform Owner',
      status: PwfSisRolloutStatus.notApproved,
      blockerPolicyAr: 'كل نظام يحتاج evidence مستقل ولا يرث اعتماد نظام آخر.',
    ),
  ];

  static const productionEvidence = <PwfSisRolloutGate>[
    PwfSisRolloutGate(
      area: 'Component Gallery',
      requiredEvidenceAr: 'Desktop evidence + analyzer clean + Chrome startup.',
      ownerAr: 'UI QA',
      status: PwfSisRolloutStatus.evidenceAccepted,
      blockerPolicyAr: 'أي خطأ layout يمنع production gate.',
    ),
    PwfSisRolloutGate(
      area: 'Visual Identity Bridge',
      requiredEvidenceAr:
          'ظهور contrast gate + override preview + rollback card.',
      ownerAr: 'Visual Identity Admin',
      status: PwfSisRolloutStatus.evidenceAccepted,
      blockerPolicyAr: 'أي override منخفض التباين يجب أن يظهر كمرفوض.',
    ),
    PwfSisRolloutGate(
      area: 'Override/Rollback UAT',
      requiredEvidenceAr:
          'preview آمن + rejected low contrast + rollback steps.',
      ownerAr: 'Platform Governance',
      status: PwfSisRolloutStatus.evidenceAccepted,
      blockerPolicyAr: 'لا publish بلا versioning وrollback.',
    ),
    PwfSisRolloutGate(
      area: 'Responsive Evidence',
      requiredEvidenceAr:
          'Desktop مقبول؛ mobile 390 وtablet 1024 مطلوبان نصًا/صورة.',
      ownerAr: 'Browser UAT',
      status: PwfSisRolloutStatus.pendingEvidence,
      blockerPolicyAr: 'أي overflow أفقي في mobile يمنع التعميم.',
    ),
    PwfSisRolloutGate(
      area: 'Role-Based UI Validation',
      requiredEvidenceAr:
          'superuser مقبول؛ restricted/platform-admin evidence مطلوب.',
      ownerAr: 'RBAC QA',
      status: PwfSisRolloutStatus.pendingEvidence,
      blockerPolicyAr: 'لا تظهر أدوات platformAdmin لمستخدم restricted.',
    ),
    PwfSisRolloutGate(
      area: 'Console Review',
      requiredEvidenceAr:
          'Chrome startup موجود؛ يلزم نص console clean بعد فتح الصفحات الأربع.',
      ownerAr: 'Browser UAT',
      status: PwfSisRolloutStatus.pendingEvidence,
      blockerPolicyAr: 'render/layout exceptions تمنع إغلاق المسار.',
    ),
    PwfSisRolloutGate(
      area: 'Database Wave B',
      requiredEvidenceAr: 'محفوظ وغير منفذ ضمن PWF-SIS-05.',
      ownerAr: 'Database Migration Program',
      status: PwfSisRolloutStatus.preserved,
      blockerPolicyAr: 'لا SQL54/55 ضمن هذه الدفعة.',
    ),
    PwfSisRolloutGate(
      area: 'Production Gate',
      requiredEvidenceAr: 'قرار رسمي بعد استكمال كل الأدلة غير المكتملة.',
      ownerAr: 'Platform Owner',
      status: PwfSisRolloutStatus.notApproved,
      blockerPolicyAr: 'لا production approval في PWF-SIS-05.',
    ),
  ];

  static const roleValidation = <PwfSisRolloutGate>[
    PwfSisRolloutGate(
      area: 'Superuser',
      requiredEvidenceAr:
          'يرى كل صفحات PWF-SIS ويستطيع فتح rollout/bridge/pilot/gallery.',
      ownerAr: 'RBAC QA',
      status: PwfSisRolloutStatus.evidenceAccepted,
      blockerPolicyAr: 'فشل superuser يعني route/access contract blocker.',
    ),
    PwfSisRolloutGate(
      area: 'Platform Admin',
      requiredEvidenceAr:
          'يرى أدوات PWF-SIS حسب manageSystems دون صلاحيات root عامة.',
      ownerAr: 'RBAC QA',
      status: PwfSisRolloutStatus.pendingEvidence,
      blockerPolicyAr: 'لا publish بلا صلاحية إدارة أنظمة/هوية.',
    ),
    PwfSisRolloutGate(
      area: 'Restricted Employee',
      requiredEvidenceAr:
          'لا يرى أدوات PWF-SIS platform governance، ولا يحصل على data leakage.',
      ownerAr: 'RBAC QA',
      status: PwfSisRolloutStatus.pendingEvidence,
      blockerPolicyAr: 'أي ظهور غير مصرّح يعد blocker.',
    ),
  ];

  static const wave2CandidateSystems = <PwfSisRolloutGate>[
    PwfSisRolloutGate(
      area: 'Media Center',
      requiredEvidenceAr:
          'مرشح Wave 2: تطبيق PWF-SIS كطبقة visual/read-only على صفحات المركز الإعلامي دون publish أو archive أو delete.',
      ownerAr: 'Media Center Owner + Platform UI Governance',
      status: PwfSisRolloutStatus.readyForUat,
      blockerPolicyAr:
          'أي تغيير في editorial workflow أو public visibility خارج نطاق العرض المرئي يعد blocker.',
    ),
    PwfSisRolloutGate(
      area: 'Service Center',
      requiredEvidenceAr:
          'مؤجل بسبب وجود نماذج طلبات وتتبع وحساسية بيانات الجمهور؛ يحتاج privacy evidence قبل Wave لاحقة.',
      ownerAr: 'Platform Services Owner',
      status: PwfSisRolloutStatus.pendingEvidence,
      blockerPolicyAr:
          'لا يطبق PWF-SIS على نماذج إرسال الطلبات قبل فحص accessibility/privacy/submit flow.',
    ),
    PwfSisRolloutGate(
      area: 'Tasks',
      requiredEvidenceAr:
          'مؤجل بسبب workflow تشغيلي وتعيينات مستخدمين ومهام داخلية.',
      ownerAr: 'Tasks System Owner',
      status: PwfSisRolloutStatus.pendingEvidence,
      blockerPolicyAr: 'لا تغيير على Kanban/forms/actions قبل UAT دورية.',
    ),
    PwfSisRolloutGate(
      area: 'Cases',
      requiredEvidenceAr:
          'مؤجل لحساسية القضايا القانونية والملفات المرتبطة بها.',
      ownerAr: 'Cases System Owner',
      status: PwfSisRolloutStatus.blocked,
      blockerPolicyAr: 'legal/privacy sensitivity يمنع Wave 2.',
    ),
    PwfSisRolloutGate(
      area: 'Billing',
      requiredEvidenceAr: 'مؤجل بسبب حساسية مالية وسداد وفواتير.',
      ownerAr: 'Billing System Owner',
      status: PwfSisRolloutStatus.blocked,
      blockerPolicyAr: 'لا visual rollout قبل financial UAT وrollback منفصل.',
    ),
    PwfSisRolloutGate(
      area: 'Mustakshif / GIS',
      requiredEvidenceAr:
          'مؤجل بسبب خرائط وطبقات ثقيلة وحاجة performance evidence.',
      ownerAr: 'GIS Owner',
      status: PwfSisRolloutStatus.pendingEvidence,
      blockerPolicyAr: 'لا تغيير للخرائط قبل BBOX/zoom/performance evidence.',
    ),
  ];

  static const wave2RiskMatrix = <PwfSisRolloutGate>[
    PwfSisRolloutGate(
      area: 'Data mutation risk',
      requiredEvidenceAr:
          'Wave 2 لا يسمح بأي إدخال/نشر/حذف؛ العرض فقط حتى إغلاق UAT.',
      ownerAr: 'Platform Governance',
      status: PwfSisRolloutStatus.readyForUat,
      blockerPolicyAr: 'أي action button منتج يظهر ضمن pilot يعد blocker.',
    ),
    PwfSisRolloutGate(
      area: 'RBAC leakage risk',
      requiredEvidenceAr:
          'superuser/platform-admin/restricted evidence لكل route في candidate.',
      ownerAr: 'RBAC QA',
      status: PwfSisRolloutStatus.pendingEvidence,
      blockerPolicyAr:
          'ظهور أدوات platform governance أو محتوى غير مصرح لمستخدم restricted يمنع Wave 2.',
    ),
    PwfSisRolloutGate(
      area: 'Responsive risk',
      requiredEvidenceAr:
          'desktop + tablet 1024 + mobile 390 مع console clean بعد فتح candidate pages.',
      ownerAr: 'Browser UAT',
      status: PwfSisRolloutStatus.pendingEvidence,
      blockerPolicyAr:
          'أي RenderFlex overflow أو horizontal leak يمنع rollout.',
    ),
    PwfSisRolloutGate(
      area: 'Visual identity override risk',
      requiredEvidenceAr:
          'contrast gate وrollback versioning قبل أي publish للهوية على candidate.',
      ownerAr: 'Visual Identity Admin',
      status: PwfSisRolloutStatus.pendingEvidence,
      blockerPolicyAr: 'أي override منخفض التباين يبقى rejected ولا ينشر.',
    ),
    PwfSisRolloutGate(
      area: 'Sovereign boundary risk',
      requiredEvidenceAr:
          'لا waqf_assets ولا schema waqf ولا awqaf_system runtime ضمن Wave 2.',
      ownerAr: 'Platform Owner',
      status: PwfSisRolloutStatus.preserved,
      blockerPolicyAr: 'أي DDL/DML سيادي خارج نطاق المرشح يعد blocker.',
    ),
  ];

  static const wave2EvidenceExpansion = <PwfSisRolloutGate>[
    PwfSisRolloutGate(
      area: 'Candidate route inventory',
      requiredEvidenceAr:
          'حصر routes الخاصة بالمركز الإعلامي قبل أي تطبيق مرئي.',
      ownerAr: 'Platform PMO',
      status: PwfSisRolloutStatus.readyForUat,
      blockerPolicyAr: 'لا يطبق PWF-SIS على route غير مصنف في المصفوفة.',
    ),
    PwfSisRolloutGate(
      area: 'Responsive screenshots',
      requiredEvidenceAr:
          'desktop/tablet/mobile لكل صفحة مرشحة مع عدم وجود overflow.',
      ownerAr: 'Browser UAT',
      status: PwfSisRolloutStatus.pendingEvidence,
      blockerPolicyAr: 'صور desktop فقط غير كافية لـ Wave 2.',
    ),
    PwfSisRolloutGate(
      area: 'Restricted role validation',
      requiredEvidenceAr:
          'مستخدم restricted لا يرى أدوات تحرير/نشر أو بيانات غير مصرح بها.',
      ownerAr: 'RBAC QA',
      status: PwfSisRolloutStatus.pendingEvidence,
      blockerPolicyAr: 'أي leakage يمنع candidate rollout.',
    ),
    PwfSisRolloutGate(
      area: 'Console review closure',
      requiredEvidenceAr:
          'سجل نصي بعد فتح candidate pages يؤكد عدم وجود render/layout exceptions.',
      ownerAr: 'Browser UAT',
      status: PwfSisRolloutStatus.pendingEvidence,
      blockerPolicyAr: 'الـ console clean شرط gate لا توصية.',
    ),
    PwfSisRolloutGate(
      area: 'Rollback decision',
      requiredEvidenceAr:
          'إثبات أن العودة إلى shell السابق ممكنة دون كسر route أو بيانات.',
      ownerAr: 'Platform Owner',
      status: PwfSisRolloutStatus.pendingEvidence,
      blockerPolicyAr: 'لا Wave 2 approval بلا rollback route/style switch.',
    ),
  ];

  static const closureItems = <PwfSisClosureItem>[
    PwfSisClosureItem(
      area: 'Analyzer',
      evidenceAr: 'No issues found بعد PWF-SIS-04.2.',
      status: PwfSisRolloutStatus.evidenceAccepted,
      decisionAr: 'مغلق كدليل كود.',
    ),
    PwfSisClosureItem(
      area: 'Chrome startup',
      evidenceAr:
          'Environment/Storage/Supabase/Visual Identity bootstrap تعمل.',
      status: PwfSisRolloutStatus.evidenceAccepted,
      decisionAr: 'مغلق كدليل إقلاع.',
    ),
    PwfSisClosureItem(
      area: 'Desktop superuser pages',
      evidenceAr: 'الصفحات الأربع مفتوحة في المتصفح كـ superuser.',
      status: PwfSisRolloutStatus.evidenceAccepted,
      decisionAr: 'Wave 0 مقبول وWave 1 pilot مشروط.',
    ),
    PwfSisClosureItem(
      area: 'Mobile/tablet responsive',
      evidenceAr: 'لم تصل صور mobile/tablet بعد.',
      status: PwfSisRolloutStatus.pendingEvidence,
      decisionAr: 'يبقى blocker قبل إغلاق المسار كاملًا.',
    ),
    PwfSisClosureItem(
      area: 'Restricted role validation',
      evidenceAr: 'لا يوجد دليل restricted user بعد PWF-SIS-04.2.',
      status: PwfSisRolloutStatus.pendingEvidence,
      decisionAr: 'يبقى blocker قبل التعميم خارج pilot.',
    ),
    PwfSisClosureItem(
      area: 'Console review text',
      evidenceAr: 'سجل startup موجود؛ يلزم مراجعة console بعد فتح الصفحات.',
      status: PwfSisRolloutStatus.pendingEvidence,
      decisionAr: 'يبقى blocker قبل إغلاق المسار كاملًا.',
    ),
    PwfSisClosureItem(
      area: 'Database Wave B',
      evidenceAr: 'لم تنفذ SQL54/SQL55 ضمن PWF-SIS.',
      status: PwfSisRolloutStatus.preserved,
      decisionAr:
          'محفوظ لمسار قاعدة البيانات ولا يحجب إغلاق PWF-SIS UI جزئيًا.',
    ),
  ];

  static const wave2ExecutionEvidence = <PwfSisRolloutGate>[
    PwfSisRolloutGate(
      area: 'Media Center route inventory',
      requiredEvidenceAr:
          'توثيق كل مسارات /admin/media-center وتصنيفها حسب الخطر والمالك قبل أي تطبيق visual pilot.',
      ownerAr: 'Platform UI Governance + Media Center Owner',
      status: PwfSisRolloutStatus.evidenceAccepted,
      blockerPolicyAr: 'أي مسار غير مفهرس يؤجل التنفيذ.',
    ),
    PwfSisRolloutGate(
      area: 'Analyzer after N2.50',
      requiredEvidenceAr:
          'dart format + flutter analyze بعد تطبيق صفحة wave-2-scope والجرد.',
      ownerAr: 'Local Flutter QA',
      status: PwfSisRolloutStatus.pendingEvidence,
      blockerPolicyAr: 'أي issue داخل lib يمنع تنفيذ Wave 2.',
    ),
    PwfSisRolloutGate(
      area: 'Browser UAT for Media Center',
      requiredEvidenceAr:
          'فتح /admin/media-center والمسارات منخفضة المخاطر على desktop/tablet/mobile بدون overflow أو console exception.',
      ownerAr: 'Browser UAT',
      status: PwfSisRolloutStatus.pendingEvidence,
      blockerPolicyAr:
          'أي RenderFlex overflow أو routing failure يؤجل التنفيذ.',
    ),
    PwfSisRolloutGate(
      area: 'Restricted role validation',
      requiredEvidenceAr:
          'إثبات أن مستخدم restricted لا يرى أزرار publish/archive/delete ولا أدوات governance خارج صلاحياته.',
      ownerAr: 'RBAC QA',
      status: PwfSisRolloutStatus.pendingEvidence,
      blockerPolicyAr: 'أي تسرب صلاحيات أو بيانات يمنع التنفيذ.',
    ),
    PwfSisRolloutGate(
      area: 'Console review',
      requiredEvidenceAr:
          'نص console بعد فتح صفحات media candidate يثبت عدم وجود render/layout/runtime exceptions.',
      ownerAr: 'Browser UAT',
      status: PwfSisRolloutStatus.pendingEvidence,
      blockerPolicyAr: 'أي exception يساوي blocker.',
    ),
    PwfSisRolloutGate(
      area: 'Execution decision',
      requiredEvidenceAr:
          'قرار N2.51: defer، لأن الجرد جاهز لكن أدلة Media Center المستقلة لم تصل بعد.',
      ownerAr: 'Platform PMO',
      status: PwfSisRolloutStatus.notApproved,
      blockerPolicyAr: 'لا تنفيذ فعلي قبل N2.52 وبعد evidence مستقل.',
    ),
  ];
}
