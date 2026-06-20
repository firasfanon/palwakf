part of 'pwf_content_pages.dart';

class _PwfCmsOrFallbackPage extends ConsumerWidget {
  const _PwfCmsOrFallbackPage({
    required this.unitSlug,
    required this.pageSlug,
    required this.title,
    required this.subtitle,
    required this.sections,
    required this.primaryActionLabel,
    required this.primaryActionPath,
  });

  final String unitSlug;
  final String pageSlug;
  final String title;
  final String subtitle;
  final List<_PwfContentSection> sections;
  final String primaryActionLabel;
  final String primaryActionPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageAsync = ref.watch(
      pwfSitePageProvider(PwfSitePageParam(unitSlug: unitSlug, slug: pageSlug)),
    );

    return pageAsync.when(
      loading: () {
        // Fail-open: show fallback while loading (no skeleton jitter on public pages).
        return _PwfContentPage(
          unitSlug: unitSlug,
          title: title,
          subtitle: subtitle,
          sections: sections,
          primaryActionLabel: primaryActionLabel,
          primaryActionPath: primaryActionPath,
        );
      },
      error: (_, __) {
        // Fail-open: always show fallback.
        return _PwfContentPage(
          unitSlug: unitSlug,
          title: title,
          subtitle: subtitle,
          sections: sections,
          primaryActionLabel: primaryActionLabel,
          primaryActionPath: primaryActionPath,
        );
      },
      data: (page) {
        if (page == null) {
          return _PwfContentPage(
            unitSlug: unitSlug,
            title: title,
            subtitle: subtitle,
            sections: sections,
            primaryActionLabel: primaryActionLabel,
            primaryActionPath: primaryActionPath,
          );
        }

        final isAr =
            Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
        final cmsTitle = isAr ? page.titleAr : page.titleEn;
        final cmsSubtitle = isAr ? page.subtitleAr : page.subtitleEn;
        final cmsBody = isAr ? page.bodyAr : page.bodyEn;
        final cmsSections = _pwfParseCmsBodyToSections(cmsBody);

        return _PwfContentPage(
          unitSlug: unitSlug,
          title: cmsTitle.trim().isEmpty ? title : cmsTitle,
          subtitle: cmsSubtitle.trim().isEmpty ? subtitle : cmsSubtitle,
          sections: cmsSections.isEmpty ? sections : cmsSections,
          primaryActionLabel: primaryActionLabel,
          primaryActionPath: primaryActionPath,
        );
      },
    );
  }
}

List<_PwfContentSection> _pwfParseCmsBodyToSections(String body) {
  final text = body.trim();
  if (text.isEmpty) return const [];

  final lines = text.split('\n');
  final sections = <_PwfContentSection>[];

  String currentHeading = '';
  final paragraphBuffer = <String>[];
  final bullets = <String>[];

  void flush() {
    final p = paragraphBuffer.join('\n').trim();
    if (currentHeading.isEmpty && p.isEmpty && bullets.isEmpty) return;
    sections.add(
      _PwfContentSection(
        heading: currentHeading,
        body: p.isEmpty ? null : p,
        bullets: bullets.isEmpty ? null : List<String>.from(bullets),
      ),
    );
    paragraphBuffer.clear();
    bullets.clear();
  }

  for (final raw in lines) {
    final line = raw.trimRight();
    if (line.trim().startsWith('## ')) {
      flush();
      currentHeading = line.trim().substring(3).trim();
      continue;
    }
    if (line.trim().startsWith('- ')) {
      bullets.add(line.trim().substring(2).trim());
      continue;
    }
    paragraphBuffer.add(line);
  }
  flush();

  // If the CMS body has no headings at all, ensure one section.
  if (sections.length == 1 && sections.first.heading.trim().isEmpty) {
    return sections;
  }
  return sections;
}

// ----------------- Shared building blocks -----------------

class _PwfContentPage extends ConsumerWidget {
  const _PwfContentPage({
    required this.unitSlug,
    required this.title,
    required this.subtitle,
    required this.sections,
    required this.primaryActionLabel,
    required this.primaryActionPath,
  });

  final String unitSlug;
  final String title;
  final String subtitle;
  final List<_PwfContentSection> sections;
  final String primaryActionLabel;
  final String primaryActionPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
    final normalizedSlug = unitSlug.trim().isEmpty
        ? 'home'
        : unitSlug.trim().toLowerCase();
    final unit = ref.watch(orgUnitBySlugProvider(normalizedSlug)).valueOrNull;
    final scopeLabel = pwfResolveScopeLabel(
      unitSlug: normalizedSlug,
      unit: unit,
    );
    final displayTitle = _scopedPublicTitle(
      title: title,
      scopeLabel: scopeLabel,
      unitSlug: normalizedSlug,
      isAr: isAr,
    );

