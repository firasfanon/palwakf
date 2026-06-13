import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:waqf/core/utils/date_utils.dart';
import 'package:waqf/data/models/homepage_section.dart';
import 'package:waqf/presentation/providers/homepage_settings_provider.dart';

String sharedAdminFormatDate(DateTime? date) {
  if (date == null) return '—';
  return AppDateUtils.formatArabicDate(date.toLocal());
}

String sharedAdminFormatDateTime(DateTime? date) {
  if (date == null) return '—';
  return AppDateUtils.formatArabicDateTime(date.toLocal());
}

class SharedAdminSurfaceCard extends StatelessWidget {
  const SharedAdminSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(24);

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Material(
        color: Colors.white,
        elevation: 1.5,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class SharedAdminStatCard extends StatelessWidget {
  const SharedAdminStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.helper,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    return SharedAdminSurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (helper != null && helper!.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    helper!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SharedAdminMetaChip extends StatelessWidget {
  const SharedAdminMetaChip({
    super.key,
    required this.label,
    this.icon,
    this.color = const Color(0xFF0B3A70),
    this.soft = false,
  });

  final String label;
  final IconData? icon;
  final Color color;
  final bool soft;

  @override
  Widget build(BuildContext context) {
    final bg = soft ? color.withValues(alpha: 0.08) : const Color(0xFFF8FAFC);
    final border = soft
        ? color.withValues(alpha: 0.18)
        : const Color(0xFFE5E7EB);
    final fg = soft ? color : const Color(0xFF374151);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final maxLabelWidth = screenWidth < 480 ? screenWidth - 120 : 320.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 6),
          ],
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxLabelWidth),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: fg,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SharedAdminSectionNotice extends StatelessWidget {
  const SharedAdminSectionNotice({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
    this.color = const Color(0xFF0B3A70),
  });

  final String message;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF374151),
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SharedAdminEmptyState extends StatelessWidget {
  const SharedAdminEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  final String title;
  final String message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return SharedAdminSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: const Color(0xFF9CA3AF)),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}

class SharedAdminLoadingState extends StatelessWidget {
  const SharedAdminLoadingState({
    super.key,
    this.message = 'جاري تحميل البيانات...',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return SharedAdminSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 14),
            Text(message),
          ],
        ),
      ),
    );
  }
}

class SharedAdminErrorState extends StatelessWidget {
  const SharedAdminErrorState({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return SharedAdminSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: Color(0xFFB22222)),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SharedAdminRecordActions extends StatelessWidget {
  const SharedAdminRecordActions({
    super.key,
    this.onView,
    this.onEdit,
    this.onDelete,
    this.extra,
    this.compact = false,
  });

  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Widget? extra;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[
      if (onView != null)
        OutlinedButton.icon(
          onPressed: onView,
          icon: const Icon(Icons.visibility_outlined, size: 18),
          label: const Text('عرض'),
        ),
      if (onEdit != null)
        FilledButton.tonalIcon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('تعديل'),
        ),
      if (onDelete != null)
        TextButton.icon(
          onPressed: onDelete,
          icon: const Icon(
            Icons.delete_outline,
            size: 18,
            color: Color(0xFFB22222),
          ),
          label: const Text('حذف', style: TextStyle(color: Color(0xFFB22222))),
        ),
      if (extra != null) extra!,
    ];

    if (compact) {
      return Wrap(spacing: 8, runSpacing: 8, children: buttons);
    }

    final spaced = <Widget>[];
    for (var i = 0; i < buttons.length; i++) {
      if (i > 0) spaced.add(const SizedBox(width: 8));
      spaced.add(buttons[i]);
    }

    return Row(children: spaced);
  }
}

class SharedHomepageCountSettings {
  const SharedHomepageCountSettings({
    required this.homeLimit,
    required this.showViewAll,
    this.extra = const <String, dynamic>{},
  });

  final int homeLimit;
  final bool showViewAll;
  final Map<String, dynamic> extra;

  factory SharedHomepageCountSettings.fromMap(
    Map<String, dynamic>? raw, {
    required int defaultHomeLimit,
    bool defaultShowViewAll = true,
  }) {
    final map = raw == null
        ? const <String, dynamic>{}
        : Map<String, dynamic>.from(raw);
    final dynamic rawLimit =
        map['home_limit'] ??
        map['max_items'] ??
        map['maxItems'] ??
        map['show_count'] ??
        map['showCount'];
    int parsedLimit = defaultHomeLimit;
    if (rawLimit is int) parsedLimit = rawLimit;
    if (rawLimit is num) parsedLimit = rawLimit.toInt();
    if (rawLimit is String)
      parsedLimit = int.tryParse(rawLimit.trim()) ?? defaultHomeLimit;
    parsedLimit = parsedLimit.clamp(1, 12);

    final dynamic rawShowViewAll = map['show_view_all'] ?? map['showViewAll'];
    bool parsedShowViewAll = defaultShowViewAll;
    if (rawShowViewAll is bool) parsedShowViewAll = rawShowViewAll;
    if (rawShowViewAll is String) {
      final normalized = rawShowViewAll.trim().toLowerCase();
      if (normalized == 'true') parsedShowViewAll = true;
      if (normalized == 'false') parsedShowViewAll = false;
    }

    return SharedHomepageCountSettings(
      homeLimit: parsedLimit,
      showViewAll: parsedShowViewAll,
      extra: map,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    'home_limit': homeLimit,
    'show_view_all': showViewAll,
    ...extra,
  };
}

class SharedHomepageCountControlCard extends ConsumerStatefulWidget {
  const SharedHomepageCountControlCard({
    super.key,
    required this.unitSlug,
    required this.unitId,
    required this.primarySectionName,
    required this.aliases,
    required this.title,
    required this.description,
    required this.defaultHomeLimit,
    this.allowedHomeLimits = const <int>[1, 2, 3, 4, 5, 6, 8, 10, 12],
  });

