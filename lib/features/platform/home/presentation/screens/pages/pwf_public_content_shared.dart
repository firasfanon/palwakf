import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:waqf/presentation/providers/unit_context_provider.dart';

import '../../theme/pwf_home_palette.dart';
import 'package:waqf/features/platform/home/presentation/widgets/shared/pwf_home_visual_contract.dart';
import 'package:waqf/features/platform/home/presentation/widgets/shared/pwf_public_safe_error.dart';

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
  if (normalizedSlug == 'home') {
    return contextual.isNotEmpty ? contextual : 'الوزارة';
  }

  final unitLabel = pwfUnitNameFromRow(unit);
  if (unitLabel != null) return unitLabel;

  final fallbackLabel = pwfFallbackUnitNameFromSlug(normalizedSlug);
  if (fallbackLabel != null) return fallbackLabel;

  if (contextual.isNotEmpty && !pwfLooksLikeGenericMinistryLabel(contextual)) {
    return contextual;
  }

  return 'الجهة الحالية';
}

String? pwfUnitNameFromRow(Map<String, dynamic>? unit) {
  final profile = _firstProfile(unit);
  final candidates = [
    unit?['name_ar'],
    unit?['title_ar'],
    profile?['display_name_ar'],
    profile?['name_ar'],
    profile?['title_ar'],
    unit?['name'],
    unit?['name_en'],
  ];
  for (final candidate in candidates) {
    final value = (candidate ?? '').toString().trim();
    if (value.isNotEmpty && !pwfLooksLikeGenericMinistryLabel(value)) {
      return value;
    }
  }
  return null;
}

Map<String, dynamic>? _firstProfile(Map<String, dynamic>? unit) {
  final raw = unit?['org_unit_profiles'];
  if (raw is List && raw.isNotEmpty && raw.first is Map) {
    return Map<String, dynamic>.from(raw.first as Map);
  }
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return null;
}

String? pwfFallbackUnitNameFromSlug(String unitSlug) {
  switch (unitSlug.trim().toLowerCase()) {
    case 'home':
      return 'وزارة الأوقاف والشؤون الدينية';
    case 'jer':
    case 'jerusalem':
      return 'مديرية أوقاف القدس';
    case 'ram':
    case 'ramallah':
      return 'مديرية أوقاف رام الله والبيرة';
    case 'nbl':
    case 'nablus':
      return 'مديرية أوقاف نابلس';
    case 'jen':
    case 'jenin':
      return 'مديرية أوقاف جنين';
    case 'tlk':
    case 'tulkarm':
      return 'مديرية أوقاف طولكرم';
    case 'qalq':
    case 'qalqilya':
      return 'مديرية أوقاف قلقيلية';
    case 'slf':
    case 'salfit':
      return 'مديرية أوقاف سلفيت';
    case 'tub':
    case 'tubas':
      return 'مديرية أوقاف طوباس';
    case 'jrh':
    case 'jericho':
      return 'مديرية أوقاف أريحا والأغوار';
    case 'bth':
    case 'bethlehem':
      return 'مديرية أوقاف بيت لحم';
    case 'hbr':
    case 'hebron':
      return 'مديرية أوقاف الخليل';
    default:
      return null;
  }
}

bool pwfLooksLikeGenericMinistryLabel(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) return false;
  return normalized == 'وزارة الأوقاف والشؤون الدينية' ||
      normalized == 'وزارة الاوقاف والشؤون الدينية' ||
      normalized == 'الوزارة' ||
      normalized.toLowerCase() == 'ministry';
}

String pwfScopeLabel(String unitSlug) =>
    pwfResolveScopeLabel(unitSlug: unitSlug);

