import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:waqf/app/routing/app_routes.dart';
import 'package:waqf/features/platform/home/presentation/theme/pwf_home_palette.dart';
import 'package:waqf/features/platform/home/presentation/widgets/pwf_web_container.dart';

class PwfMainHeader extends StatelessWidget {
  const PwfMainHeader({super.key, required this.unitSlug});

  final String unitSlug;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: PwfWebContainer(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo section
            Row(
              children: [
                const FaIcon(
                  FontAwesomeIcons.mosque,
                  size: 40,
                  color: PwfHomePalette.secondary,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'وزارة الأوقاف والشؤون الدينية',
                      style: GoogleFonts.cairo(
                        fontSize: 28.8,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'المنصة الإلكترونية المتكاملة - دولة فلسطين',
                      style: GoogleFonts.cairo(
                        fontSize: 14.4,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.90),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Actions: search + user buttons
            Row(
              children: [
                const _SearchBox(),
                const SizedBox(width: 20),
                Row(
                  children: [
                    _HeaderButton(
                      icon: Icons.login,
                      label: 'دخول الموظفين',
                      background: Colors.white.withValues(alpha: 0.10),
                      onTap: () => context.go(AppRoutes.adminLogin),
                    ),
                    const SizedBox(width: 15),
                    _HeaderButton(
                      icon: Icons.phone,
                      label: 'الطوارئ',
                      background: PwfHomePalette.danger,
                      hoverBackground: const Color(0xFFC82333),
                      onTap: () => context.go(AppRoutes.underConstruction),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBox extends StatefulWidget {
  const _SearchBox();

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
    return Container(
      width: 300,
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
                  hintText: 'ابحث في الخدمات والمعلومات...',
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
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color? hoverBackground;
  final VoidCallback onTap;

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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(color: bg, borderRadius: PwfHomeRadii.br8),
          child: Row(
            children: [
              Icon(widget.icon, size: 14, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: GoogleFonts.cairo(
                  fontSize: 14,
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
