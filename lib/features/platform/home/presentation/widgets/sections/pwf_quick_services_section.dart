import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:waqf/app/routing/app_routes.dart';
import 'package:waqf/data/models/footer_settings.dart';
import 'package:waqf/features/platform/assistant/assistant_core/data/services/chat_entry_service.dart';
import 'package:waqf/presentation/providers/footer_settings_provider.dart';
import 'package:waqf/presentation/providers/unit_context_provider.dart';

import '../../../data/models/pwf_public_service_catalog_item.dart';
import '../../../data/providers/pwf_public_services_catalog_providers.dart';
import '../../../presentation/theme/pwf_home_palette.dart';
import '../../screens/pages/pwf_public_content_shared.dart';
import '../pwf_section_container.dart';
import '../shared/pwf_hoverable.dart';
import '../shared/pwf_section_title.dart';

class PwfQuickServicesSection extends ConsumerWidget {
  const PwfQuickServicesSection({super.key, this.unitSlug = 'home'});

  final String unitSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final normalizedSlug = unitSlug.trim().isEmpty
        ? 'home'
        : unitSlug.trim().toLowerCase();
    final settings = ref
        .watch(publicFooterSettingsProvider(normalizedSlug))
        .maybeWhen(data: (value) => value, orElse: () => null);
    final ownerHomeServices = ref
        .watch(pwfPlatformNavigationHomeServicesProvider)
        .maybeWhen(
          data: (value) => value,
          orElse: () => const <PwfPublicServiceCatalogItem>[],
        );
    final unit = ref.watch(orgUnitBySlugProvider(normalizedSlug)).valueOrNull;
    final scopeLabel = pwfResolveScopeLabel(
      unitSlug: normalizedSlug,
      unit: unit,
      contextualLabel: (settings?.ministryName ?? '').trim().isEmpty
          ? null
          : settings?.ministryName,
    );

