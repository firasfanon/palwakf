import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:waqf/features/platform/home/presentation/screens/pwf_web_page_scaffold.dart';
import '../l10n/pwf_complaints_strings.dart';
import '../providers/pwf_complaints_providers.dart';
import '../widgets/pwf_complaints_header.dart';
import '../widgets/pwf_complaints_tab_scaffold.dart';
import '../widgets/pwf_public_footer_lite.dart';
import '../widgets/pwf_public_header_lite.dart';
import '../widgets/tabs/pwf_complaints_faq_tab.dart';
import '../widgets/tabs/pwf_complaints_new_tab.dart';
import '../widgets/tabs/pwf_complaints_suggestions_tab.dart';
import '../widgets/tabs/pwf_complaints_track_tab.dart';

class PwfComplaintsScreen extends ConsumerWidget {
  final String unitSlug;
  final bool embedInPublicShell;

  const PwfComplaintsScreen({
    super.key,
    required this.unitSlug,
    this.embedInPublicShell = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = PwfComplaintsStrings.of(context);
    final normalizedUnitSlug = unitSlug.trim().isEmpty
        ? 'home'
        : unitSlug.trim().toLowerCase();

    final usePublicShell = kIsWeb || embedInPublicShell;

    final content = ProviderScope(
      overrides: [
        pwfComplaintsUnitSlugProvider.overrideWith((ref) => normalizedUnitSlug),
      ],
      child: _ComplaintsPageBody(
        unitSlug: normalizedUnitSlug,
        embedInPublicShell: usePublicShell,
      ),
    );

    if (usePublicShell && kIsWeb) {
      return PwfWebPageScaffold(unitSlug: normalizedUnitSlug, child: content);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            PwfPublicHeaderLite(
              unitSlug: normalizedUnitSlug,
              title: s.t('complaints.title'),
              homeLabel: s.t('complaints.btn.home'),
            ),
            Expanded(child: content),
            PwfPublicFooterLite(text: s.t('complaints.footer.copy')),
          ],
        ),
      ),
    );
  }
}

class _ComplaintsPageBody extends ConsumerWidget {
  const _ComplaintsPageBody({
    required this.unitSlug,
    required this.embedInPublicShell,
  });

  final String unitSlug;
  final bool embedInPublicShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = PwfComplaintsStrings.of(context);
    final screenH = MediaQuery.of(context).size.height;
    final tabsHeight = math.max(760.0, math.min(980.0, screenH * 0.84));

    final inner = LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = 1100.0;
        final horizontalPadding = constraints.maxWidth >= 1200 ? 24.0 : 16.0;

        final pageContent = Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ComplaintsHero(s: s),
                  const SizedBox(height: 18),
                  PwfComplaintsHeader(
                    title: s.t('complaints.title'),
                    subtitle: s.t('complaints.subtitle'),
                  ),
                  const SizedBox(height: 16),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      height: tabsHeight,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: PwfComplaintsTabScaffold(
                          tabs: [
                            s.t('complaints.tab.new'),
                            s.t('complaints.tab.track'),
                            s.t('complaints.tab.suggestions'),
                            s.t('complaints.tab.faq'),
                          ],
                          children: const [
                            PwfComplaintsNewTab(),
                            PwfComplaintsTrackTab(),
                            PwfComplaintsSuggestionsTab(),
                            PwfComplaintsFaqTab(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        return pageContent;
      },
    );

    if (embedInPublicShell) {
      return SingleChildScrollView(child: inner);
    }
    return inner;
  }
}

class _ComplaintsHero extends StatelessWidget {
  const _ComplaintsHero({required this.s});

  final PwfComplaintsStrings s;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [Color(0xFF0B3A6A), Color(0xFF0F4D7D)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withValues(alpha: 36),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: 90),
              ),
            ),
            child: const Text(
              'الواجهة العامة • الشكاوى والمقترحات',
              style: TextStyle(
                color: Color(0xFFFFF4CC),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            s.t('complaints.title'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'قناة عامة موثوقة لتلقي الشكاوى والمقترحات والاستفسارات، مع تجربة بصرية منسجمة مع هوية وزارة الأوقاف والشؤون الدينية.',
            style: const TextStyle(
              color: Color(0xFFE7EEF7),
              fontSize: 14,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _HeroChip(icon: Icons.assignment_rounded, text: 'تقديم شكوى'),
              _HeroChip(icon: Icons.query_stats_rounded, text: 'تتبع الطلب'),
              _HeroChip(icon: Icons.tips_and_updates_rounded, text: 'مقترحات'),
              _HeroChip(icon: Icons.help_outline_rounded, text: 'أسئلة شائعة'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
