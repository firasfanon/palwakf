import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqf/data/models/homepage_section.dart';
import 'package:waqf/presentation/providers/homepage_settings_provider.dart';
import 'package:waqf/presentation/screens/admin/main/management/home_management/widgets/common/section_header.dart';
import 'package:waqf/presentation/screens/admin/main/management/home_management/widgets/common/settings_text_field.dart';

class MinisterSection extends ConsumerStatefulWidget {
  const MinisterSection({super.key});

  @override
  ConsumerState<MinisterSection> createState() => _MinisterSectionState();
}

class _MinisterSectionState extends ConsumerState<MinisterSection> {
  final _nameController = TextEditingController();
  final _positionController = TextEditingController();
  final _messageController = TextEditingController();
  final _quoteController = TextEditingController();
  final _imageController = TextEditingController();

  bool _showQuote = true;
  bool _showSignature = true;
  bool _hydrated = false;

  @override
  void dispose() {
    _nameController.dispose();
    _positionController.dispose();
    _messageController.dispose();
    _quoteController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _hydrateIfNeeded(MinisterSectionState state) {
    if (_hydrated || state.settings == null) return;
    final s = state.settings!;
    _nameController.text = s.name;
    _positionController.text = s.position;
    _messageController.text = s.message;
    _quoteController.text = s.quote;
    _imageController.text = s.imageUrl;
    _showQuote = s.showQuote;
    _showSignature = s.showSignature;
    _hydrated = true;
  }

  void _pushChanges() {
    final current = ref.read(ministerSectionNotifierProvider).settings;
    if (current == null) return;

    ref.read(ministerSectionNotifierProvider.notifier).updateSettings(
      MinisterSectionSettings(
        name: _nameController.text,
        position: _positionController.text,
        message: _messageController.text,
        quote: _quoteController.text,
        imageUrl: _imageController.text,
        showQuote: _showQuote,
        showSignature: _showSignature,
        messageLink: current.messageLink,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ministerSectionNotifierProvider);
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
            icon: Icons.person,
            title: 'إعدادات قسم كلمة الوزير',
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
                      label: 'اسم الوزير',
                      controller: _nameController,
                      hint: 'اسم معالي الوزير',
                      labelColor: Colors.blue,
                      onChanged: (_) => _pushChanges(),
                    ),
                    const SizedBox(height: 20),
                    SettingsTextField(
                      label: 'المنصب',
                      controller: _positionController,
                      hint: 'منصب الوزير',
                      labelColor: Colors.blue,
                      onChanged: (_) => _pushChanges(),
                    ),
                    const SizedBox(height: 20),
                    SettingsTextField(
                      label: 'رابط صورة الوزير',
                      controller: _imageController,
                      hint: 'https://example.com/minister.jpg',
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
                      label: 'نص الكلمة',
                      controller: _messageController,
                      hint: 'كلمة معالي الوزير',
                      maxLines: 4,
                      labelColor: Colors.blue,
                      onChanged: (_) => _pushChanges(),
                    ),
                    const SizedBox(height: 20),
                    SettingsTextField(
                      label: 'نص الاقتباس المميز',
                      controller: _quoteController,
                      hint: 'اقتباس مميز من كلمة الوزير',
                      maxLines: 2,
                      labelColor: Colors.blue,
                      onChanged: (_) => _pushChanges(),
                    ),
                    const SizedBox(height: 20),
                    CheckboxListTile(
                      title: const Text('عرض الاقتباس المميز'),
                      value: _showQuote,
                      onChanged: (v) {
                        setState(() => _showQuote = v ?? true);
                        _pushChanges();
                      },
                      activeColor: Colors.blue,
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      title: const Text('عرض التوقيع'),
                      value: _showSignature,
                      onChanged: (v) {
                        setState(() => _showSignature = v ?? true);
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