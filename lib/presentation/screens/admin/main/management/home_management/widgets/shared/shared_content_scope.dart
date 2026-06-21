import 'package:flutter/material.dart';

class SharedContentScopeOption {
  const SharedContentScopeOption({
    required this.slug,
    required this.label,
    this.unitId,
    this.isHome = false,
  });

  final String slug;
  final String label;
  final String? unitId;
  final bool isHome;
}

List<SharedContentScopeOption> buildSharedContentScopeOptions(
  List<Map<String, dynamic>> units,
) {
  final optionsBySlug = <String, SharedContentScopeOption>{};

  for (final row in units) {
    final slug = (row['slug'] ?? '').toString().trim().toLowerCase();
    if (slug.isEmpty) continue;

    final nameAr = (row['name_ar'] ?? '').toString().trim();
    final code = (row['code'] ?? '').toString().trim();
    final label = nameAr.isNotEmpty
        ? (code.isNotEmpty ? '$nameAr ($code)' : nameAr)
        : slug;

    final isHome = slug == 'home';
    final candidate = SharedContentScopeOption(
      slug: slug,
      label: isHome ? 'الوزارة / الصفحة الرئيسية' : label,
      unitId: row['id']?.toString(),
      isHome: isHome,
    );

    final existing = optionsBySlug[slug];
    if (existing == null) {
      optionsBySlug[slug] = candidate;
      continue;
    }

    final shouldReplace =
        (existing.unitId == null || existing.unitId!.isEmpty) &&
        (candidate.unitId != null && candidate.unitId!.isNotEmpty);
    if (shouldReplace) {
      optionsBySlug[slug] = candidate;
    }
  }

  optionsBySlug.putIfAbsent(
    'home',
    () => const SharedContentScopeOption(
      slug: 'home',
      label: 'الوزارة / الصفحة الرئيسية',
      isHome: true,
    ),
  );

  final options = optionsBySlug.values.toList(growable: false)
    ..sort((a, b) {
      if (a.isHome && !b.isHome) return -1;
      if (!a.isHome && b.isHome) return 1;
      return a.label.compareTo(b.label);
    });

  return options;
}

String sharedContentScopeHint(String slug) {
  final normalized = slug.trim().toLowerCase();
  if (normalized == 'home') {
    return 'نطاق وزارة / PalWakf: هذه الإدخالات تغذي الصفحة الرئيسية والسياق الوزاري.';
  }
  return 'نطاق وحدة حسب slug: هذه الإدخالات تظهر داخل الصفحة الديناميكية لنفس الوحدة.';
}

class SharedContentScopeBadge extends StatelessWidget {
  const SharedContentScopeBadge({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    final isHome = slug.trim().toLowerCase() == 'home';
    final color = isHome ? const Color(0xFF0B3A70) : const Color(0xFF2E7D32);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isHome ? Icons.public : Icons.account_tree_outlined,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            isHome ? 'وزارة / home' : 'وحدة / slug',
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// Limits selectable editorial scopes without injecting a ministry/home fallback.
/// An empty [allowedSlugs] means the caller keeps the legacy all-units selector.
List<SharedContentScopeOption> filterSharedContentScopeOptions(
  List<SharedContentScopeOption> options, {
  Set<String>? allowedSlugs,
}) {
  if (allowedSlugs == null) return options;
  final normalized = allowedSlugs
      .map((value) => value.trim().toLowerCase())
      .where((value) => value.isNotEmpty)
      .toSet();
  return options
      .where((option) => normalized.contains(option.slug.trim().toLowerCase()))
      .toList(growable: false);
}

/// Reusable scoped selector used by both the general and unit-owned editorial
/// workspaces. In locked mode it deliberately exposes the context as read-only.
class SharedContentScopeSelector extends StatelessWidget {
  const SharedContentScopeSelector({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.locked = false,
    this.labelText = 'نطاق الإدارة',
  });

  final List<SharedContentScopeOption> options;
  final String value;
  final ValueChanged<String> onChanged;
  final bool locked;
  final String labelText;

  @override
  Widget build(BuildContext context) {
    final selected = options.firstWhere(
      (option) => option.slug == value,
      orElse: () => options.first,
    );

    if (locked || options.length <= 1) {
      return InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: const Icon(Icons.account_tree_outlined),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selected.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.lock_outline, size: 18),
          ],
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: selected.slug,
      isExpanded: true,
      decoration: InputDecoration(labelText: labelText),
      items: options
          .map(
            (option) => DropdownMenuItem<String>(
              value: option.slug,
              child: Text(
                option.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(growable: false),
      selectedItemBuilder: (context) => options
          .map<Widget>(
            (option) => Align(
              alignment: Alignment.centerRight,
              child: Text(
                option.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(growable: false),
      onChanged: (next) {
        if (next != null && next.isNotEmpty) onChanged(next);
      },
    );
  }
}
