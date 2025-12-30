import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqf/presentation/providers/header_settings_provider.dart';
import 'package:waqf/presentation/screens/admin/main/management/home_management/widgets/common/section_header.dart';
import 'package:waqf/presentation/screens/admin/main/management/home_management/widgets/common/settings_text_field.dart';

class HeaderSettingsSection extends ConsumerStatefulWidget {
  const HeaderSettingsSection({super.key});

  @override
  ConsumerState<HeaderSettingsSection> createState() =>
      _HeaderSettingsSectionState();
}

class _HeaderSettingsSectionState extends ConsumerState<HeaderSettingsSection> {
  final _logoController = TextEditingController();
  final _siteNameController = TextEditingController();
  final _siteTaglineController = TextEditingController();
  final _faviconController = TextEditingController();
  final _breakingNewsController = TextEditingController();
  bool _showBreakingNews = true;
  bool _hydrated = false;

  @override
  void dispose() {
    _logoController.dispose();
    _siteNameController.dispose();
    _siteTaglineController.dispose();
    _faviconController.dispose();
    _breakingNewsController.dispose();
    super.dispose();
  }

  void _hydrateIfNeeded(HeaderSettingsState state) {
    if (_hydrated || state.settings == null) return;
    final s = state.settings!;
    _logoController.text = s.logoUrl;
    _siteNameController.text = s.siteName;
    _siteTaglineController.text = s.siteTagline;
    _faviconController.text = s.faviconUrl ?? '';
    _breakingNewsController.text = s.breakingNewsText ?? '';
    _showBreakingNews = s.showBreakingNews;
    _hydrated = true;
  }

  void _pushChanges() {
    final current = ref.read(headerSettingsProvider).settings;
    if (current == null) return;

    ref.read(headerSettingsProvider.notifier).updateSettings(
      current.copyWith(
        logoUrl: _logoController.text,
        siteName: _siteNameController.text,
        siteTagline: _siteTaglineController.text,
        faviconUrl: _faviconController.text.isEmpty
            ? null
            : _faviconController.text,
        showBreakingNews: _showBreakingNews,
        breakingNewsText: _breakingNewsController.text.isEmpty
            ? null
            : _breakingNewsController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(headerSettingsProvider);
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
            Colors.blue.withValues(alpha:0.05),
            Colors.blue.withValues(alpha:0.02)
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withValues(alpha:0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.web,
            title: 'إعدادات قسم الهيدر',
            color: Colors.blue,
          ),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    SettingsTextField(
                      label: 'رابط الشعار',
                      controller: _logoController,
                      hint: 'https://example.com/logo.png',
                      labelColor: Colors.blue,
                      onChanged: (_) => _pushChanges(),
                    ),
                    const SizedBox(height: 20),
                    SettingsTextField(
                      label: 'اسم الموقع',
                      controller: _siteNameController,
                      hint: 'وزارة الأوقاف والشؤون الدينية',
                      labelColor: Colors.blue,
                      onChanged: (_) => _pushChanges(),
                    ),
                    const SizedBox(height: 20),
                    SettingsTextField(
                      label: 'الشعار الفرعي',
                      controller: _siteTaglineController,
                      hint: 'دولة فلسطين',
                      labelColor: Colors.blue,
                      onChanged: (_) => _pushChanges(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  children: [
                    SettingsTextField(
                      label: 'رابط Favicon',
                      controller: _faviconController,
                      hint: 'https://example.com/favicon.ico',
                      labelColor: Colors.blue,
                      onChanged: (_) => _pushChanges(),
                    ),
                    const SizedBox(height: 20),
                    SettingsTextField(
                      label: 'نص الأخبار العاجلة',
                      controller: _breakingNewsController,
                      hint: 'أهلاً بكم في الموقع الرسمي',
                      maxLines: 2,
                      labelColor: Colors.blue,
                      onChanged: (_) => _pushChanges(),
                    ),
                    const SizedBox(height: 20),
                    CheckboxListTile(
                      title: const Text('عرض شريط الأخبار العاجلة'),
                      value: _showBreakingNews,
                      onChanged: (v) {
                        setState(() => _showBreakingNews = v ?? true);
                        _pushChanges();
                      },
                      activeColor: Colors.blue,
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