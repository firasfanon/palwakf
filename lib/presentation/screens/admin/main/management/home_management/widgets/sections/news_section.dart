import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqf/data/models/homepage_section.dart';
import 'package:waqf/presentation/providers/homepage_settings_provider.dart';
import 'package:waqf/presentation/screens/admin/main/management/home_management/widgets/common/section_header.dart';


class NewsSection extends ConsumerStatefulWidget {
  const NewsSection({super.key});

  @override
  ConsumerState<NewsSection> createState() => _NewsSectionState();
}

class _NewsSectionState extends ConsumerState<NewsSection> {
  int _showCount = 3;
  bool _showCategories = true;
  bool _showDates = true;
  bool _autoRefresh = true;
  String _layout = 'grid';
  bool _hydrated = false;

  void _hydrateIfNeeded(NewsSectionState state) {
    if (_hydrated || state.settings == null) return;
    final s = state.settings!;
    _showCount = s.showCount;
    _showCategories = s.showCategories;
    _showDates = s.showDates;
    _autoRefresh = s.autoRefresh;
    _layout = s.layout;
    _hydrated = true;
  }

  void _pushChanges() {
    final current = ref.read(newsSectionNotifierProvider).settings;
    if (current == null) return;

    ref.read(newsSectionNotifierProvider.notifier).updateSettings(
      NewsSectionSettings(
        showCount: _showCount,
        showCategories: _showCategories,
        showViewCounts: current.showViewCounts,
        showDates: _showDates,
        layout: _layout,
        autoRefresh: _autoRefresh,
        refreshInterval: current.refreshInterval,
        showExcerpts: current.showExcerpts,
        showAuthors: current.showAuthors,
        showImages: current.showImages,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newsSectionNotifierProvider);
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
          colors: [
            Colors.orange.withValues(alpha:0.05),
            Colors.orange.withValues(alpha:0.02)
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha:0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.article,
            title: 'إعدادات قسم الأخبار',
            color: Colors.orange,
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
                      'عدد الأخبار المعروضة',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
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
                      items: [1, 2, 3, 4, 5, 6]
                          .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text('$c أخبار'),
                      ))
                          .toList(),
                      onChanged: (v) {
                        setState(() => _showCount = v ?? 3);
                        _pushChanges();
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'تخطيط العرض',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
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
                        DropdownMenuItem(value: 'grid', child: Text('شبكة')),
                        DropdownMenuItem(value: 'list', child: Text('قائمة')),
                        DropdownMenuItem(
                            value: 'carousel', child: Text('عرض متحرك')),
                      ],
                      onChanged: (v) {
                        setState(() => _layout = v ?? 'grid');
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
                      title: const Text('عرض الفئات'),
                      value: _showCategories,
                      onChanged: (v) {
                        setState(() => _showCategories = v ?? true);
                        _pushChanges();
                      },
                      activeColor: Colors.orange,
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      title: const Text('عرض التواريخ'),
                      value: _showDates,
                      onChanged: (v) {
                        setState(() => _showDates = v ?? true);
                        _pushChanges();
                      },
                      activeColor: Colors.orange,
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      title: const Text('تحديث تلقائي'),
                      value: _autoRefresh,
                      onChanged: (v) {
                        setState(() => _autoRefresh = v ?? true);
                        _pushChanges();
                      },
                      activeColor: Colors.orange,
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