import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:waqf/app/routing/app_routes.dart';
import 'package:waqf/app/routing/unit_routes.dart';
import 'package:waqf/data/models/footer_settings.dart';
import 'package:waqf/features/platform/assistant/assistant_core/data/services/chat_entry_service.dart';
import 'package:waqf/presentation/providers/footer_settings_provider.dart';
import 'package:waqf/presentation/providers/unit_context_provider.dart';
import '../../providers/pwf_ui_prefs_provider.dart';
import '../../theme/pwf_home_palette.dart';
import '../../theme/pwf_theme_tokens.dart';
import '../pwf_web_container.dart';
import '../../screens/pages/pwf_public_content_shared.dart';

class PwfMainNav extends ConsumerWidget {
  const PwfMainNav({super.key, this.unitSlug = 'home'});

  final String unitSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final normalizedSlug = unitSlug.trim().isEmpty
        ? 'home'
        : unitSlug.trim().toLowerCase();
    final themeKey = ref.watch(pwfUiPrefsProvider).themeKey;
    final t = PwfThemeTokens.forKey(themeKey);
    final scopedSettings = ref
        .watch(publicFooterSettingsProvider(normalizedSlug))
        .maybeWhen(data: (value) => value, orElse: () => null);
    final unit = ref.watch(orgUnitBySlugProvider(normalizedSlug)).valueOrNull;
    final scopeLabel = pwfResolveScopeLabel(
      unitSlug: normalizedSlug,
      unit: unit,
      contextualLabel: (scopedSettings?.ministryName ?? '').trim().isEmpty
          ? null
          : scopedSettings?.ministryName,
    );
    final items = _navItems(
      context,
      normalizedSlug,
      scopedSettings,
      scopeLabel: scopeLabel,
    );

    final isMobile = MediaQuery.sizeOf(context).width < 700;

    return Container(
      decoration: BoxDecoration(
        color: t.navSurface,
        border: Border(
          top: BorderSide(color: t.onPrimary.withValues(alpha: 0.10)),
        ),
      ),
      child: PwfWebContainer(
        child: isMobile
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: items.take(4).toList()),
              )
            : Row(
                children: [
                  Expanded(
                    child: Wrap(spacing: 0, runSpacing: 0, children: items),
                  ),
                ],
              ),
      ),
    );
  }
}

