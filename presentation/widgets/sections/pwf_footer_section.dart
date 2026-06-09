import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:waqf/app/routing/app_routes.dart';

import '../../theme/pwf_home_palette.dart';
import '../../providers/pwf_ui_prefs_provider.dart';
import '../../theme/pwf_theme_tokens.dart';
// Footer should span full page width (no maxWidth container).

class PwfFooterSection extends ConsumerStatefulWidget {
  const PwfFooterSection({super.key, this.unitSlug = 'home'});

  final String unitSlug;

  @override
  ConsumerState<PwfFooterSection> createState() => _PwfFooterSectionState();
}

class _PwfFooterSectionState extends ConsumerState<PwfFooterSection> {
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeKey = ref.watch(pwfUiPrefsProvider).themeKey;
    final t = PwfThemeTokens.forKey(themeKey);
    final w = MediaQuery.sizeOf(context).width;
    final hPad = w >= 768 ? 20.0 : 16.0;

    return Container(
      width: double.infinity,
      color: t.footerBg,
      padding: EdgeInsets.fromLTRB(hPad, 26, hPad, 18),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              final isNarrow = w < 900;
              final colW = isNarrow ? w : (w - 40) / 3;

              return Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  SizedBox(width: colW, child: _aboutColumn(context)),
                  SizedBox(width: colW, child: _contactColumn(context)),
                  SizedBox(width: colW, child: _newsletterColumn(context)),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          const Divider(color: Color(0x33FFFFFF)),
          const SizedBox(height: 12),
          _copyright(context),
        ],
      ),
    );
  }

  Widget _aboutColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'عن الوزارة',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'وزارة الأوقاف والشؤون الدينية في فلسطين، ...وتعزيز التعليم الديني، وتنمية المجتمع وفقاً للقيم الإسلامية.',
          style: GoogleFonts.cairo(
            fontSize: 13.5,
            color: const Color(0xD9FFFFFF),
            height: 1.7,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _socialIcon(
              icon: FontAwesomeIcons.facebookF,
              onTap: () => _openUrl('https://www.facebook.com/palestine.wakf/'),
            ),
            _socialIcon(
              icon: FontAwesomeIcons.twitter,
              onTap: () => context.go(AppRoutes.underConstruction),
            ),
            _socialIcon(
              icon: FontAwesomeIcons.instagram,
              onTap: () => context.go(AppRoutes.underConstruction),
            ),
            _socialIcon(
              icon: FontAwesomeIcons.youtube,
              onTap: () => context.go(AppRoutes.underConstruction),
            ),
            _socialIcon(
              icon: FontAwesomeIcons.telegram,
              onTap: () => context.go(AppRoutes.underConstruction),
            ),
          ],
        ),
      ],
    );
  }

  Widget _contactColumn(BuildContext context) {
    Widget row(IconData icon, String text) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            FaIcon(icon, size: 14, color: PwfHomePalette.secondary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.cairo(
                  fontSize: 13.5,
                  color: const Color(0xD9FFFFFF),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'معلومات الاتصال',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        row(
          FontAwesomeIcons.locationDot,
          'الرام - مقر الوزارة، رام الله - فلسطين',
        ),
        row(FontAwesomeIcons.phone, '00970 2 298 2000'),
        row(FontAwesomeIcons.envelope, 'info@awqaf.ps'),
        row(FontAwesomeIcons.clock, 'الأحد - الخميس: 8 صباحاً - 3 مساءً'),
      ],
    );
  }

  Widget _newsletterColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'النشرة الإخبارية',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'اشترك في نشرتنا الإخبارية لتصلك آخر أخبار الوزارة والفعاليات الدينية.',
          style: GoogleFonts.cairo(
            fontSize: 13.5,
            color: const Color(0xD9FFFFFF),
            height: 1.7,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0x0FFFFFFF),
            borderRadius: PwfHomeRadii.br30,
            border: Border.all(color: const Color(0x22FFFFFF)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _emailCtrl,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.cairo(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'البريد الإلكتروني',
                    hintStyle: GoogleFonts.cairo(
                      color: const Color(0xB3FFFFFF),
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              InkWell(
                borderRadius: PwfHomeRadii.br30,
                onTap: () => context.go(AppRoutes.underConstruction),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FaIcon(
                    FontAwesomeIcons.paperPlane,
                    color: PwfHomePalette.secondary,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _copyright(BuildContext context) {
    Widget link(String label) {
      return InkWell(
        onTap: () => context.go(AppRoutes.underConstruction),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            color: const Color(0xD9FFFFFF),
            decoration: TextDecoration.underline,
          ),
        ),
      );
    }

    return Column(
      children: [
        Text(
          'جميع الحقوق محفوظة © 2023 وزارة الأوقاف والشؤون الدينية - دولة فلسطين. المنصة الإلكترونية المتكاملة.',
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            color: const Color(0xD9FFFFFF),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 6,
          children: [
            link('سياسة الخصوصية'),
            const Text('|', style: TextStyle(color: Color(0x99FFFFFF))),
            link('شروط الاستخدام'),
            const Text('|', style: TextStyle(color: Color(0x99FFFFFF))),
            link('إمكانية الوصول'),
            const Text('|', style: TextStyle(color: Color(0x99FFFFFF))),
            link('خريطة الموقع'),
          ],
        ),
      ],
    );
  }

  Widget _socialIcon({required IconData icon, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0x14FFFFFF),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0x22FFFFFF)),
          ),
          child: Center(child: FaIcon(icon, size: 15, color: Colors.white)),
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
