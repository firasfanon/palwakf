import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqf/data/models/homepage_section.dart';
import 'package:waqf/presentation/providers/homepage_settings_provider.dart';
import 'package:waqf/presentation/screens/admin/main/management/home_management/widgets/common/section_header.dart';


class AnnouncementsSection extends ConsumerStatefulWidget {
  const AnnouncementsSection({super.key});

  @override
  ConsumerState<AnnouncementsSection> createState() =>
      _AnnouncementsSectionState();
}

class _AnnouncementsSectionState extends ConsumerState<AnnouncementsSection> {
  int _showCount = 4;
  bool _showPriorities = true;
  bool _highlightUrgent = true;
  String _layout = 'cards';
  bool _hydrated = false;

  void _hydrateIfNeeded(AnnouncementsSectionState state) {
    if (_hydrated || state.settings == null) return;
    final s = state.settings!;
    _showCount = s.showCount;
    _showPriorities = s.showPriorities;
    _highlightUrgent = s.highlightUrgent;
    _layout = s.layout;
    _hydrated = true;
  }

  void _pushChanges() {
    ref.read(announcementsSectionNotifierProvider.notifier).updateSettings(
      AnnouncementsSectionSettings(
        showCount: _showCount,
        showPriorities: _showPriorities,
        showExpiry: true,
        highlightUrgent: _highlightUrgent,
        layout: _layout,
        showIcons: true,
        showDates: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(announcementsSectionNotifierProvider);
    _hydrateIfNeeded(state);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Text(
          'خطأ: ${state.error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.withValues(alpha:0.05), Colors.red.withValues(alpha:0.02)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha:0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.campaign,
            title: 'إعدادات قسم الإعلانات',
            color: Colors.red,
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'عدد الإعلانات المعروضة',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      initialValue: _showCount,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: [2, 3, 4, 5, 6, 8]
                          .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text('$c إعلانات'),
                      ))
                          .toList(),
                      onChanged: (v) {
                        setState(() => _showCount = v ?? 4);
                        _pushChanges();
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'تخطيط العرض',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _layout,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'cards', child: Text('بطاقات')),
                        DropdownMenuItem(value: 'list', child: Text('قائمة')),
                        DropdownMenuItem(
                            value: 'ticker', child: Text('شريط متحرك')),
                      ],
                      onChanged: (v) {
                        setState(() => _layout = v ?? 'cards');
                        _pushChanges();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  children: [
                    CheckboxListTile(
                      title: const Text('عرض الأولويات'),
                      value: _showPriorities,
                      onChanged: (v) {
                        setState(() => _showPriorities = v ?? true);
                        _pushChanges();
                      },
                      activeColor: Colors.red,
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      title: const Text('تمييز الإعلانات العاجلة'),
                      value: _highlightUrgent,
                      onChanged: (v) {
                        setState(() => _highlightUrgent = v ?? true);
                        _pushChanges();
                      },
                      activeColor: Colors.red,
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      title: const Text('عرض الأيقونات'),
                      value: true,
                      onChanged: (_) => _pushChanges(),
                      activeColor: Colors.red,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}