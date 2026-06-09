import 'package:flutter/material.dart';

enum SharedContentPublicationMode { draft, published, scheduled, archived }

extension SharedContentPublicationModeExtension
    on SharedContentPublicationMode {
  String get displayName {
    switch (this) {
      case SharedContentPublicationMode.draft:
        return 'مسودة';
      case SharedContentPublicationMode.published:
        return 'منشور';
      case SharedContentPublicationMode.scheduled:
        return 'مجدول';
      case SharedContentPublicationMode.archived:
        return 'مؤرشف';
    }
  }
}

class SharedContentPublicationFields extends StatelessWidget {
  const SharedContentPublicationFields({
    super.key,
    required this.mode,
    required this.onModeChanged,
    required this.isFeatured,
    required this.onFeaturedChanged,
    required this.isPinned,
    required this.onPinnedChanged,
    required this.sortOrder,
    required this.onSortOrderChanged,
    required this.publishAt,
    required this.onPickPublishAt,
    required this.onClearPublishAt,
    this.modeLabel = 'حالة النشر',
    this.publishAtLabel = 'موعد النشر',
  });

  final SharedContentPublicationMode mode;
  final ValueChanged<SharedContentPublicationMode> onModeChanged;
  final bool isFeatured;
  final ValueChanged<bool> onFeaturedChanged;
  final bool isPinned;
  final ValueChanged<bool> onPinnedChanged;
  final int sortOrder;
  final ValueChanged<int> onSortOrderChanged;
  final DateTime? publishAt;
  final Future<void> Function() onPickPublishAt;
  final VoidCallback onClearPublishAt;
  final String modeLabel;
  final String publishAtLabel;

  @override
  Widget build(BuildContext context) {
    final publishLabel = publishAt == null
        ? '$publishAtLabel (اختياري)'
        : '$publishAtLabel: ${publishAt!.toLocal().toString().substring(0, 16)}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'النشر والإبراز',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<SharedContentPublicationMode>(
                  value: mode,
                  decoration: InputDecoration(labelText: modeLabel),
                  items: SharedContentPublicationMode.values
                      .map(
                        (value) =>
                            DropdownMenuItem<SharedContentPublicationMode>(
                              value: value,
                              child: Text(value.displayName),
                            ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value != null) onModeChanged(value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  initialValue: sortOrder.toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'الترتيب'),
                  onChanged: (value) =>
                      onSortOrderChanged(int.tryParse(value.trim()) ?? 0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              FilterChip(
                selected: isFeatured,
                onSelected: onFeaturedChanged,
                label: const Text('Featured / مميز'),
                avatar: const Icon(Icons.auto_awesome_rounded, size: 18),
              ),
              FilterChip(
                selected: isPinned,
                onSelected: onPinnedChanged,
                label: const Text('Pinned / مثبت'),
                avatar: const Icon(Icons.push_pin_rounded, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPickPublishAt,
                  icon: const Icon(Icons.schedule_rounded),
                  label: Align(
                    alignment: Alignment.centerRight,
                    child: Text(publishLabel, textAlign: TextAlign.right),
                  ),
                ),
              ),
              if (publishAt != null) ...[
                const SizedBox(width: 12),
                IconButton(
                  tooltip: 'مسح موعد النشر',
                  onPressed: onClearPublishAt,
                  icon: const Icon(Icons.clear_rounded),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
