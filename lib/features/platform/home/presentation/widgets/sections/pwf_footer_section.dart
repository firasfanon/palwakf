import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:waqf/app/routing/app_routes.dart';
import 'package:waqf/data/models/footer_settings.dart';
import 'package:waqf/presentation/providers/footer_settings_provider.dart';

import '../../theme/pwf_home_palette.dart';
import '../../providers/pwf_ui_prefs_provider.dart';
import '../../theme/pwf_theme_tokens.dart';

class PwfFooterSection extends ConsumerStatefulWidget {
  const PwfFooterSection({super.key, this.unitSlug = 'home'});

  final String unitSlug;

  @override
  ConsumerState<PwfFooterSection> createState() => _PwfFooterSectionState();
}

class _PwfFooterSectionState extends ConsumerState<PwfFooterSection> {
  @override
  Widget build(BuildContext context) {
    final themeKey = ref.watch(pwfUiPrefsProvider).themeKey;
    final t = PwfThemeTokens.forKey(themeKey);
    final w = MediaQuery.sizeOf(context).width;
    final hPad = w >= 768 ? 20.0 : 16.0;
    final asyncSettings = ref.watch(
      publicFooterSettingsProvider(widget.unitSlug),
    );
    final settings = asyncSettings.maybeWhen(
      data: (value) => value,
      orElse: _fallbackSettings,
    );

    return Container(
      width: double.infinity,
      color: t.footerBg,
      padding: EdgeInsets.fromLTRB(hPad, 26, hPad, 18),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, c) {
              final width = c.maxWidth;
              final isNarrow = width < 900;
              final colW = isNarrow ? width : (width - 40) / 3;

              return Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  SizedBox(width: colW, child: _aboutColumn(settings)),
                  SizedBox(width: colW, child: _contactColumn(settings)),
                  SizedBox(width: colW, child: _linksColumn(settings, context)),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          const Divider(color: Color(0x33FFFFFF)),
          const SizedBox(height: 12),
          _copyright(context, settings),
        ],
      ),
    );
  }

  FooterSettings _fallbackSettings() {
    final now = DateTime.now();
    return FooterSettings(
      id: 'fallback',
      ministryName: 'وزارة الأوقاف والشؤون الدينية',
      ministrySubtitle: 'دولة فلسطين',
      ministryDescription:
          'وزارة الأوقاف والشؤون الدينية تعمل على خدمة المجتمع الفلسطيني وتعزيز القيم الدينية والتراث الإسلامي.',
      contactPhone: '02-2411937/8/9',
      contactEmail: 'info@awqaf.ps',
      contactAddress: 'القدس - مدينة البيرة - حي الجنان - شارع النور',
      workingDays: 'من الأحد إلى الخميس',
      workingHours: '8:00 صباحاً - 3:00 مساءً',
      quickLinks: const [
        FooterLink(label: 'عن الوزارة', route: '/about'),
        FooterLink(label: 'كلمة الوزير', route: '/minister'),
      ],
      servicesLinks: const [
        FooterLink(label: 'الخدمات الإلكترونية', route: '/eservices'),
        FooterLink(label: 'المساجد', route: '/mosques'),
      ],
      bottomLinks: const [
        FooterLink(label: 'سياسة الخصوصية', route: '/privacy'),
        FooterLink(label: 'شروط الاستخدام', route: '/terms'),
        FooterLink(label: 'خريطة الموقع', route: '/sitemap'),
      ],
      copyrightText:
          '© 2024 وزارة الأوقاف والشؤون الدينية - دولة فلسطين. جميع الحقوق محفوظة.',
      developerCredit: 'تم التطوير بواسطة فريق تقنية المعلومات',
      createdAt: now,
      updatedAt: now,
    );
  }

  Widget _aboutColumn(FooterSettings settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if ((settings.ministryLogoUrl ?? '').trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                settings.ministryLogoUrl!,
                width: 64,
                height: 64,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
        Text(
          settings.ministryName,
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          settings.ministrySubtitle,
          style: GoogleFonts.cairo(
            fontSize: 13,
            color: const Color(0xD9FFFFFF),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          (settings.ministryDescription ?? '').trim().isEmpty
              ? 'وزارة الأوقاف والشؤون الدينية تخدم المجتمع الفلسطيني وتعزز القيم الدينية والتراث الإسلامي.'
              : settings.ministryDescription!,
          style: GoogleFonts.cairo(
            fontSize: 13.5,
            color: const Color(0xD9FFFFFF),
            height: 1.7,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            if ((settings.facebookUrl ?? '').trim().isNotEmpty)
              _socialIcon(
                icon: Icons.facebook,
                onTap: () => _openUrl(settings.facebookUrl!),
              ),
            if ((settings.twitterUrl ?? '').trim().isNotEmpty)
              _socialIcon(
                icon: Icons.alternate_email,
                onTap: () => _openUrl(settings.twitterUrl!),
              ),
            if ((settings.instagramUrl ?? '').trim().isNotEmpty)
              _socialIcon(
                icon: Icons.camera_alt,
                onTap: () => _openUrl(settings.instagramUrl!),
              ),
            if ((settings.youtubeUrl ?? '').trim().isNotEmpty)
              _socialIcon(
                icon: Icons.smart_display,
                onTap: () => _openUrl(settings.youtubeUrl!),
              ),
            if ((settings.linkedinUrl ?? '').trim().isNotEmpty)
              _socialIcon(
                icon: Icons.work,
                onTap: () => _openUrl(settings.linkedinUrl!),
              ),
          ],
        ),
      ],
    );
  }

  Widget _contactColumn(FooterSettings settings) {
    Widget row(IconData icon, String text) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Icon(icon, size: 14, color: PwfHomePalette.secondary),
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
        if (settings.showAddress &&
            (settings.contactAddress ?? '').trim().isNotEmpty)
          row(Icons.place, settings.contactAddress!),
        if (settings.showPhone &&
            (settings.contactPhone ?? '').trim().isNotEmpty)
          row(Icons.phone, settings.contactPhone!),
        if (settings.showEmail &&
            (settings.contactEmail ?? '').trim().isNotEmpty)
          row(Icons.email, settings.contactEmail!),
        if (settings.showWorkingHours)
          row(
            Icons.schedule,
            '${settings.workingDays} | ${settings.workingHours}',
          ),
      ],
    );
  }

  Widget _linksColumn(FooterSettings settings, BuildContext context) {
    final quick = settings.quickLinks.where((e) => e.enabled).toList();
    final services = settings.servicesLinks.where((e) => e.enabled).toList();

    Widget buildLink(FooterLink link) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: () => _openRoute(context, link.route),
          child: Text(
            link.label,
            style: GoogleFonts.cairo(
              fontSize: 13.5,
              color: const Color(0xD9FFFFFF),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'روابط وخدمات',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        ...quick.take(4).map(buildLink),
        if (quick.isNotEmpty && services.isNotEmpty) const SizedBox(height: 6),
        ...services.take(4).map(buildLink),
        if (quick.isEmpty && services.isEmpty)
          Text(
            'لا توجد روابط مفعلة حاليًا.',
            style: GoogleFonts.cairo(
              fontSize: 13.5,
              color: const Color(0xD9FFFFFF),
            ),
          ),
      ],
    );
  }

  Widget _copyright(BuildContext context, FooterSettings settings) {
    final links = settings.bottomLinks.where((e) => e.enabled).toList();

    return Column(
      children: [
        Text(
          settings.copyrightText,
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            color: const Color(0xD9FFFFFF),
            height: 1.6,
          ),
        ),
        if (settings.showDeveloperCredit &&
            settings.developerCredit.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            settings.developerCredit,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 12.5,
              color: const Color(0xD9FFFFFF),
              height: 1.6,
            ),
          ),
        ],
        if (links.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 6,
            children: [
              for (int i = 0; i < links.length; i++) ...[
                InkWell(
                  onTap: () => _openRoute(context, links[i].route),
                  child: Text(
                    links[i].label,
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      color: const Color(0xD9FFFFFF),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                if (i != links.length - 1)
                  const Text('|', style: TextStyle(color: Color(0x99FFFFFF))),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _socialIcon({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
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
        child: Center(child: Icon(icon, size: 15, color: Colors.white)),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openRoute(BuildContext context, String route) async {
    final trimmed = route.trim();
    if (trimmed.isEmpty) return;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      await _openUrl(trimmed);
      return;
    }
    if (!context.mounted) return;
    context.go(_normalizeFooterRoute(trimmed));
  }

  String _normalizeFooterRoute(String value) {
    switch (value) {
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
        return value.startsWith('/') ? value : '/$value';
    }
  }
}
