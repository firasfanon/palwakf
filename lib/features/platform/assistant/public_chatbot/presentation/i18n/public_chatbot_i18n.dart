import 'package:flutter/material.dart';

import 'package:waqf/app/routing/app_routes.dart';
import '../../../assistant_core/data/models/feature_card_item.dart';
import '../../../assistant_core/data/models/quick_action_item.dart';

class PublicChatbotI18n {
  const PublicChatbotI18n(this.locale);

  final Locale locale;

  static PublicChatbotI18n of(BuildContext context) =>
      PublicChatbotI18n(Localizations.localeOf(context));

  bool get isArabic => locale.languageCode.toLowerCase().startsWith('ar');

  String get pageTitle => isArabic ? 'اسألنا' : 'Ask Us';
  String get headerTitle =>
      isArabic ? 'شات الأوقاف العام' : 'Awqaf Public Chatbot';
  String get headerSubtitle => isArabic
      ? 'مساعد عام يجيب من المحتوى العام الموثوق فقط: التعريف بالمؤسسة، الخدمات، الأسئلة الشائعة، الروابط والنماذج، ومعلومات الوحدات.'
      : 'A public assistant that answers only from trusted public content: the institution, services, FAQs, links & forms, and unit information.';
  String get inputHint => isArabic
      ? 'اسأل عن خدمة أو رابط أو معلومة عامة...'
      : 'Ask about a service, link, or public information...';

  String get introMessage => isArabic
      ? 'مرحبًا بك في شات الأوقاف العام.\n\n'
            'هذا الشات مخصص للجمهور، ويقتصر على المحتوى العام الموثوق، مثل:\n'
            '• التعريف بالوزارة\n'
            '• الخدمات العامة والإلكترونية\n'
            '• الأسئلة الشائعة\n'
            '• الروابط والنماذج\n'
            '• معلومات الوحدات والجهات التابعة\n\n'
            'اكتب سؤالك أو اختر من الاختصارات التالية.'
      : 'Welcome to the Awqaf public chatbot.\n\n'
            'This chatbot is for the public and only uses trusted public content, such as:\n'
            '• About the ministry\n'
            '• Public and e-services\n'
            '• FAQs\n'
            '• Links and forms\n'
            '• Unit information\n\n'
            'Type your question or use one of the shortcuts below.';

  List<QuickActionItem> quickActions() {
    return [
      QuickActionItem(
        id: 'about',
        label: isArabic ? 'عن الوزارة' : 'About',
        icon: Icons.apartment_rounded,
        message: isArabic
            ? 'أريد التعرف على الوزارة'
            : 'Tell me about the ministry',
      ),
      QuickActionItem(
        id: 'services',
        label: isArabic ? 'الخدمات' : 'Services',
        icon: Icons.miscellaneous_services_rounded,
        message: isArabic
            ? 'ما هي الخدمات العامة المتاحة؟'
            : 'What public services are available?',
      ),
      QuickActionItem(
        id: 'faq',
        label: isArabic ? 'الأسئلة الشائعة' : 'FAQs',
        icon: Icons.quiz_rounded,
        message: isArabic
            ? 'ما أكثر الأسئلة الشائعة؟'
            : 'What are the common FAQs?',
      ),
      QuickActionItem(
        id: 'prayer-times',
        label: isArabic ? 'مواقيت الصلاة' : 'Prayer times',
        icon: Icons.access_time_rounded,
        message: isArabic ? 'أريد مواقيت الصلاة' : 'I need prayer times',
      ),
      QuickActionItem(
        id: 'zakat',
        label: isArabic ? 'حساب الزكاة' : 'Zakat calculator',
        icon: Icons.calculate_rounded,
        message: isArabic ? 'أريد حساب الزكاة' : 'I want to calculate zakat',
      ),
      QuickActionItem(
        id: 'nearest-mosque',
        label: isArabic ? 'أقرب مسجد' : 'Nearest mosque',
        icon: Icons.mosque_rounded,
        message: isArabic ? 'أريد أقرب مسجد' : 'I need the nearest mosque',
      ),
      QuickActionItem(
        id: 'forms',
        label: isArabic ? 'الروابط والنماذج' : 'Links & Forms',
        icon: Icons.link_rounded,
        message: isArabic
            ? 'أرشدني إلى الروابط والنماذج'
            : 'Guide me to links and forms',
      ),
      QuickActionItem(
        id: 'units',
        label: isArabic ? 'معلومات الوحدات' : 'Unit Info',
        icon: Icons.account_tree_rounded,
        message: isArabic
            ? 'أريد معلومات عن الوحدات'
            : 'I need unit information',
      ),
    ];
  }

