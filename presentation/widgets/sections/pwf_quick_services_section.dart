import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../presentation/theme/pwf_home_palette.dart';
import '../pwf_section_container.dart';
import '../shared/pwf_section_title.dart';
import '../shared/pwf_hoverable.dart';
import 'package:waqf/app/routing/app_routes.dart';

class PwfQuickServicesSection extends StatelessWidget {
  const PwfQuickServicesSection({super.key, this.unitSlug = 'home'});

  final String unitSlug;

  @override
  Widget build(BuildContext context) {
    return PwfSectionContainer(
      sectionKey: 'PwfQuickServicesSection',
      child: Column(
        children: [
          const PwfSectionTitle(
            title: 'خدمات الوزارة السريعة',
            subtitle: 'الوصول السريع للخدمات الأكثر طلباً',
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              final cols = w >= 1100 ? 4 : (w >= 820 ? 3 : (w >= 560 ? 2 : 1));
              final itemW = (w - (cols - 1) * 25) / cols;

              final items = _items(context);
              return Wrap(
                spacing: 25,
                runSpacing: 25,
                children: [
                  for (final it in items)
                    SizedBox(
                      width: itemW,
                      child: _ServiceCard(item: it),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  List<_ServiceItem> _items(BuildContext context) {
    // HTML points all these links to /under-construction.
    void goUC() => context.go(AppRoutes.underConstruction);

    return const [
      _ServiceItem(
        icon: FontAwesomeIcons.comments,
        title: 'وحدة الشكاوى',
        description: 'تقديم ومتابعة الشكاوى والملاحظات إلكترونياً',
        linkText: 'فتح الخدمة',
      ),
      _ServiceItem(
        icon: FontAwesomeIcons.calendarAlt,
        title: 'مواقيت الصلاة',
        description: 'مواقيت الصلاة اليومية حسب مدن فلسطين مع اتجاه القبلة',
        linkText: 'عرض المواقيت',
        goUnderConstruction: true,
      ),
      _ServiceItem(
        icon: FontAwesomeIcons.mosque,
        title: 'ترخيص المساجد',
        description: 'طلب ترخيص لبناء مسجد جديد أو تجديد ترخيص مسجد قائم',
        linkText: 'بدء الطلب',
        goUnderConstruction: true,
      ),
      _ServiceItem(
        icon: FontAwesomeIcons.userGraduate,
        title: 'تعيين الأئمة',
        description: 'التقديم للوظائف الشاغرة للأئمة والخطباء والدعاة',
        linkText: 'التقديم الآن',
        goUnderConstruction: true,
      ),
      _ServiceItem(
        icon: FontAwesomeIcons.handsHelping,
        title: 'التبرع للأوقاف',
        description: 'التبرع لمشاريع الأوقاف وصيانة المساجد والمقدسات',
        linkText: 'التبرع الآن',
        goUnderConstruction: true,
      ),
      _ServiceItem(
        icon: FontAwesomeIcons.robot,
        title: 'المساعد الذكي (Chat)',
        description: 'مساعد ذكي للإجابة عن أسئلتكم وخدمات الوزارة',
        linkText: 'بدء المحادثة',
      ),
      _ServiceItem(
        icon: FontAwesomeIcons.bookReader,
        title: 'دورات تحفيظ القرآن',
        description: 'التسجيل في دورات تحفيظ القرآن للكبار والصغار',
        linkText: 'التسجيل',
        goUnderConstruction: true,
      ),
      _ServiceItem(
        icon: FontAwesomeIcons.landmark,
        title: 'إدارة الأوقاف',
        description: 'خدمات إدارة وتنمية الأوقاف الإسلامية في فلسطين',
        linkText: 'الدخول للخدمة',
        goUnderConstruction: true,
      ),
      _ServiceItem(
        icon: FontAwesomeIcons.chartLine,
        title: 'تقارير الأوقاف',
        description: 'تقارير وإحصائيات عن الأوقاف والمشاريع الوقفية',
        linkText: 'عرض التقارير',
        goUnderConstruction: true,
      ),
      _ServiceItem(
        icon: FontAwesomeIcons.handshake,
        title: 'شراكات الأوقاف',
        description: 'الشراكات والتعاون مع المؤسسات الداعمة للأوقاف',
        linkText: 'المزيد',
        goUnderConstruction: true,
      ),
    ].map((it) {
      // Attach runtime callback without changing const shape.
      switch (it.title) {
        case 'وحدة الشكاوى':
          return it.copyWith(onTap: () => context.go('/complaints'));
        case 'مواقيت الصلاة':
          return it.copyWith(onTap: () => context.go('/prayer-times'));
        case 'التبرع للأوقاف':
          return it.copyWith(onTap: () => context.go('/zakat'));
        case 'المساعد الذكي (Chat)':
          return it.copyWith(onTap: () => context.go('/admin/chatbot'));
        case 'دورات تحفيظ القرآن':
          // optional: route to Quran page if available
          return it.copyWith(onTap: () => context.go('/quran'));
        default:
          if (!it.goUnderConstruction) return it;
          return it.copyWith(onTap: goUC);
      }
    }).toList();
  }
}

class _ServiceItem {
  final IconData icon;
  final String title;
  final String description;
  final String linkText;
  final VoidCallback? onTap;
  final bool goUnderConstruction;

  const _ServiceItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.linkText,
    this.onTap,
    this.goUnderConstruction = false,
  });

  _ServiceItem copyWith({VoidCallback? onTap}) {
    return _ServiceItem(
      icon: icon,
      title: title,
      description: description,
      linkText: linkText,
      onTap: onTap ?? this.onTap,
      goUnderConstruction: goUnderConstruction,
    );
  }
}

class _ServiceCard extends StatefulWidget {
  const _ServiceCard({required this.item});

  final _ServiceItem item;

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final shimmerX = _hover ? 1.0 : -1.0;

    return PwfHoverable(
      onTap: widget.item.onTap,
      hoverTranslate: const Offset(0, -10),
      borderRadius: PwfHomeRadii.br16,
      child: Stack(
        children: [
          // Base card
          Container(
            decoration: BoxDecoration(
              color: PwfHomePalette.cardBg,
              borderRadius: PwfHomeRadii.br16,
              border: const Border(
                top: BorderSide(color: PwfHomePalette.primary, width: 4),
              ),
            ),
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(widget.item.icon, size: 40, color: PwfHomePalette.primary),
                const SizedBox(height: 18),
                Text(
                  widget.item.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: PwfHomePalette.primary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.item.description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: PwfHomePalette.gray,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: widget.item.onTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.item.linkText,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: PwfHomePalette.secondary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_back,
                        size: 16,
                        color: PwfHomePalette.secondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Shimmer overlay (service-card::before)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 120),
                opacity: _hover ? 1 : 1,
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 600),
                  alignment: Alignment(shimmerX, 0),
                  curve: Curves.easeOut,
                  child: Container(
                    width: 200,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          Colors.transparent,
                          Color(0x1AFFFFFF),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Mouse detector for shimmer direction (keep separate from hoverable shadow)
          Positioned.fill(
            child: MouseRegion(
              onEnter: (_) => setState(() => _hover = true),
              onExit: (_) => setState(() => _hover = false),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}
