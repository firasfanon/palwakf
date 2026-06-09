// ignore_for_file: unused_element_parameter
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:waqf/app/routing/app_routes.dart';

import '../../theme/pwf_home_palette.dart';
import '../pwf_section_container.dart';
import '../shared/pwf_section_title.dart';

class PwfImportantLinksSection extends StatelessWidget {
  const PwfImportantLinksSection({super.key, this.unitSlug = 'home'});

  final String unitSlug;

  @override
  Widget build(BuildContext context) {
    final items = <_LinkItem>[
      _LinkItem(
        icon: Icons.account_balance,
        title: 'دليل الأوقاف الإسلامية',
        desc: 'دليل شامل للأوقاف الإسلامية في فلسطين وتاريخها وإدارتها',
        cta: 'زيارة الدليل',
      ),
      _LinkItem(
        icon: Icons.balance,
        title: 'القوانين والتشريعات',
        desc: 'القوانين والأنظمة المتعلقة بالأوقاف الإسلامية في فلسطين',
        cta: 'عرض القوانين',
      ),
      _LinkItem(
        icon: Icons.book,
        title: 'المكتبة الوقفية',
        desc: 'مكتبة رقمية تحتوي على مراجع وكتب عن الأوقاف الإسلامية',
        cta: 'زيارة المكتبة',
      ),
      _LinkItem(
        icon: Icons.groups,
        title: 'شركاء الأوقاف',
        desc: 'المؤسسات والجهات الشريكة في مشاريع الأوقاف الإسلامية',
        cta: 'عرض الشركاء',
      ),
    ];

    return PwfSectionContainer(
      sectionKey: 'PwfImportantLinksSection',
      child: Column(
        children: [
          const PwfSectionTitle(
            title: 'روابط مهمة للأوقاف الإسلامية',
            subtitle: 'روابط ومصادر مهمة تتعلق بالأوقاف الإسلامية',
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              final isNarrow = w < 900;
              final cardW = isNarrow ? w : (w - 60) / 4;
              return Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  for (final it in items)
                    SizedBox(
                      width: isNarrow ? w : cardW,
                      child: _LinkCard(item: it),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LinkItem {
  const _LinkItem({
    required this.icon,
    required this.title,
    required this.desc,
    required this.cta,
    this.href,
  });

  final IconData icon;
  final String title;
  final String desc;
  final String cta;
  final String? href;
}

class _LinkCard extends StatefulWidget {
  const _LinkCard({required this.item});

  final _LinkItem item;

  @override
  State<_LinkCard> createState() => _LinkCardState();
}

class _LinkCardState extends State<_LinkCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final it = widget.item;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..translate(0.0, _hover ? -10.0 : 0.0),
        decoration: BoxDecoration(
          color: PwfHomePalette.cardBg,
          borderRadius: PwfHomeRadii.br16,
          boxShadow: _hover ? PwfHomeShadows.cardHover : PwfHomeShadows.card,
          border: const Border(
            top: BorderSide(width: 4, color: PwfHomePalette.secondary),
          ),
        ),
        child: InkWell(
          borderRadius: PwfHomeRadii.br16,
          onTap: () => context.go(_normalizeImportantLink(it.href)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: PwfHomePalette.bg,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      it.icon,
                      size: 34,
                      color: PwfHomePalette.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  it.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: PwfHomePalette.primary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  it.desc,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 13.5,
                    color: Colors.black87,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      it.cta,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: PwfHomePalette.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const FaIcon(
                      FontAwesomeIcons.arrowLeft,
                      size: 14,
                      color: PwfHomePalette.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _normalizeImportantLink(String? value) {
  final raw = (value ?? '').trim();
  if (raw.isEmpty) return AppRoutes.contact;
  switch (raw) {
    case 'e-services':
    case '/e-services':
      return AppRoutes.eservices;
    case 'privacy':
      return AppRoutes.privacy;
    case 'terms':
      return AppRoutes.terms;
    case 'sitemap':
      return AppRoutes.sitemap;
    default:
      return raw.startsWith('/') ? raw : '/$raw';
  }
}
