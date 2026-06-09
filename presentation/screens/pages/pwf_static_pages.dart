import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/pwf_theme_tokens.dart';
import '../../providers/pwf_ui_prefs_provider.dart';
import '../pwf_web_page_scaffold.dart';
import '../../widgets/pwf_section_container.dart';

/// Generic HTML-identity page used for public static pages until full CMS binding is ready.
/// Web-only: use inside GoRouter when kIsWeb == true.
class PwfStaticPageWebScreen extends ConsumerWidget {
  const PwfStaticPageWebScreen({
    super.key,
    required this.unitSlug,
    required this.titleAr,
    required this.titleEn,
    this.subtitleAr,
    this.subtitleEn,
    this.icon,
  });

  final String unitSlug;
  final String titleAr;
  final String titleEn;
  final String? subtitleAr;
  final String? subtitleEn;
  final IconData? icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = Directionality.of(context) == TextDirection.rtl;
    final title = isAr ? titleAr : titleEn;
    final subtitle = isAr ? subtitleAr : subtitleEn;

    return PwfWebPageScaffold(
      unitSlug: unitSlug,
      title: title,
      child: PwfSectionContainer(
        child: _ContentCard(title: title, subtitle: subtitle, icon: icon),
      ),
    );
  }
}

class _ContentCard extends ConsumerWidget {
  const _ContentCard({required this.title, this.subtitle, this.icon});

  final String title;
  final String? subtitle;
  final IconData? icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeKey = ref.watch(pwfUiPrefsProvider).themeKey;
    final t = PwfThemeTokens.forKey(themeKey);

    return Container(
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
          Row(
            children: [
              if (icon != null)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: t.accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: t.accent),
                ),
              if (icon != null) const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              subtitle!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: t.mutedText, height: 1.6),
            ),
          ],
          const SizedBox(height: 14),
          Text(
            Directionality.of(context) == TextDirection.rtl
                ? 'يجري استكمال محتوى هذه الصفحة وفق الهوية البصرية الجديدة. يمكنك العودة للرئيسية أو متابعة آخر الأخبار.'
                : 'This page is being completed under the new visual identity. You can return to Home or explore latest news.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.7),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ActionButton(
                label: Directionality.of(context) == TextDirection.rtl
                    ? 'العودة للرئيسية'
                    : 'Back to Home',
                filled: true,
                onTap: () => context.go('/home'),
              ),
              _ActionButton(
                label: Directionality.of(context) == TextDirection.rtl
                    ? 'آخر الأخبار'
                    : 'Latest News',
                filled: false,
                onTap: () => context.go('/home/news'),
              ),
            ],
          ),
        ],
      ),
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
