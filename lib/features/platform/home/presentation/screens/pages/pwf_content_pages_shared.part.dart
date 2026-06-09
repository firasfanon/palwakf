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
    final themeKey = ref.watch(pwfUiPrefsProvider).themeKey;
    final t = PwfThemeTokens.forKey(themeKey);

    return PwfWebPageScaffold(
      unitSlug: unitSlug,
      title: title,
      showTitleSection: true,
      child: PwfSectionContainer(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          decoration: BoxDecoration(
            color: t.cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: t.cardBorder),
            boxShadow: t.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: t.mutedText,
                  height: 1.7,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              for (final s in sections) ...[
                _SectionBlock(section: s),
                const SizedBox(height: 14),
              ],
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _ActionButton(
                    label: primaryActionLabel,
                    filled: true,
                    onTap: () => context.go(primaryActionPath),
                  ),
                  _ActionButton(
                    label:
                        Localizations.localeOf(
                              context,
                            ).languageCode.toLowerCase() ==
                            'ar'
                        ? 'آخر الأخبار'
                        : 'Latest News',
                    filled: false,
                    onTap: () => context.go('/home/news'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PwfContentSection {
  const _PwfContentSection({required this.heading, this.body, this.bullets});

  final String heading;
  final String? body;
  final List<String>? bullets;
}

class _SectionBlock extends ConsumerWidget {
  const _SectionBlock({required this.section});
  final _PwfContentSection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeKey = ref.watch(pwfUiPrefsProvider).themeKey;
    final t = PwfThemeTokens.forKey(themeKey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.heading,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        if (section.body != null && section.body!.trim().isNotEmpty)
          Text(
            section.body!,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.75),
          ),
        if (section.bullets != null && section.bullets!.isNotEmpty) ...[
          const SizedBox(height: 6),
          for (final b in section.bullets!)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 7),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: t.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      b,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(height: 1.7),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
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
