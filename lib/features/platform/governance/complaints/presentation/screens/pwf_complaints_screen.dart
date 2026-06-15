import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:waqf/features/platform/home/presentation/screens/pwf_web_page_scaffold.dart';
import 'package:waqf/features/platform/home/presentation/screens/pages/pwf_public_content_shared.dart';
import '../l10n/pwf_complaints_strings.dart';
import '../providers/pwf_complaints_providers.dart';
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
                  _ComplaintsHero(s: s, unitSlug: unitSlug),
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
  const _ComplaintsHero({required this.s, required this.unitSlug});

  final PwfComplaintsStrings s;
  final String unitSlug;

  @override
  Widget build(BuildContext context) {
    return PwfPublicIntroCard(
      title: s.t('complaints.title'),
      subtitle:
          'قناة عامة موثوقة لتلقي الشكاوى والمقترحات والاستفسارات، مع تجربة واضحة ومنسجمة مع هوية وزارة الأوقاف والشؤون الدينية.',
      icon: Icons.assignment_rounded,
      unitSlug: unitSlug,
    );
  }
}