    return PwfSectionContainer(
      sectionKey: 'PwfQuickServicesSection',
      child: Column(
        children: [
          PwfSectionTitle(
            title: normalizedSlug == 'home'
                ? 'الخدمات العامة السريعة'
                : 'الخدمات السريعة لـ $scopeLabel',
            subtitle: normalizedSlug == 'home'
                ? 'وصول مباشر إلى أبرز الخدمات والمعلومات العامة الأكثر استخداماً'
                : 'خدمات سريعة تُدار من نفس العقد الحاكم وتُعرض بحسب $scopeLabel داخل الصفحة الديناميكية.',
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              final cols = w >= 1100 ? 4 : (w >= 820 ? 3 : (w >= 560 ? 2 : 1));
              final itemW = (w - (cols - 1) * 25) / cols;

              final items = _items(
                context,
                normalizedSlug,
                settings,
                ownerHomeServices: ownerHomeServices,
                scopeLabel: scopeLabel,
              );
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

  List<_ServiceItem> _items(
    BuildContext context,
    String unitSlug,
    FooterSettings? settings, {
    required List<PwfPublicServiceCatalogItem> ownerHomeServices,
    required String scopeLabel,
  }) {
    final ownerManaged = ownerHomeServices
        .map(
          (item) => _ServiceItem(
            icon: _iconForRoute(item.link),
            title: item.title,
            description: unitSlug == 'home'
                ? 'خدمة سريعة مقروءة من platform_navigation عبر واجهة public owner-read محكومة.'
                : 'خدمة سريعة مقروءة من platform_navigation وتُعرض ضمن نطاق $scopeLabel عند تفعيل بوابة التشغيل.',
            linkText: 'فتح الخدمة',
            onTap: () async {
              final target = item.link.trim();
              if (target.startsWith('http://') ||
                  target.startsWith('https://')) {
                await launchUrlString(target);
              } else {
                context.go(target.startsWith('/') ? target : '/$target');
              }
            },
          ),
        )
        .toList(growable: false);

    if (ownerManaged.isNotEmpty) return ownerManaged;

    final managed = (settings?.servicesLinks ?? const <FooterLink>[])
        .where(
          (e) =>
              e.enabled &&
              e.label.trim().isNotEmpty &&
              e.route.trim().isNotEmpty,
        )
        .map(
          (link) => _ServiceItem(
            icon: _iconForRoute(link.route),
            title: link.label,
            description: unitSlug == 'home'
                ? 'خدمة سريعة مُدارة مركزيًا وتظهر على الصفحة الرئيسية.'
                : 'خدمة سريعة مرتبطة بـ $scopeLabel وتُعرض حسب النطاق الحالي.',
            linkText: 'فتح الخدمة',
            onTap: () async {
              final target = link.route.trim();
              if (target.startsWith('http://') ||
                  target.startsWith('https://')) {
                await launchUrlString(target);
              } else {
                context.go(target.startsWith('/') ? target : '/$target');
              }
            },
          ),
        )
        .toList(growable: false);

    if (managed.isNotEmpty) return managed;

    void goUC() => context.go(AppRoutes.services);

    return [
      _ServiceItem(
        icon: Icons.forum,
        title: 'وحدة الشكاوى',
        description: 'تقديم ومتابعة الشكاوى والملاحظات إلكترونياً',
        linkText: 'فتح الخدمة',
      ),
      _ServiceItem(
        icon: Icons.event,
        title: 'مواقيت الصلاة',
        description: 'مواقيت الصلاة اليومية حسب مدن فلسطين مع اتجاه القبلة',
        linkText: 'عرض المواقيت',
        goUnderConstruction: true,
      ),
      _ServiceItem(
        icon: Icons.account_balance,
        title: 'دليل المساجد',
        description:
            'استعراض معلومات المساجد والخدمات المرتبطة بها على الواجهة العامة',
        linkText: 'فتح الدليل',
      ),
      _ServiceItem(
        icon: Icons.school,
        title: 'الخدمات الإلكترونية',
        description:
            'الوصول إلى الخدمات الإلكترونية والنماذج العامة المتاحة عبر المنصة',
        linkText: 'فتح الخدمات',
      ),
      _ServiceItem(
        icon: Icons.volunteer_activism,
        title: 'الزكاة والتبرعات',
        description:
            'الوصول إلى خدمات الزكاة والتبرعات والمساهمات الوقفية العامة',
        linkText: 'التبرع الآن',
        goUnderConstruction: true,
      ),
      _ServiceItem(
        icon: Icons.smart_toy,
        title: 'اسألنا',
        description:
            'شات عام للإجابة عن الأسئلة العامة والخدمات والمعلومات الأساسية',
        linkText: 'بدء المحادثة',
      ),
      _ServiceItem(
        icon: Icons.menu_book,
        title: 'القرآن الكريم',
        description:
            'الوصول إلى صفحات وبرامج القرآن الكريم والدورات والأنشطة المرتبطة بها',
        linkText: 'فتح الصفحة',
      ),
      _ServiceItem(
        icon: Icons.account_balance,
        title: 'خدمات الأوقاف',
        description:
            'معلومات وخدمات عامة مرتبطة بالأوقاف الإسلامية والمشاريع الوقفية',
        linkText: 'عرض الخدمات',
      ),
      _ServiceItem(
        icon: Icons.show_chart,
        title: 'اتصل بنا',
        description:
            'قنوات التواصل الرسمية ومعلومات الاتصال والعناوين وساعات الدوام',
        linkText: 'عرض البيانات',
      ),
      _ServiceItem(
        icon: Icons.groups,
        title: 'الأخبار والفعاليات',
        description:
            'متابعة الأخبار الحديثة والأنشطة والفعاليات العامة الخاصة بالوزارة',
        linkText: 'استعراض المحتوى',
      ),
    ].map((it) {
      switch (it.title) {
        case 'وحدة الشكاوى':
          return it.copyWith(onTap: () => context.go(AppRoutes.complaints));
        case 'مواقيت الصلاة':
          return it.copyWith(onTap: () => context.go(AppRoutes.prayerTimes));
        case 'دليل المساجد':
          return it.copyWith(onTap: () => context.go(AppRoutes.mosques));
        case 'الخدمات الإلكترونية':
          return it.copyWith(onTap: () => context.go(AppRoutes.eservices));
        case 'الزكاة والتبرعات':
          return it.copyWith(onTap: () => context.go(AppRoutes.zakat));
        case 'اسألنا':
          return it.copyWith(onTap: () => ChatEntryService.open(context));
        case 'القرآن الكريم':
          return it.copyWith(onTap: () => context.go(AppRoutes.quran));
        case 'خدمات الأوقاف':
          return it.copyWith(onTap: () => context.go(AppRoutes.services));
        case 'اتصل بنا':
          return it.copyWith(onTap: () => context.go(AppRoutes.contact));
        case 'الأخبار والفعاليات':
          return it.copyWith(onTap: () => context.go(AppRoutes.news));
        default:
          if (!it.goUnderConstruction) return it;
          return it.copyWith(onTap: goUC);
      }
    }).toList();
  }
}

IconData _iconForRoute(String route) {
  final normalized = route.trim().toLowerCase();
  if (normalized.contains('complaint')) return Icons.forum;
  if (normalized.contains('prayer')) return Icons.event;
  if (normalized.contains('mosque')) return Icons.account_balance;
  if (normalized.contains('eservices')) return Icons.school;
  if (normalized.contains('zakat')) return Icons.volunteer_activism;
  if (normalized.contains('quran')) return Icons.menu_book;
  if (normalized.contains('service')) return Icons.account_balance;
  return Icons.link;
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
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: _hover ? 1 : 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: PwfHomeRadii.br16,
                    gradient: LinearGradient(
                      begin: Alignment(-1.0 + shimmerX, -1),
                      end: Alignment(1.0 + shimmerX, 1),
                      colors: [
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white.withValues(alpha: 0.10),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                      stops: const [0.2, 0.5, 0.8],
                    ),
                  ),
                ),
              ),
            ),
          ),
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
