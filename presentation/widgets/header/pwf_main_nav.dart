import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/pwf_home_palette.dart';
import '../../providers/pwf_ui_prefs_provider.dart';
import '../../theme/pwf_theme_tokens.dart';
import '../pwf_web_container.dart';
import 'package:waqf/app/routing/app_routes.dart';
import 'package:waqf/app/routing/unit_routes.dart';

class PwfMainNav extends ConsumerWidget {
  const PwfMainNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeKey = ref.watch(pwfUiPrefsProvider).themeKey;
    final t = PwfThemeTokens.forKey(themeKey);
    final items = _navItems(context);
    return Container(
      decoration: BoxDecoration(
        // Container can't have both `color` and `decoration`.
        // Keep the same visual as the HTML nav background.
        color: t.navSurface,
        border: Border(
          top: BorderSide(color: t.onPrimary.withValues(alpha: 0.10)),
        ),
      ),
      child: PwfWebContainer(
        child: Row(
          children: [
            Expanded(child: Wrap(spacing: 0, runSpacing: 0, children: items)),
          ],
        ),
      ),
    );
  }
}

List<Widget> _navItems(BuildContext context) {
  return <Widget>[
    _NavLink(
      icon: FontAwesomeIcons.home,
      label: 'الرئيسية',
      onTap: () => context.go(AppRoutes.home),
    ),
    _NavDropdown(
      label: 'عن الوزارة',
      icon: FontAwesomeIcons.infoCircle,
      children: [
        _DropdownLink(
          icon: FontAwesomeIcons.userTie,
          label: 'كلمة الوزير',
          onTap: () => context.go(AppRoutes.minister),
        ),
        _DropdownLink(
          icon: FontAwesomeIcons.bullseye,
          label: 'رؤيتنا ورسالتنا',
          onTap: () => context.go(AppRoutes.visionMission),
        ),
        _DropdownLink(
          icon: FontAwesomeIcons.userClock,
          label: 'وزراء سابقون',
          onTap: () => context.go(AppRoutes.formerMinisters),
        ),
        _DropdownLink(
          icon: FontAwesomeIcons.sitemap,
          label: 'الهيكل التنظيمي',
          onTap: () => context.go(AppRoutes.structure),
        ),
      ],
    ),
    _NavDropdown(
      label: 'المساجد والأوقاف',
      icon: FontAwesomeIcons.mosque,
      children: [
        _DropdownLink(
          icon: FontAwesomeIcons.searchLocation,
          label: 'دليل المساجد',
          onTap: () => context.go(AppRoutes.mosques),
        ),
        _DropdownLink(
          icon: FontAwesomeIcons.landmark,
          label: 'إدارة الأوقاف',
          onTap: () => context.go(AppRoutes.mosques),
        ),
        _DropdownLink(
          icon: FontAwesomeIcons.tools,
          label: 'صيانة المساجد',
          onTap: () => context.go(AppRoutes.underConstruction),
        ),
        _DropdownLink(
          icon: FontAwesomeIcons.hardHat,
          label: 'مشاريع تحت الإنشاء',
          onTap: () => context.go(AppRoutes.projects),
        ),
      ],
    ),
    _NavDropdown(
      label: 'التعليم الديني',
      icon: FontAwesomeIcons.graduationCap,
      children: [
        _DropdownLink(
          icon: FontAwesomeIcons.school,
          label: 'المعاهد الدينية',
          onTap: () => context.go(AppRoutes.underConstruction),
        ),
        _DropdownLink(
          icon: FontAwesomeIcons.bookOpen,
          label: 'دورات تحفيظ القرآن',
          onTap: () => context.go(AppRoutes.underConstruction),
        ),
        _DropdownLink(
          icon: FontAwesomeIcons.userGraduate,
          label: 'برامج الأئمة والدعاة',
          onTap: () => context.go(AppRoutes.underConstruction),
        ),
        _DropdownLink(
          icon: FontAwesomeIcons.calendarAlt,
          label: 'الفعاليات الدينية',
          onTap: () => context.go(AppRoutes.underConstruction),
        ),
      ],
    ),
    _NavDropdown(
      label: 'الخدمات',
      icon: FontAwesomeIcons.layerGroup,
      children: [
        _DropdownLink(
          icon: FontAwesomeIcons.computer,
          label: 'الخدمات الإلكترونية',
          onTap: () => context.go(AppRoutes.eservices),
        ),
        _DropdownLink(
          icon: FontAwesomeIcons.handsHelping,
          label: 'الخدمات الاجتماعية',
          onTap: () => context.go(AppRoutes.socialServices),
        ),
        _DropdownLink(
          icon: FontAwesomeIcons.mosque,
          label: 'المساجد',
          onTap: () => context.go(AppRoutes.mosques),
        ),
        _DropdownLink(
          icon: FontAwesomeIcons.diagramProject,
          label: 'المشاريع',
          onTap: () => context.go(AppRoutes.projects),
        ),
      ],
    ),
    _NavLink(
      icon: FontAwesomeIcons.kaaba,
      label: 'الحج والعمرة',
      onTap: () => _launch('https://nosok.pal-wakf.ps/'),
    ),
    _NavDropdown(
      label: 'الإعلام',
      icon: FontAwesomeIcons.newspaper,
      children: [
        _DropdownLink(
          icon: FontAwesomeIcons.newspaper,
          label: 'الأخبار',
          onTap: () => context.go(UnitRoutes.news('home')),
        ),
        _DropdownLink(
          icon: FontAwesomeIcons.bullhorn,
          label: 'الإعلانات',
          onTap: () => context.go(UnitRoutes.announcements('home')),
        ),
        _DropdownLink(
          icon: FontAwesomeIcons.calendarAlt,
          label: 'الأنشطة والفعاليات',
          onTap: () => context.go(UnitRoutes.activities('home')),
        ),
        _DropdownLink(
          icon: FontAwesomeIcons.images,
          label: 'معرض الصور والفيديو',
          onTap: () => context.go(UnitRoutes.media('home')),
        ),
        _DropdownLink(
          icon: FontAwesomeIcons.download,
          label: 'خطب الجمعة والنشرات',
          onTap: () => context.go(UnitRoutes.fridaySermons('home')),
        ),
      ],
    ),
    _NavLink(
      icon: FontAwesomeIcons.phoneAlt,
      label: 'اتصل بنا',
      onTap: () => context.go(AppRoutes.contact),
    ),
  ];
}

Future<void> _launch(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
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
              FaIcon(widget.icon, size: 14, color: textColor),
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
                      // Prevent the dropdown from stretching across the page.
                      // In the HTML design it has a fixed-ish width under the nav item.
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
              FaIcon(widget.icon, size: 14, color: textColor),
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
    final item = widget.item;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () {
          widget.onAnyTap();
          item.onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: _hover
                ? Colors.black.withValues(alpha: 0.05)
                : Colors.transparent,
            border: widget.isLast
                ? null
                : Border(
                    bottom: BorderSide(
                      color: Colors.black.withValues(alpha: 0.10),
                    ),
                  ),
          ),
          child: Row(
            children: [
              FaIcon(
                item.icon,
                size: 14,
                color: _hover ? PwfHomePalette.primary : PwfHomePalette.gray,
              ),
              const SizedBox(width: 10),
              Text(
                item.label,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: _hover
                      ? PwfHomePalette.primary
                      : PwfHomePalette.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