    return PwfWebPageScaffold(
      unitSlug: normalizedSlug,
      title: displayTitle,
      showTitleSection: true,
      child: PwfSectionContainer(
        sectionKey: 'public-subpage-$unitSlug',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PwfSubpageHero(
              title: displayTitle,
              subtitle: subtitle,
              eyebrow: isAr ? 'صفحة تعريفية رسمية' : 'Official public page',
              scopeLabel: scopeLabel,
              icon: _subpageIconForTitle(displayTitle),
            ),
            const SizedBox(height: 22),
            PwfVisualResponsiveGrid(
              desktopColumns: sections.length <= 2 ? 2 : 3,
              tabletColumns: 2,
              minCardWidth: 300,
              children: [
                for (final s in sections) _SectionBlock(section: s),
              ],
            ),
            const SizedBox(height: 22),
            PwfVisualCard(
              padding: const EdgeInsets.all(18),
              child: PwfVisualActionStack(
                children: [
                  _ActionButton(
                    label: primaryActionLabel,
                    filled: true,
                    onTap: () => context.go(
                      _scopedPublicPath(primaryActionPath, normalizedSlug),
                    ),
                  ),
                  _ActionButton(
                    label: isAr ? 'آخر الأخبار' : 'Latest News',
                    filled: false,
                    onTap: () => context.go(
                      _scopedPublicPath('/news', normalizedSlug),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


String _scopedPublicTitle({
  required String title,
  required String scopeLabel,
  required String unitSlug,
  required bool isAr,
}) {
  if (unitSlug == 'home') return title;
  final trimmed = title.trim();
  if (isAr && trimmed == 'عن الوزارة') return 'عن $scopeLabel';
  if (!isAr && trimmed.toLowerCase() == 'about the ministry') {
    return 'About $scopeLabel';
  }
  return trimmed.isEmpty ? scopeLabel : trimmed;
}

String _scopedPublicPath(String path, String unitSlug) {
  final normalizedSlug = PwfUnitSlugRegistry.publicSlugFor(unitSlug);
  final value = path.trim();
  if (value.isEmpty) {
    return normalizedSlug == 'home' ? '/home' : '/$normalizedSlug';
  }
  if (value.startsWith('http://') || value.startsWith('https://')) return value;
  final normalizedPath = value.startsWith('/') ? value : '/$value';
  if (normalizedSlug == 'home') {
    if (normalizedPath == '/news') return '/home/news';
    return normalizedPath;
  }
  if (normalizedPath == '/home') return '/$normalizedSlug';
  if (normalizedPath.startsWith('/home/')) {
    return '/$normalizedSlug/${normalizedPath.substring('/home/'.length)}';
  }
  return '/$normalizedSlug$normalizedPath';
}

class _PwfSubpageHero extends StatelessWidget {
  const _PwfSubpageHero({
    required this.title,
    required this.subtitle,
    required this.eyebrow,
    required this.scopeLabel,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String eyebrow;
  final String scopeLabel;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile = constraints.maxWidth < 640;
        return Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: mobile ? 180 : 220),
          padding: EdgeInsets.all(mobile ? 18 : 28),
      decoration: BoxDecoration(
        gradient: PwfHomeVisualContract.sovereignGradient(),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [PwfHomeVisualContract.elevatedCardShadow],
      ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 720;
          final text = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  PwfVisualChip(
                    label: eyebrow,
                    icon: Icons.verified_outlined,
                    color: PwfHomePalette.secondary,
                  ),
                  PwfVisualChip(
                    label: scopeLabel,
                    icon: Icons.apartment_outlined,
                    color: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.92),
                  height: 1.75,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
          final iconBox = Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            ),
            child: Icon(icon, color: PwfHomePalette.secondary, size: 54),
          );
              if (compact) return text;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: text),
                  const SizedBox(width: 24),
                  iconBox,
                ],
              );
            },
          ),
        );
      },
    );
  }
}

IconData _subpageIconForTitle(String title) {
  final normalized = title.toLowerCase();
  if (normalized.contains('رؤية') || normalized.contains('vision')) {
    return Icons.visibility_outlined;
  }
  if (normalized.contains('وزارة') || normalized.contains('ministry')) {
    return Icons.account_balance_outlined;
  }
  if (normalized.contains('وزير') || normalized.contains('minister')) {
    return Icons.record_voice_over_outlined;
  }
  if (normalized.contains('هيكل') || normalized.contains('structure')) {
    return Icons.account_tree_outlined;
  }
  return Icons.article_outlined;
}

class _PwfContentSection {
  const _PwfContentSection({required this.heading, this.body, this.bullets});

  final String heading;
  final String? body;
  final List<String>? bullets;
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({required this.section});
  final _PwfContentSection section;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile = constraints.maxWidth < 640;
        return PwfVisualCard(
          showAccentRail: true,
          padding: EdgeInsetsDirectional.fromSTEB(
            mobile ? 18 : 24,
            mobile ? 18 : 22,
            mobile ? 18 : 24,
            mobile ? 18 : 22,
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.only(start: mobile ? 6 : 10),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                PwfVisualIconTile(
                  icon: Icons.done_all_outlined,
                  color: PwfHomePalette.royalRed,
                  size: mobile ? 40 : 44,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    section.heading,
                    style: PwfHomeVisualContract.cardTitleStyle(context),
                  ),
                ),
              ],
            ),
            if (section.body != null && section.body!.trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                section.body!,
                style: PwfHomeVisualContract.cardBodyStyle(context),
              ),
            ],
            if (section.bullets != null && section.bullets!.isNotEmpty) ...[
              const SizedBox(height: 12),
              for (final b in section.bullets!)
                Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: PwfHomePalette.secondary,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          b,
                          style: PwfHomeVisualContract.cardBodyStyle(context),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActionButton extends ConsumerStatefulWidget {
  const _ActionButton({
    required this.label,
    required this.onTap,
    required this.filled,
  });

  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  ConsumerState<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends ConsumerState<_ActionButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final themeKey = ref.watch(pwfUiPrefsProvider).themeKey;
    final t = PwfThemeTokens.forKey(themeKey);

    final bg = widget.filled
        ? (_hover ? t.accentHover : t.accent)
        : (_hover ? t.surfaceHover : t.surface);

    final fg = widget.filled ? t.onAccent : t.text;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.filled ? Colors.transparent : t.border,
            ),
          ),
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
