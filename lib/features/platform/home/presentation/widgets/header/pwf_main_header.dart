import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:waqf/app/routing/app_routes.dart';
import 'package:waqf/data/models/header_settings.dart';
import 'package:waqf/presentation/providers/header_settings_provider.dart';
import '../../theme/pwf_home_palette.dart';
import '../pwf_web_container.dart';

class PwfMainHeader extends ConsumerWidget {
  const PwfMainHeader({super.key, required this.unitSlug});

  final String unitSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final normalizedSlug = unitSlug.trim().isEmpty
        ? 'home'
        : unitSlug.trim().toLowerCase();
    final asyncSettings = ref.watch(
      publicHeaderSettingsProvider(normalizedSlug),
    );
    final settings = asyncSettings.maybeWhen(
      data: (value) => value,
      orElse: _fallbackSettings,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: PwfWebContainer(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final compact = width < 980;
            final searchWidth = width < 820
                ? 180.0
                : width < 980
                ? 220.0
                : 300.0;
            final buttonGap = compact ? 10.0 : 15.0;
            final buttonHorizontal = compact ? 14.0 : 20.0;
            final buttonFont = compact ? 12.0 : 14.0;
            final titleFont = width < 820 ? 22.0 : 28.8;
            final subtitleFont = width < 820 ? 12.5 : 14.4;

            return Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      _HeaderLogo(logoUrl: settings.logoUrl),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              settings.siteName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                fontSize: titleFont,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              settings.siteTagline,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                fontSize: subtitleFont,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.90),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          _SearchBox(
                            width: searchWidth,
                            scopeLabel: settings.siteName,
                          ),
                          SizedBox(width: compact ? 12 : 20),
                          Row(
                            children: [
                              _HeaderButton(
                                icon: Icons.login,
                                label: 'دخول الموظفين',
                                background: Colors.white.withValues(
                                  alpha: 0.10,
                                ),
                                horizontalPadding: buttonHorizontal,
                                fontSize: buttonFont,
                                onTap: () => context.go(AppRoutes.adminLogin),
                              ),
                              SizedBox(width: buttonGap),
                              _HeaderButton(
                                icon: Icons.phone,
                                label: normalizedSlug == 'home'
                                    ? 'الطوارئ'
                                    : 'طوارئ ${settings.siteName}',
                                background: PwfHomePalette.danger,
                                hoverBackground: const Color(0xFFC82333),
                                horizontalPadding: buttonHorizontal,
                                fontSize: buttonFont,
                                onTap: () => context.go(AppRoutes.complaints),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  HeaderSettings _fallbackSettings() {
    final now = DateTime.now();
    return HeaderSettings(
      id: 'fallback-header',
      logoUrl: '',
      siteName: 'وزارة الأوقاف والشؤون الدينية',
      siteTagline: 'المنصة الإلكترونية المتكاملة - دولة فلسطين',
      createdAt: now,
      updatedAt: now,
    );
  }
}

class _HeaderLogo extends StatelessWidget {
  const _HeaderLogo({required this.logoUrl});

  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    final value = (logoUrl ?? '').trim();
    if (_shouldUseIconFallback(value)) {
      return const FaIcon(
        FontAwesomeIcons.mosque,
        size: 40,
        color: PwfHomePalette.secondary,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        value,
        width: 48,
        height: 48,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const FaIcon(
          FontAwesomeIcons.mosque,
          size: 40,
          color: PwfHomePalette.secondary,
        ),
      ),
    );
  }

  static bool _shouldUseIconFallback(String value) {
    if (value.isEmpty) return true;

    final uri = Uri.tryParse(value);
    final host = uri?.host.toLowerCase() ?? '';
    if (host.isEmpty) return true;

    return host == 'via.placeholder.com' ||
        host == 'placeholder.com' ||
        host.endsWith('.placeholder.com') ||
        host == 'images.unsplash.com' ||
        host.endsWith('.unsplash.com') ||
        host == 'source.unsplash.com';
  }
}

class _SearchBox extends StatefulWidget {
  const _SearchBox({required this.width, required this.scopeLabel});

  final double width;
  final String scopeLabel;

  @override
  State<_SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<_SearchBox> {
  bool _hover = false;
  final TextEditingController _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final placeholder = widget.scopeLabel.trim().isEmpty
        ? 'ابحث في الخدمات والمعلومات...'
        : 'ابحث في ${widget.scopeLabel}...';

    return Container(
      width: widget.width,
      height: 44,
      decoration: BoxDecoration(
        color: PwfHomePalette.cardBg,
        borderRadius: PwfHomeRadii.br30,
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 20, end: 8),
              child: TextField(
                controller: _c,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: PwfHomePalette.primary,
                ),
                decoration: InputDecoration(
                  hintText: placeholder,
                  hintStyle: GoogleFonts.cairo(
                    fontSize: 14,
                    color: PwfHomePalette.gray,
                  ),
                  isDense: true,
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _hover = true),
            onExit: (_) => setState(() => _hover = false),
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('البحث قيد الربط')),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 56,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: _hover
                      ? const Color(0xFFB08A40)
                      : PwfHomePalette.secondary,
                  borderRadius: const BorderRadiusDirectional.only(
                    topEnd: Radius.circular(30),
                    bottomEnd: Radius.circular(30),
                  ),
                ),
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.search,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatefulWidget {
  const _HeaderButton({
    required this.icon,
    required this.label,
    required this.background,
    required this.onTap,
    this.hoverBackground,
    required this.horizontalPadding,
    required this.fontSize,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color? hoverBackground;
  final VoidCallback onTap;
  final double horizontalPadding;
  final double fontSize;

  @override
  State<_HeaderButton> createState() => _HeaderButtonState();
}

class _HeaderButtonState extends State<_HeaderButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final Color bg = (_hover && widget.hoverBackground != null)
        ? widget.hoverBackground!
        : widget.background;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: widget.horizontalPadding,
            vertical: 10,
          ),
          decoration: BoxDecoration(color: bg, borderRadius: PwfHomeRadii.br8),
          child: Row(
            children: [
              Icon(widget.icon, size: 14, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: GoogleFonts.cairo(
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
