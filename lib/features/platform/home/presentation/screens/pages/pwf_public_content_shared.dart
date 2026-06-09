import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:waqf/presentation/providers/unit_context_provider.dart';

import '../../theme/pwf_home_palette.dart';
import '../../widgets/pwf_hover_card.dart';

String pwfFormatArabicDate(DateTime? dt) {
  if (dt == null) return 'غير محدد';
  const months = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];
  final m = months[(dt.month - 1).clamp(0, 11)];
  return '${dt.day} $m ${dt.year}';
}

String pwfResolveScopeLabel({
  required String unitSlug,
  Map<String, dynamic>? unit,
  String? contextualLabel,
}) {
  final normalizedSlug = unitSlug.trim().isEmpty
      ? 'home'
      : unitSlug.trim().toLowerCase();
  final contextual = (contextualLabel ?? '').trim();
  if (contextual.isNotEmpty) return contextual;
  if (normalizedSlug == 'home') return 'الوزارة';

  final candidates = [
    unit?['name_ar'],
    unit?['title_ar'],
    unit?['name'],
    unit?['name_en'],
  ];
  for (final candidate in candidates) {
    final value = (candidate ?? '').toString().trim();
    if (value.isNotEmpty) return value;
  }

  return 'الوحدة الحالية';
}

String pwfScopeLabel(String unitSlug) =>
    pwfResolveScopeLabel(unitSlug: unitSlug);

class PwfPublicIntroCard extends ConsumerWidget {
  const PwfPublicIntroCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.unitSlug,
    this.note,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String unitSlug;
  final String? note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHome = unitSlug.toLowerCase() == 'home';
    final unit = ref.watch(orgUnitBySlugProvider(unitSlug)).valueOrNull;
    final scopeLabel = pwfResolveScopeLabel(unitSlug: unitSlug, unit: unit);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PwfHomePalette.primary,
            PwfHomePalette.primary.withValues(alpha: 0.90),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: PwfHomeRadii.br20,
        boxShadow: const [
          BoxShadow(
            color: PwfHomePalette.shadow,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: PwfHomePalette.secondary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isHome ? 'محتوى الصفحة الرئيسية' : 'محتوى صفحة الوحدة',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  scopeLabel,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: GoogleFonts.cairo(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 14.5,
              height: 1.7,
            ),
          ),
          if (note?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      note!,
                      style: GoogleFonts.cairo(
                        color: Colors.white.withValues(alpha: 0.90),
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class PwfStatsWrap extends StatelessWidget {
  const PwfStatsWrap({super.key, required this.items});

  final List<PwfStatItem> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final cols = w >= 1100 ? 4 : (w >= 740 ? 2 : 1);
        const spacing = 14.0;
        final cardW = (w - (spacing * (cols - 1))) / cols;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final item in items)
              SizedBox(
                width: cardW,
                child: PwfSurfaceCard(
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(item.icon, color: item.color, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item.value}',
                              style: GoogleFonts.cairo(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: PwfHomePalette.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.label,
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: PwfHomePalette.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class PwfStatItem {
  const PwfStatItem({
    required this.label,
    required this.value,
    required this.icon,
    this.color = PwfHomePalette.primary,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;
}

class PwfSurfaceCard extends StatelessWidget {
  const PwfSurfaceCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return PwfHoverCard(
      padding: padding ?? const EdgeInsets.all(18),
      child: child,
    );
  }
}

class PwfMetaBadge extends StatelessWidget {
  const PwfMetaBadge({
    super.key,
    required this.label,
    this.icon,
    this.color = PwfHomePalette.primary,
    this.backgroundColor,
  });

  final String label;
  final IconData? icon;
  final Color color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class PwfSearchBox extends StatelessWidget {
  const PwfSearchBox({
    super.key,
    required this.hint,
    required this.onChanged,
    this.initialValue,
  });

  final String hint;
  final String? initialValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      textDirection: TextDirection.rtl,
      style: GoogleFonts.cairo(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: PwfHomePalette.primary,
            width: 1.2,
          ),
        ),
      ),
    );
  }
}

class PwfFilterChipButton extends StatelessWidget {
  const PwfFilterChipButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.selectedColor,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? selectedColor;

  @override
  Widget build(BuildContext context) {
    final color = selectedColor ?? PwfHomePalette.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? color : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : PwfHomePalette.textSecondary,
          ),
        ),
      ),
    );
  }
}

class PwfLoadingBlock extends StatelessWidget {
  const PwfLoadingBlock({super.key, this.message = 'جاري التحميل...'});
  final String message;

  @override
  Widget build(BuildContext context) {
    return PwfSurfaceCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 14),
            Text(
              message,
              style: GoogleFonts.cairo(color: PwfHomePalette.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class PwfEmptyBlock extends StatelessWidget {
  const PwfEmptyBlock({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return PwfSurfaceCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(
              icon,
              size: 38,
              color: PwfHomePalette.textSecondary.withValues(alpha: 0.70),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: PwfHomePalette.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 13.5,
                height: 1.7,
                color: PwfHomePalette.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PwfErrorBlock extends StatelessWidget {
  const PwfErrorBlock({super.key, required this.onRetry, this.message});

  final VoidCallback onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return PwfSurfaceCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 40,
              color: PwfHomePalette.royalRed,
            ),
            const SizedBox(height: 12),
            Text(
              'تعذر تحميل البيانات',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: PwfHomePalette.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message ??
                  'حدث خطأ أثناء جلب البيانات. يمكنك إعادة المحاولة الآن.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 13.5,
                height: 1.7,
                color: PwfHomePalette.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: PwfHomePalette.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PwfDetailActionsBar extends StatelessWidget {
  const PwfDetailActionsBar({
    super.key,
    required this.actions,
    this.title = 'إجراءات سريعة',
    this.subtitle,
  });

  final List<Widget> actions;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return PwfSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: PwfHomePalette.primary,
            ),
          ),
          if (subtitle?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: GoogleFonts.cairo(
                fontSize: 13,
                height: 1.7,
                color: PwfHomePalette.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Wrap(spacing: 10, runSpacing: 10, children: actions),
        ],
      ),
    );
  }
}

class PwfDetailSectionTitle extends StatelessWidget {
  const PwfDetailSectionTitle({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: PwfHomePalette.primary,
          ),
        ),
        if (subtitle?.trim().isNotEmpty == true) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: GoogleFonts.cairo(
              fontSize: 13.5,
              height: 1.7,
              color: PwfHomePalette.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class PwfDetailInfoGrid extends StatelessWidget {
  const PwfDetailInfoGrid({super.key, required this.items});

  final List<PwfDetailInfoItem> items;

  @override
  Widget build(BuildContext context) {
    final visibleItems = items.where((e) => e.value.trim().isNotEmpty).toList();
    if (visibleItems.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final cols = w >= 1100 ? 3 : (w >= 760 ? 2 : 1);
        const spacing = 12.0;
        final cardW = (w - (spacing * (cols - 1))) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final item in visibleItems)
              SizedBox(
                width: cardW,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(item.icon, size: 18, color: item.color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.label,
                              style: GoogleFonts.cairo(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: PwfHomePalette.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.value,
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                height: 1.55,
                                color: PwfHomePalette.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class PwfDetailInfoItem {
  const PwfDetailInfoItem({
    required this.label,
    required this.value,
    required this.icon,
    this.color = PwfHomePalette.primary,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class PwfRelatedLinksCard extends StatelessWidget {
  const PwfRelatedLinksCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return PwfSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PwfDetailSectionTitle(title: title, subtitle: subtitle),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
