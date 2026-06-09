import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../theme/pwf_home_palette.dart';
import '../providers/pwf_ui_prefs_provider.dart';
import 'shared/pwf_hoverable.dart';

class PwfThemeControlsOverlay extends ConsumerWidget {
  const PwfThemeControlsOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(pwfUiPrefsProvider);
    final ctrl = ref.read(pwfUiPrefsProvider.notifier);

    // Keep UI HTML-identical. We only wire behavior + active state.
    return Positioned(
      left: 30,
      // Keep controls visible above the footer area on all pages.
      bottom: 110,
      child: Column(
        children: [
          _CircleBtn(
            icon: FontAwesomeIcons.sun,
            active: prefs.themeKey == PwfThemeKey.light,
            onTap: () => ctrl.setTheme(PwfThemeKey.light),
          ),
          const SizedBox(height: 10),
          _CircleBtn(
            icon: FontAwesomeIcons.moon,
            active: prefs.themeKey == PwfThemeKey.dark,
            onTap: () => ctrl.setTheme(PwfThemeKey.dark),
          ),
          const SizedBox(height: 10),
          _CircleBtn(
            icon: FontAwesomeIcons.mosque,
            active: prefs.themeKey == PwfThemeKey.islamic,
            onTap: () => ctrl.setTheme(PwfThemeKey.islamic),
          ),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({
    required this.icon,
    required this.onTap,
    required this.active,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return PwfHoverable(
      hoverTranslate: const Offset(0, -3),
      onTap: onTap,
      child: Container(
        width: 55,
        height: 55,
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
        child: Center(child: Icon(icon, color: Colors.white, size: 22)),
      ),
    );
  }
}