List<Widget> _navItems(
  BuildContext context,
  String unitSlug,
  FooterSettings? scopedSettings, {
  required String scopeLabel,
}) {
  final isHome = unitSlug == 'home';
  final contextualLinks = _contextualFooterLinks(scopedSettings);

  return <Widget>[
    _NavLink(
      icon: Icons.home,
      label: isHome ? 'الرئيسية' : scopeLabel,
      onTap: () =>
          context.go(isHome ? AppRoutes.home : UnitRoutes.home(unitSlug)),
    ),
    if (isHome)
      _NavLink(
        icon: Icons.account_tree_outlined,
        label: 'PalWakf',
        onTap: () => context.go(AppRoutes.palWakf),
      ),
    _NavDropdown(
      label: isHome ? 'عن الوزارة' : 'عن $scopeLabel',
      icon: Icons.info_outline,
      children: [
        _DropdownLink(
          icon: Icons.info_outline,
          label: isHome ? 'عن الوزارة' : 'عن $scopeLabel',
          onTap: () =>
              context.go(isHome ? AppRoutes.about : UnitRoutes.about(unitSlug)),
        ),
        if (isHome) ...[
          _DropdownLink(
            icon: Icons.person,
            label: 'كلمة الوزير',
            onTap: () => context.go(AppRoutes.minister),
          ),
          _DropdownLink(
            icon: Icons.flag,
            label: 'الرؤيا والرسالة',
            onTap: () => context.go(AppRoutes.visionMission),
          ),
          _DropdownLink(
            icon: Icons.account_tree,
            label: 'الهيكل التنظيمي',
            onTap: () => context.go(AppRoutes.structure),
          ),
          _DropdownLink(
            icon: Icons.groups_2_outlined,
            label: 'الوزراء السابقون',
            onTap: () => context.go(AppRoutes.formerMinisters),
          ),
        ] else ...[
          _DropdownLink(
            icon: Icons.flag,
            label: 'رؤيا ورسالة $scopeLabel',
            onTap: () => context.go(UnitRoutes.visionMission(unitSlug)),
          ),
        ],
      ],
    ),
    _NavDropdown(
      label: 'المركز الإعلامي',
      icon: Icons.article,
      children: [
        _DropdownLink(
          icon: Icons.dashboard_customize_outlined,
          label: 'بوابة المركز الإعلامي',
          onTap: () => context.go(_scopedMediaCenterRoute(unitSlug)),
        ),
        _DropdownLink(
          icon: Icons.article,
          label: 'الأخبار',
          onTap: () => context.go(UnitRoutes.news(unitSlug)),
        ),
        _DropdownLink(
          icon: Icons.campaign,
          label: 'الإعلانات',
          onTap: () => context.go(UnitRoutes.announcements(unitSlug)),
        ),
        _DropdownLink(
          icon: Icons.event_note_outlined,
          label: 'الأنشطة',
          onTap: () => context.go(UnitRoutes.activities(unitSlug)),
        ),
        _DropdownLink(
          icon: Icons.celebration_outlined,
          label: 'الفعاليات',
          onTap: () => context.go(_scopedEventsRoute(unitSlug)),
        ),
        _DropdownLink(
          icon: Icons.groups_2_outlined,
          label: 'الاجتماعيات',
          onTap: () => context.go(_scopedSocialPostsRoute(unitSlug)),
        ),
        _DropdownLink(
          icon: Icons.image,
          label: 'الصور والفيديوهات',
          onTap: () => context.go(UnitRoutes.media(unitSlug)),
        ),
        _DropdownLink(
          icon: Icons.mic_none_outlined,
          label: 'خطب الجمعة',
          onTap: () => context.go(UnitRoutes.fridaySermons(unitSlug)),
        ),
        _DropdownLink(
          icon: Icons.description_outlined,
          label: 'البيانات الصحفية',
          onTap: () => context.go(_scopedPressReleasesRoute(unitSlug)),
        ),
        _DropdownLink(
          icon: Icons.record_voice_over_outlined,
          label: 'التصريحات الرسمية',
          onTap: () => context.go(_scopedOfficialStatementsRoute(unitSlug)),
        ),
        _DropdownLink(
          icon: Icons.campaign_outlined,
          label: 'الحملات التوعوية',
          onTap: () => context.go(_scopedAwarenessCampaignsRoute(unitSlug)),
        ),
        _DropdownLink(
          icon: Icons.shield_outlined,
          label: 'مرصد حماية المقدسات',
          onTap: () => context.go(_scopedSanctitiesRoute(unitSlug)),
        ),
      ],
    ),
    _NavDropdown(
      label: 'مركز الخدمات',
      icon: Icons.layers,
      children: [
        _DropdownLink(
          icon: Icons.design_services_outlined,
          label: 'دليل الخدمات',
          onTap: () => context.go(
            isHome ? AppRoutes.services : UnitRoutes.services(unitSlug),
          ),
        ),
        _DropdownLink(
          icon: Icons.computer,
          label: 'الخدمات الإلكترونية',
          onTap: () => context.go(
            isHome ? AppRoutes.eservices : UnitRoutes.eservices(unitSlug),
          ),
        ),
        _DropdownLink(
          icon: Icons.assignment_outlined,
          label: 'تقديم طلب خدمة',
          onTap: () => context.go(
            isHome
                ? AppRoutes.serviceRequestEntry
                : UnitRoutes.serviceRequest(unitSlug),
          ),
        ),
        _DropdownLink(
          icon: Icons.manage_search_outlined,
          label: 'متابعة طلب',
          onTap: () => context.go(
            isHome
                ? AppRoutes.serviceRequestTracking
                : UnitRoutes.serviceTracking(unitSlug),
          ),
        ),
        _DropdownLink(
          icon: Icons.report_gmailerrorred_outlined,
          label: 'الشكاوى والملاحظات',
          onTap: () => context.go(
            isHome ? AppRoutes.complaints : UnitRoutes.complaints(unitSlug),
          ),
        ),
        _DropdownLink(
          icon: Icons.gavel_outlined,
          label: 'الأنظمة والقوانين والتعليمات',
          onTap: () => context.go(_scopedLegalReferencesRoute(unitSlug)),
        ),
        _DropdownLink(
          icon: Icons.menu_book,
          label: 'القرآن الكريم',
          onTap: () =>
              context.go(isHome ? AppRoutes.quran : UnitRoutes.quran(unitSlug)),
        ),
        _DropdownLink(
          icon: Icons.access_time_rounded,
          label: 'مواقيت الصلاة',
          onTap: () => context.go(
            isHome ? AppRoutes.prayerTimes : UnitRoutes.prayerTimes(unitSlug),
          ),
        ),
        _DropdownLink(
          icon: Icons.volunteer_activism_outlined,
          label: 'الزكاة',
          onTap: () =>
              context.go(isHome ? AppRoutes.zakat : UnitRoutes.zakat(unitSlug)),
        ),
      ],
    ),
    _NavDropdown(
      label: 'الأنظمة والمنصات',
      icon: Icons.hub_outlined,
      children: [
        _DropdownLink(
          icon: Icons.map_outlined,
          label: 'المستكشف',
          onTap: () => context.go(AppRoutes.mustakshif),
        ),
        _DropdownLink(
          icon: Icons.place,
          label: 'الحج والعمرة / نسك',
          onTap: () => _launch('https://nosok.pal-wakf.ps/'),
        ),
        _DropdownLink(
          icon: Icons.forum,
          label: ChatEntryService.headerLabel(context),
          onTap: () =>
              ChatEntryService.open(context, fallbackUnitSlug: unitSlug),
        ),
      ],
    ),
    if (contextualLinks.isNotEmpty)
      _NavDropdown(
        label: isHome ? 'روابط الوزارة' : 'روابط $scopeLabel',
        icon: Icons.link_rounded,
        children: [
          for (final item in contextualLinks)
            _DropdownLink(
              icon: item.icon,
              label: item.label,
              onTap: () => _openFooterLink(context, item.link),
            ),
        ],
      ),
    _NavLink(
      icon: Icons.phone,
      label: isHome ? 'اتصل بنا' : 'اتصل بـ $scopeLabel',
      onTap: () => context.go(
        isHome ? AppRoutes.contact : UnitRoutes.contact(unitSlug),
      ),
    ),
  ];
}

