import 'package:flutter/material.dart';
import '../theme/palwakf_sis_breakpoints.dart';

class PwfUnifiedSearchBar extends StatelessWidget {
  const PwfUnifiedSearchBar({
    super.key,
    this.hintText = 'بحث...',
    this.onChanged,
    this.onSubmitted,
    this.controller,
    this.filters = const [],
    this.selectedFilters = const {},
    this.onFilterToggled,
    this.trailing,
  });

  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextEditingController? controller;
  final List<PwfFilterOption> filters;
  final Set<String> selectedFilters;
  final ValueChanged<String>? onFilterToggled;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final device = PalWakfSisBreakpoints.of(context);
    final isMobile = device == PalWakfSisDeviceClass.mobile;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Icon(Icons.search, color: const Color(0xFF9CA3AF), size: isMobile ? 20 : 22),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontFamily: 'NotoSansArabic',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    hintStyle: const TextStyle(
                      fontFamily: 'NotoSansArabic',
                      fontSize: 14,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
              const SizedBox(width: 14),
            ],
          ),
        ),
        if (filters.isNotEmpty) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              reverse: true,
              itemCount: filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final filter = filters[i];
                final selected = selectedFilters.contains(filter.key);
                return _PwfFilterChip(
                  label: filter.label,
                  icon: filter.icon,
                  selected: selected,
                  accentColor: scheme.primary,
                  onTap: () => onFilterToggled?.call(filter.key),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class PwfFilterOption {
  const PwfFilterOption({
    required this.key,
    required this.label,
    this.icon,
  });

  final String key;
  final String label;
  final IconData? icon;
}

class _PwfFilterChip extends StatelessWidget {
  const _PwfFilterChip({
    required this.label,
    required this.selected,
    required this.accentColor,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? accentColor : Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? accentColor : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: selected ? Colors.white : const Color(0xFF6B7280)),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'NotoSansArabic',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : const Color(0xFF374151),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
