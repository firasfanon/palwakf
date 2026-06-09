import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/pwf_home_palette.dart';
import '../../providers/pwf_ui_prefs_provider.dart';
import '../../theme/pwf_theme_tokens.dart';
import '../pwf_web_container.dart';
import 'package:waqf/app/routing/app_routes.dart';

class PwfTopBar extends ConsumerWidget {
  const PwfTopBar({super.key, this.unitSlug = 'home'});

  final String unitSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(pwfUiPrefsProvider);
    final themeKey = prefs.themeKey;
    final t = PwfThemeTokens.forKey(themeKey);

    final isMobile = MediaQuery.sizeOf(context).width < 700;

    return Container(
      color: t.topBarSurface,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 6 : 8),
      child: PwfWebContainer(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _A11yButton(
                    icon: Icons.text_fields,
                    label: 'الخط',
                    active: false,
                    onTap: () =>
                        ref.read(pwfUiPrefsProvider.notifier).increaseFont(),
                  ),
                  const SizedBox(width: 15),
                  _A11yButton(
                    icon: Icons.contrast,
                    label: 'التباين',
                    active: prefs.highContrast,
                    onTap: () => ref
                        .read(pwfUiPrefsProvider.notifier)
                        .toggleHighContrast(),
                  ),
                  const SizedBox(width: 15),
                  _A11yButton(
                    icon: Icons.menu_book,
                    label: 'وضع القراءة',
                    active: prefs.readMode,
                    onTap: () =>
                        ref.read(pwfUiPrefsProvider.notifier).toggleReadMode(),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Row(
                children: [
                  if (!isMobile) ...[
                    const _LangSelector(),
                    const SizedBox(width: 20),
                  ],
                  _GradientActionLink(
                    icon: Icons.forum,
                    label: 'الشكاوى',
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFDC3545), Color(0xFFE35D6A)],
                    ),
                    onTap: () => context.go(AppRoutes.complaints),
                  ),
                  if (!isMobile) ...[
                    const SizedBox(width: 12),
                    _GradientActionLink(
                      icon: Icons.menu_book,
                      label: 'القرآن',
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [PwfHomePalette.secondary, Color(0xFFE6B244)],
                      ),
                      onTap: () => context.go(AppRoutes.quran),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _A11yButton extends StatefulWidget {
  const _A11yButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.active,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  State<_A11yButton> createState() => _A11yButtonState();
}

class _A11yButtonState extends State<_A11yButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.active ? PwfHomePalette.secondary : Colors.white;
    final color = _hover ? PwfHomePalette.secondary : baseColor;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Row(
          children: [
            Icon(widget.icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              widget.label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LangSelector extends StatelessWidget {
  const _LangSelector();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _LangBtn(label: 'العربية', active: true),
        SizedBox(width: 10),
        _LangBtn(label: 'English', active: false),
      ],
    );
  }
}

class _LangBtn extends StatefulWidget {
  const _LangBtn({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  State<_LangBtn> createState() => _LangBtnState();
}

class _LangBtnState extends State<_LangBtn> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final bool active = widget.active;
    final Color color = active
        ? PwfHomePalette.secondary
        : (_hover ? PwfHomePalette.secondary : Colors.white);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.active
                    ? 'اللغة العربية مفعلة حالياً'
                    : 'سيتم دعم التبديل إلى الإنجليزية قريباً',
              ),
            ),
          );
        },
        child: Text(
          widget.label,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _GradientActionLink extends StatefulWidget {
  const _GradientActionLink({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  State<_GradientActionLink> createState() => _GradientActionLinkState();
}

class _GradientActionLinkState extends State<_GradientActionLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: _hover ? (Matrix4.identity()..translate(0.0, -2.0)) : null,
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: PwfHomeRadii.br8,
            boxShadow: _hover
                ? const [
                    BoxShadow(
                      color: Color(0x4DC19A50),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: Row(
            children: [
              Icon(widget.icon, size: 14, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