String _scopedMediaCenterRoute(String unitSlug) => unitSlug == 'home'
    ? AppRoutes.mediaCenter
    : UnitRoutes.mediaCenter(unitSlug);

String _scopedEventsRoute(String unitSlug) =>
    unitSlug == 'home' ? AppRoutes.events : UnitRoutes.events(unitSlug);

String _scopedSocialPostsRoute(String unitSlug) => unitSlug == 'home'
    ? AppRoutes.socialPosts
    : UnitRoutes.socialPosts(unitSlug);

String _scopedPressReleasesRoute(String unitSlug) => unitSlug == 'home'
    ? AppRoutes.pressReleases
    : UnitRoutes.pressReleases(unitSlug);

String _scopedOfficialStatementsRoute(String unitSlug) => unitSlug == 'home'
    ? AppRoutes.officialStatements
    : UnitRoutes.officialStatements(unitSlug);

String _scopedAwarenessCampaignsRoute(String unitSlug) => unitSlug == 'home'
    ? AppRoutes.awarenessCampaigns
    : UnitRoutes.awarenessCampaigns(unitSlug);

String _scopedSanctitiesRoute(String unitSlug) => unitSlug == 'home'
    ? AppRoutes.sanctitiesObservatory
    : UnitRoutes.sanctitiesObservatory(unitSlug);

String _scopedLegalReferencesRoute(String unitSlug) => unitSlug == 'home'
    ? AppRoutes.legalReferences
    : UnitRoutes.legalReferences(unitSlug);

List<_ScopedFooterNavLink> _contextualFooterLinks(FooterSettings? settings) {
  if (settings == null) return const [];
  final seen = <String>{};
  final output = <_ScopedFooterNavLink>[];

  void addLinks(List<FooterLink> links, IconData icon) {
    for (final link in links) {
      final label = link.label.trim();
      final route = link.route.trim();
      if (!link.enabled || label.isEmpty || route.isEmpty) continue;
      final key = '$label|$route';
      if (!seen.add(key)) continue;
      output.add(_ScopedFooterNavLink(link: link, icon: icon, label: label));
      if (output.length >= 6) return;
    }
  }

  addLinks(settings.quickLinks, Icons.link_rounded);
  if (output.length < 6) {
    addLinks(settings.servicesLinks, Icons.flash_on_rounded);
  }
  return output;
}

Future<void> _openFooterLink(BuildContext context, FooterLink link) async {
  final value = link.route.trim();
  if (value.isEmpty) return;
  if (value.startsWith('http://') || value.startsWith('https://')) {
    await _launch(value);
    return;
  }
  if (!context.mounted) return;
  context.go(_normalizePublicRoute(value));
}