/// Returns true when a string belongs to operator/developer governance rather
/// than to citizen-facing copy. Public pages must not expose these labels.
bool pwfIsTechnicalPublicNote(String? value) {
  final text = (value ?? '').trim();
  if (text.isEmpty) return false;
  final lowered = text.toLowerCase();
  return lowered.contains('rpc') ||
      lowered.contains('rls') ||
      lowered.contains('sql') ||
      lowered.contains('uat') ||
      lowered.contains('fallback') ||
      lowered.contains('backend') ||
      lowered.contains('wrapper') ||
      lowered.contains('allowlist') ||
      lowered.contains('source rows') ||
      lowered.contains('owner schema') ||
      lowered.contains('schema') ||
      lowered.contains('unitSlug'.toLowerCase()) ||
      lowered.contains('pwf-sis') ||
      lowered.contains('waqf_assets') ||
      lowered.contains('mustakshif') ||
      lowered.contains('cases') ||
      lowered.contains('assistant/') ||
      lowered.contains('public.v_') ||
      lowered.contains('public.') ||
      lowered.contains('zakat.public') ||
      lowered.contains('billing_system') ||
      lowered.contains('platform_services') ||
      lowered.contains('مصدر البيانات') ||
      lowered.contains('المسار الرسمي') ||
      lowered.contains('المصادر المسموح') ||
      lowered.contains('عقد المصدر') ||
      lowered.contains('حالة الجاهزية') ||
      lowered.contains('بوابة الاعتماد') ||
      lowered.contains('الربط التشغيلي') ||
      lowered.contains('قاعدة البيانات') ||
      lowered.contains('السيادية') ||
      lowered.contains('المالك') ||
      lowered.contains('حوكمة');
}

String pwfPublicCopyOrFallback(String value, String fallback) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return fallback;
  return pwfIsTechnicalPublicNote(trimmed) ? fallback : trimmed;
}

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
    final unit = ref.watch(orgUnitBySlugProvider(unitSlug)).valueOrNull;
    final scopeLabel = pwfResolveScopeLabel(unitSlug: unitSlug, unit: unit);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 780;
        final iconBox = PwfVisualIconTile(
          icon: icon,
          color: PwfHomePalette.secondary,
          backgroundColor: Colors.white.withValues(alpha: 0.12),
          size: compact ? 44 : 52,
        );
        final badges = Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            PwfVisualChip(
              label: scopeLabel,
              icon: Icons.apartment_outlined,
              color: Colors.white,
            ),
          ],
        );
        final publicSubtitle = pwfPublicCopyOrFallback(
          subtitle,
          'صفحة عامة ضمن الموقع الرسمي، تعرض المعلومات والخدمات بصياغة واضحة للجمهور.',
        );
        // Platform 12: public mastheads do not render governance/developer notes.
        final text = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            badges,
            const SizedBox(height: 6),
            Text(
              title,
              style: PwfHomeVisualContract.onDarkTitleStyle(context),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: Text(
                publicSubtitle,
                style: PwfHomeVisualContract.onDarkBodyStyle(context),
              ),
            ),
          ],
        );

        return Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: compact ? 108 : 126),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 16 : 20,
            vertical: compact ? 14 : 18,
          ),
          decoration: BoxDecoration(
            gradient: PwfHomeVisualContract.sovereignGradient(),
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [PwfHomeVisualContract.elevatedCardShadow],
          ),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [iconBox, const SizedBox(height: 12), text],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: text),
                    const SizedBox(width: 14),
                    iconBox,
                  ],
                ),
        );
      },
    );
  }
}

class PwfStatsWrap extends StatelessWidget {
  const PwfStatsWrap({super.key, required this.items});

  final List<PwfStatItem> items;

  @override
  Widget build(BuildContext context) {
    return PwfVisualResponsiveGrid(
      desktopColumns: 4,
      tabletColumns: 2,
      minCardWidth: 220,
      children: [
        for (final item in items)
          PwfVisualCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                PwfVisualIconTile(icon: item.icon, color: item.color, size: 42),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.value}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: PwfHomePalette.primary,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: PwfHomePalette.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
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
    return PwfVisualCard(
      padding: padding ?? const EdgeInsets.all(16),
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
    return PwfVisualChip(label: label, icon: icon, color: color);
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
    return PwfVisualCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 14),
            Text(
              message,
              style: PwfHomeVisualContract.cardBodyStyle(context),
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
    return PwfVisualEmptyState(
      title: title,
      message: message,
      icon: icon,
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
              PwfPublicSafeError.messageFor(message),
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
