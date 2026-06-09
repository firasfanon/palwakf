import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/pwf_home_palette.dart';
import '../providers/pwf_ui_prefs_provider.dart';
import 'pwf_accessibility_tools_dialog.dart';
import 'shared/pwf_hoverable.dart';

class PwfThemeControlsOverlay extends ConsumerWidget {
  const PwfThemeControlsOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(pwfUiPrefsProvider);
    final ctrl = ref.read(pwfUiPrefsProvider.notifier);

    final isMobile = MediaQuery.sizeOf(context).width < 700;
    final buttons = <Widget>[
      _CircleBtn(
        icon: Icons.wb_sunny_outlined,
        compact: isMobile,
        active: prefs.themeKey == PwfThemeKey.light,
        onTap: () => ctrl.setTheme(PwfThemeKey.light),
      ),
      const SizedBox(height: 10),
      _CircleBtn(
        icon: Icons.dark_mode_outlined,
        compact: isMobile,
        active: prefs.themeKey == PwfThemeKey.dark,
        onTap: () => ctrl.setTheme(PwfThemeKey.dark),
      ),
      const SizedBox(height: 10),
      _CircleBtn(
        icon: Icons.account_balance,
        compact: isMobile,
        active: prefs.themeKey == PwfThemeKey.islamic,
        onTap: () => ctrl.setTheme(PwfThemeKey.islamic),
      ),
      const SizedBox(height: 10),
      _CircleBtn(
        icon: Icons.accessibility_new,
        active: false,
        compact: isMobile,
        onTap: () {
          showDialog<void>(
            context: context,
            builder: (context) => const PwfAccessibilityToolsDialog(),
          );
        },
      ),
    ];

    if (isMobile) {
      return Positioned(
        left: 12,
        right: 12,
        bottom: 18,
        child: SafeArea(
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 14,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: buttons),
            ),
          ),
        ),
      );
    }

    return Positioned(left: 30, bottom: 110, child: Column(children: buttons));
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({
    required this.icon,
    required this.onTap,
    required this.active,
    this.compact = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return PwfHoverable(
      hoverTranslate: const Offset(0, -3),
      onTap: onTap,
      child: Container(
        width: compact ? 42 : 55,
        height: compact ? 42 : 55,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              active ? PwfHomePalette.secondary : PwfHomePalette.primary,
              active ? const Color(0xFFE6B244) : PwfHomePalette.primary2,
            ],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Icon(icon, color: Colors.white, size: compact ? 17 : 22),
        ),
      ),
    );
  }
}