String _normalizePublicRoute(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) return AppRoutes.home;
  switch (normalized) {
    case 'e-services':
    case '/e-services':
      return AppRoutes.eservices;
    case 'privacy':
      return '/privacy';
    case 'terms':
      return '/terms';
    case 'sitemap':
      return '/sitemap';
    default:
      return normalized.startsWith('/') ? normalized : '/$normalized';
  }
}

Future<void> _launch(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _ScopedFooterNavLink {
  const _ScopedFooterNavLink({
    required this.link,
    required this.icon,
    required this.label,
  });

  final FooterLink link;
  final IconData icon;
  final String label;
}

class _NavLink extends StatefulWidget {
  const _NavLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final Color textColor = _hover ? PwfHomePalette.secondary : Colors.white;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          color: _hover
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.transparent,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 14, color: textColor),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DropdownLink {
  const _DropdownLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _NavDropdown extends StatefulWidget {
  const _NavDropdown({
    required this.label,
    required this.icon,
    required this.children,
  });

  final String label;
  final IconData icon;
  final List<_DropdownLink> children;

  @override
  State<_NavDropdown> createState() => _NavDropdownState();
}

class _NavDropdownState extends State<_NavDropdown> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _entry;
  bool _hover = false;
  bool _menuHover = false;
  Timer? _closeTimer;

  @override
  void dispose() {
    _closeTimer?.cancel();
    _remove();
    super.dispose();
  }

  void _show() {
    if (_entry != null) return;
    _entry = OverlayEntry(
      builder: (context) {
        return Positioned.fill(
          child: Stack(
            children: [
              CompositedTransformFollower(
                link: _link,
                showWhenUnlinked: false,
                followerAnchor: Alignment.topRight,
                targetAnchor: Alignment.bottomRight,
                offset: const Offset(0, 0),
                child: MouseRegion(
                  onEnter: (_) {
                    _menuHover = true;
                    _cancelClose();
                  },
                  onExit: (_) {
                    _menuHover = false;
                    _scheduleClose();
                  },
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 250,
                        maxWidth: 320,
                      ),
                      decoration: BoxDecoration(
                        color: PwfHomePalette.cardBg,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(PwfHomeRadii.r8),
                          bottomRight: Radius.circular(PwfHomeRadii.r8),
                        ),
                        boxShadow: PwfHomeShadows.card,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (int i = 0; i < widget.children.length; i++)
                            _DropdownMenuItem(
                              item: widget.children[i],
                              isLast: i == widget.children.length - 1,
                              onAnyTap: _remove,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    Overlay.of(context, rootOverlay: true).insert(_entry!);
  }

  void _remove() {
    _entry?.remove();
    _entry = null;
  }

  void _cancelClose() {
    _closeTimer?.cancel();
    _closeTimer = null;
  }

  void _scheduleClose() {
    _cancelClose();
    _closeTimer = Timer(const Duration(milliseconds: 120), () {
      if (!_hover && !_menuHover) _remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = _hover ? PwfHomePalette.secondary : Colors.white;
    return CompositedTransformTarget(
      link: _link,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) {
          setState(() => _hover = true);
          _cancelClose();
          _show();
        },
        onExit: (_) {
          setState(() => _hover = false);
          _scheduleClose();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          color: _hover
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.transparent,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 14, color: textColor),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 8),
              FaIcon(FontAwesomeIcons.chevronDown, size: 12, color: textColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _DropdownMenuItem extends StatefulWidget {
  const _DropdownMenuItem({
    required this.item,
    required this.isLast,
    required this.onAnyTap,
  });

  final _DropdownLink item;
  final bool isLast;
  final VoidCallback onAnyTap;

  @override
  State<_DropdownMenuItem> createState() => _DropdownMenuItemState();
}

class _DropdownMenuItemState extends State<_DropdownMenuItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final bg = _hover ? const Color(0xFFF8F8F8) : Colors.transparent;
    final textColor = _hover ? PwfHomePalette.primary : PwfHomePalette.text;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () {
          widget.onAnyTap();
          widget.item.onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: bg,
            border: widget.isLast
                ? null
                : const Border(bottom: BorderSide(color: Color(0xFFE8E8E8))),
          ),
          child: Row(
            children: [
              Icon(widget.item.icon, size: 14, color: textColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.item.label,
                  style: GoogleFonts.cairo(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 13,
                color: PwfHomePalette.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
