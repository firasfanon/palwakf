// lib/presentation/screens/admin/home_management/widgets/sections/breaking_news_section.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqf/core/constants/app_constants.dart';
import 'package:waqf/data/models/homepage_section.dart';
import 'package:waqf/presentation/providers/homepage_settings_provider.dart';
import '../common/section_header.dart';
import '../common/settings_text_field.dart';

class BreakingNewsSection extends ConsumerStatefulWidget {
  const BreakingNewsSection({super.key});

  @override
  ConsumerState<BreakingNewsSection> createState() =>
      _BreakingNewsSectionState();
}

class _BreakingNewsSectionState extends ConsumerState<BreakingNewsSection> {
  bool _enabled = true;
  bool _autoScroll = true;
  int _scrollSpeed = 50;
  int _pauseDuration = 3000;
  bool _showIcon = true;
  String _defaultIcon = 'campaign';
  bool _showSeparator = true;
  String _separatorText = '•';
  bool _allowClick = true;
  bool _showBorder = true;
  int _maxItems = 10;
  bool _hydrated = false;

  void _hydrateIfNeeded(BreakingNewsSectionState state) {
    if (_hydrated || state.settings == null) return;
    final s = state.settings!;
    _enabled = s.enabled;
    _autoScroll = s.autoScroll;
    _scrollSpeed = s.scrollSpeed;
    _pauseDuration = s.pauseDuration;
    _showIcon = s.showIcon;
    _defaultIcon = s.defaultIcon;
    _showSeparator = s.showSeparator;
    _separatorText = s.separatorText;
    _allowClick = s.allowClick;
    _showBorder = s.showBorder;
    _maxItems = s.maxItems;
    _hydrated = true;
  }

  void _pushChanges() {
    final current = ref.read(breakingNewsSectionNotifierProvider).settings;
    if (current == null) return;

    ref.read(breakingNewsSectionNotifierProvider.notifier).updateSettings(
      BreakingNewsSectionSettings(
        enabled: _enabled,
        autoScroll: _autoScroll,
        scrollSpeed: _scrollSpeed,
        pauseDuration: _pauseDuration,
        showIcon: _showIcon,
        defaultIcon: _defaultIcon,
        showSeparator: _showSeparator,
        separatorText: _separatorText,
        allowClick: _allowClick,
        showBorder: _showBorder,
        maxItems: _maxItems,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(breakingNewsSectionNotifierProvider);
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
            Colors.red.withValues(alpha:0.05),
            Colors.red.withValues(alpha:0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha:0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.campaign,
            title: 'إعدادات الأخبار العاجلة',
            color: Colors.red,
          ),
          const SizedBox(height: 32),

          // Quick Settings
          Row(
            children: [
              Expanded(
                child: _buildQuickToggle(
                  label: 'تفعيل القسم',
                  value: _enabled,
                  onChanged: (v) {
                    setState(() => _enabled = v);
                    _pushChanges();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickToggle(
                  label: 'التمرير التلقائي',
                  value: _autoScroll,
                  onChanged: (v) {
                    setState(() => _autoScroll = v);
                    _pushChanges();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickToggle(
                  label: 'عرض الأيقونة',
                  value: _showIcon,
                  onChanged: (v) {
                    setState(() => _showIcon = v);
                    _pushChanges();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Detailed Settings
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildNumberField(
                      label: 'سرعة التمرير (بكسل/ثانية)',
                      value: _scrollSpeed,
                      onChanged: (v) {
                        setState(() => _scrollSpeed = v);
                        _pushChanges();
                      },
                      min: 10,
                      max: 200,
                    ),
                    const SizedBox(height: 20),
                    _buildNumberField(
                      label: 'مدة التوقف (ملي ثانية)',
                      value: _pauseDuration,
                      onChanged: (v) {
                        setState(() => _pauseDuration = v);
                        _pushChanges();
                      },
                      min: 1000,
                      max: 10000,
                      step: 500,
                    ),
                    const SizedBox(height: 20),
                    _buildDropdownField(
                      label: 'أيقونة افتراضية',
                      value: _defaultIcon,
                      items: const [
                        {'value': 'campaign', 'label': 'مكبر صوت'},
                        {'value': 'notifications', 'label': 'جرس'},
                        {'value': 'warning', 'label': 'تحذير'},
                        {'value': 'info', 'label': 'معلومات'},
                        {'value': 'flash', 'label': 'برق'},
                      ],
                      onChanged: (v) {
                        setState(() => _defaultIcon = v);
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
                    _buildTextField(
                      label: 'نص الفاصل',
                      value: _separatorText,
                      onChanged: (v) {
                        setState(() => _separatorText = v);
                        _pushChanges();
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildNumberField(
                      label: 'الحد الأقصى للعناصر',
                      value: _maxItems,
                      onChanged: (v) {
                        setState(() => _maxItems = v);
                        _pushChanges();
                      },
                      min: 1,
                      max: 50,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text('عرض الفاصل'),
                            value: _showSeparator,
                            onChanged: (v) {
                              setState(() => _showSeparator = v ?? true);
                              _pushChanges();
                            },
                            activeColor: Colors.red,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text('السماح بالنقر'),
                            value: _allowClick,
                            onChanged: (v) {
                              setState(() => _allowClick = v ?? true);
                              _pushChanges();
                            },
                            activeColor: Colors.red,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    CheckboxListTile(
                      title: const Text('عرض الحدود'),
                      value: _showBorder,
                      onChanged: (v) {
                        setState(() => _showBorder = v ?? true);
                        _pushChanges();
                      },
                      activeColor: Colors.red,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Management Button
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to breaking news items management screen
                // context.go(AppRouter.adminBreakingNews);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('افتح شاشة إدارة الأخبار العاجلة'),
                    backgroundColor: AppConstants.info,
                  ),
                );
              },
              icon: const Icon(Icons.edit_note, size: 24),
              label: const Text('إدارة الأخبار العاجلة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickToggle({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? Colors.red : Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: value ? Colors.red : Colors.grey[700],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
    int min = 0,
    int max = 100,
    int step = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              onPressed: value > min
                  ? () => onChanged((value - step).clamp(min, max))
                  : null,
              icon: const Icon(Icons.remove_circle_outline),
              color: Colors.red,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  value.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: value < max
                  ? () => onChanged((value + step).clamp(min, max))
                  : null,
              icon: const Icon(Icons.add_circle_outline),
              color: Colors.red,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    final controller = TextEditingController(text: value);
    return SettingsTextField(
      label: label,
      controller: controller,
      hint: value,
      labelColor: Colors.red,
      onChanged: onChanged,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<Map<String, String>> items,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items
                  .map((item) => DropdownMenuItem(
                value: item['value']!,
                child: Text(item['label']!),
              ))
                  .toList(),
              onChanged: (v) => onChanged(v!),
            ),
          ),
        ),
      ],
    );
  }
}