  List<FeatureCardItem> featureCards() {
    return [
      FeatureCardItem(
        id: 'institution',
        icon: Icons.account_balance_rounded,
        title: isArabic ? 'التعريف بالمؤسسة' : 'Institution overview',
        description: isArabic
            ? 'إجابات مرتبطة بالوزارة ورسالتها والهيكل العام والروابط الرسمية.'
            : 'Answers about the ministry, its mission, structure, and official links.',
        route: AppRoutes.about,
      ),
      FeatureCardItem(
        id: 'service-guidance',
        icon: Icons.support_agent_rounded,
        title: isArabic ? 'التوجيه للخدمات' : 'Service guidance',
        description: isArabic
            ? 'يوجهك إلى الخدمة أو النموذج أو الصفحة العامة المناسبة.'
            : 'Guides you to the right public service, form, or page.',
        route: AppRoutes.services,
      ),
      FeatureCardItem(
        id: 'prayer-zakat',
        icon: Icons.volunteer_activism_rounded,
        title: isArabic ? 'مواقيت الصلاة والزكاة' : 'Prayer times & zakat',
        description: isArabic
            ? 'اختصارات مباشرة لخدمة مواقيت الصلاة وحاسبة الزكاة العامة.'
            : 'Direct shortcuts to the public prayer-times service and zakat calculator.',
        route: AppRoutes.prayerTimes,
      ),
      FeatureCardItem(
        id: 'mosques',
        icon: Icons.mosque_rounded,
        title: isArabic
            ? 'المساجد والجهات القريبة'
            : 'Mosques and nearby guidance',
        description: isArabic
            ? 'يوجهك إلى صفحة المساجد العامة ومعلومات الوحدات العامة ذات الصلة.'
            : 'Guides you to the public mosques page and relevant public unit information.',
        route: AppRoutes.mosques,
      ),
      FeatureCardItem(
        id: 'scope',
        icon: Icons.verified_user_rounded,
        title: isArabic ? 'نطاق الإجابة' : 'Answer scope',
        description: isArabic
            ? 'الجواب هنا عام فقط، ولا يشمل بيانات إدارية أو صلاحيات داخلية.'
            : 'Answers here are public only and do not include administrative or internal data.',
      ),
    ];
  }

  String get replySalam => isArabic
      ? 'أهلًا وسهلًا بك. أستطيع مساعدتك في المعلومات العامة والروابط الرسمية والخدمات المتاحة للجمهور.'
      : 'Welcome. I can help with public information, official links, and services available to visitors.';

  String get replyAbout => isArabic
      ? 'وزارة الأوقاف والشؤون الدينية تقدم خدمات عامة ومؤسسية ودينية للمجتمع الفلسطيني. أستطيع أن أوجهك إلى صفحة عن الوزارة أو الهيكل التنظيمي أو كلمة الوزير.'
      : 'The Ministry of Awqaf and Religious Affairs provides public, institutional, and religious services to the Palestinian community. I can guide you to the About page, the structure page, or the minister message.';

  String get replyServices => isArabic
      ? 'الخدمات العامة المتاحة تشمل الخدمات الإلكترونية، الشكاوى والمقترحات، مواقيت الصلاة، الزكاة، وصفحات الوحدات العامة. أخبرني أي مسار تريد وسأوجهك إليه.'
      : 'Public services include e-services, complaints and suggestions, prayer times, zakat, and public unit pages. Tell me which path you want and I will guide you to it.';

  String get replyFaq => isArabic
      ? 'أكثر الأسئلة الشائعة تدور حول الخدمات، وسائل التواصل، مواقيت الصلاة، الزكاة، وكيفية الوصول إلى النماذج والصفحات العامة.'
      : 'The most common FAQs are about services, contact information, prayer times, zakat, and how to reach forms and public pages.';

  String get replyPrayerTimes => isArabic
      ? 'يمكنني توجيهك إلى خدمة مواقيت الصلاة العامة لمعرفة المواقيت اليومية ووقت الأذان عبر الصفحة الرسمية: /prayer-times'
      : 'I can direct you to the public prayer-times service to check daily timings and adhan times: /prayer-times';

  String get replyZakat => isArabic
      ? 'يمكنك استخدام حاسبة الزكاة العامة للوصول إلى تقدير أولي للزكاة عبر الصفحة الرسمية: /home/zakat'
      : 'You can use the public zakat calculator for an initial zakat estimate from: /home/zakat';

  String get replyNearestMosque => isArabic
      ? 'يمكنني توجيهك إلى صفحة المساجد العامة لتصفح معلومات المساجد والخدمات المرتبطة بها، ثم اختيار الوحدة الأقرب لك: /mosques'
      : 'I can guide you to the public mosques page to browse mosque-related information and then select the nearest unit: /mosques';

  String get replyForms => isArabic
      ? 'يمكنني إرشادك إلى الروابط والنماذج العامة عبر الخدمات الإلكترونية أو صفحة الشكاوى ووسائل التواصل.'
      : 'I can guide you to public links and forms through e-services, complaints, and contact pages.';

  String get replyUnits => isArabic
      ? 'يمكنني مساعدتك في الوصول إلى معلومات الوحدات والمديريات والصفحات العامة التابعة لها.'
      : 'I can help you reach information about units, directorates, and their public pages.';

  String get replyContact => isArabic
      ? 'يمكنك الوصول إلى وسائل التواصل من صفحة اتصل بنا، كما أستطيع توجيهك إلى الصفحة الرسمية المطلوبة.'
      : 'You can reach contact information from the Contact page, and I can direct you to the official page you need.';

  String get replyThanks => isArabic
      ? 'على الرحب والسعة. إذا أردت صفحة أو رابطًا محددًا فأخبرني مباشرة.'
      : 'You are welcome. If you need a specific page or link, tell me directly.';

  String get replyBye => isArabic
      ? 'يسعدني مساعدتك متى شئت. يمكنك العودة إلى شات الأوقاف العام في أي وقت.'
      : 'Happy to help any time. You can return to the public Awqaf chatbot whenever you need.';

  String replyFallback(String userMessage) => isArabic
      ? 'فهمت أنك تسأل عن: "$userMessage".\n\nنطاقي هنا عام فقط. أستطيع مساعدتك في التعريف بالمؤسسة، الخدمات، الأسئلة الشائعة، الروابط والنماذج، ومعلومات الوحدات.'
      : 'I understand you are asking about: "$userMessage".\n\nMy scope here is public only. I can help with the institution, services, FAQs, links & forms, and unit information.';
}