  final String unitSlug;
  final String unitId;
  final String primarySectionName;
  final List<String> aliases;
  final String title;
  final String description;
  final int defaultHomeLimit;
  final List<int> allowedHomeLimits;

  @override
  ConsumerState<SharedHomepageCountControlCard> createState() =>
      _SharedHomepageCountControlCardState();
}

class _SharedHomepageCountControlCardState
    extends ConsumerState<SharedHomepageCountControlCard> {
  late int _homeLimit;
  late bool _showViewAll;
  bool _hydrated = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _homeLimit = widget.defaultHomeLimit;
    _showViewAll = true;
  }

  @override
  void didUpdateWidget(covariant SharedHomepageCountControlCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.unitSlug != widget.unitSlug ||
        oldWidget.primarySectionName != widget.primarySectionName) {
      _hydrated = false;
      _homeLimit = widget.defaultHomeLimit;
      _showViewAll = true;
    }
  }

  HomepageSection? _resolveSection(List<HomepageSection> sections) {
    final wanted = <String>[widget.primarySectionName, ...widget.aliases];
    for (final alias in wanted) {
      for (final section in sections) {
        if (section.sectionName == alias) return section;
      }
    }
    return null;
  }

  void _hydrateIfNeeded(HomepageSection? section) {
    if (_hydrated) return;
    final settings = SharedHomepageCountSettings.fromMap(
      section?.settings,
      defaultHomeLimit: widget.defaultHomeLimit,
    );
    _homeLimit = settings.homeLimit;
    _showViewAll = settings.showViewAll;
    _hydrated = true;
  }

  Future<void> _save(HomepageSection? existingSection) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final repo = ref.read(homepageRepositoryProvider);
      final current = SharedHomepageCountSettings.fromMap(
        existingSection?.settings,
        defaultHomeLimit: widget.defaultHomeLimit,
      );
      final nextSettings = SharedHomepageCountSettings(
        homeLimit: _homeLimit,
        showViewAll: _showViewAll,
        extra: current.extra,
      ).toMap();
      final now = DateTime.now().toUtc().toIso8601String();
      final section = HomepageSection(
        id: existingSection?.id ?? '',
        sectionName: existingSection?.sectionName ?? widget.primarySectionName,
        settings: nextSettings,
        isActive: existingSection?.isActive ?? true,
        displayOrder: existingSection?.displayOrder ?? 0,
        createdAt: existingSection?.createdAt ?? now,
        updatedAt: now,
        updatedBy: existingSection?.updatedBy,
        unitId: widget.unitId,
      );
      await repo.saveSectionsMeta([section], unitId: widget.unitId);
      ref.invalidate(homepageSectionsForUnitProvider(widget.unitSlug));
      ref.invalidate(allHomepageSectionsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ إعدادات الظهور في الصفحة الرئيسية'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذر حفظ إعدادات الظهور: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sectionsAsync = ref.watch(
      homepageSectionsForUnitProvider(widget.unitSlug),
    );

    return sectionsAsync.when(
      loading: () => const SharedAdminSurfaceCard(
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text('جاري تحميل إعدادات الظهور في الصفحة الرئيسية...'),
            ),
          ],
        ),
      ),
      error: (e, _) => SharedAdminSurfaceCard(
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFB22222)),
            const SizedBox(width: 10),
            Expanded(child: Text('تعذر تحميل إعدادات الظهور: $e')),
          ],
        ),
      ),
      data: (sections) {
        final section = _resolveSection(sections);
        _hydrateIfNeeded(section);

        return SharedAdminSurfaceCard(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 560;
              final dropdownWidth = compact ? constraints.maxWidth : 240.0;
              final switchWidth = compact ? constraints.maxWidth : 220.0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    maxLines: compact ? 3 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.description,
                    maxLines: compact ? 5 : 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: dropdownWidth,
                        child: DropdownButtonFormField<int>(
                          initialValue: _homeLimit,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'عدد البطاقات في الصفحة الرئيسية',
                          ),
                          items: widget.allowedHomeLimits
                              .map(
                                (limit) => DropdownMenuItem<int>(
                                  value: limit,
                                  child: Text(
                                    '$limit بطاقة',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: _saving
                              ? null
                              : (value) {
                                  setState(
                                    () => _homeLimit =
                                        value ?? widget.defaultHomeLimit,
                                  );
                                },
                        ),
                      ),
                      SizedBox(
                        width: switchWidth,
                        child: SwitchListTile.adaptive(
                          value: _showViewAll,
                          onChanged: _saving
                              ? null
                              : (value) => setState(() => _showViewAll = value),
                          title: const Text(
                            'إظهار زر عرض الكل',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: FilledButton.icon(
                          onPressed: _saving ? null : () => _save(section),
                          icon: _saving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(_saving ? 'جاري الحفظ...' : 'حفظ'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SharedAdminSectionNotice(
                    message:
                        'هذه الإعدادات تطبق على ظهور القسم داخل الصفحة الرئيسية حسب النطاق الحالي (${widget.unitSlug}).',
                    icon: Icons.tune_outlined,
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
