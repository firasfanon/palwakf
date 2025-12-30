import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqf/data/models/homepage_section.dart';
import 'package:waqf/presentation/providers/homepage_settings_provider.dart';
import '../common/section_header.dart';

class StatisticsSection extends ConsumerStatefulWidget {
  const StatisticsSection({super.key});

  @override
  ConsumerState<StatisticsSection> createState() =>
      _StatisticsSectionState();
}

class _StatisticsSectionState extends ConsumerState<StatisticsSection> {
  bool _showAnimated = true;
  bool _showTargets = true;
  bool _showProgress = true;
  String _layout = 'grid';
  bool _hydrated = false;

  void _hydrateIfNeeded(StatisticsSectionState state) {
    if (_hydrated || state.settings == null) return;
    final s = state.settings!;
    _showAnimated = s.showAnimatedCounters;
    _showTargets = s.showTargets;
    _showProgress = s.showProgress;
    _layout = s.layout;
    _hydrated = true;
  }

  void _pushChanges() {
    final current = ref.read(statisticsSectionNotifierProvider).settings;
    if (current == null) return;

    ref.read(statisticsSectionNotifierProvider.notifier).updateSettings(
      StatisticsSectionSettings(
        showAnimatedCounters: _showAnimated,
        animationDuration: current.animationDuration,
        counters: current.counters,
        showTargets: _showTargets,
        showProgress: _showProgress,
        layout: _layout,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(statisticsSectionNotifierProvider);
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
            Colors.green.withValues(alpha:0.05),
            Colors.green.withValues(alpha:0.02)
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha:0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.bar_chart,
            title: 'إعدادات الإحصائيات',
            color: Colors.green,
          ),
          const SizedBox(height: 24),
          Wrap(
            runSpacing: 12,
            spacing: 12,
            children: [
              FilterChip(
                label: const Text('عدادات متحركة'),
                selected: _showAnimated,
                onSelected: (v) {
                  setState(() => _showAnimated = v);
                  _pushChanges();
                },
                selectedColor: Colors.green.withValues(alpha:0.2),
                checkmarkColor: Colors.green,
              ),
              FilterChip(
                label: const Text('عرض الأهداف'),
                selected: _showTargets,
                onSelected: (v) {
                  setState(() => _showTargets = v);
                  _pushChanges();
                },
                selectedColor: Colors.green.withValues(alpha:0.2),
                checkmarkColor: Colors.green,
              ),
              FilterChip(
                label: const Text('عرض شريط التقدم'),
                selected: _showProgress,
                onSelected: (v) {
                  setState(() => _showProgress = v);
                  _pushChanges();
                },
                selectedColor: Colors.green.withValues(alpha:0.2),
                checkmarkColor: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _layout,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelText: 'تخطيط العرض',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'grid', child: Text('شبكة')),
                    DropdownMenuItem(value: 'row', child: Text('صف')),
                  ],
                  onChanged: (v) {
                    setState(() => _layout = v ?? 'grid');
                    _pushChanges();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}