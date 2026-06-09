import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pwf_accessibility_settings_provider.dart';
import '../../domain/models/pwf_accessibility_settings.dart';

class PwfAccessibilityToolsDialog extends ConsumerWidget {
  const PwfAccessibilityToolsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(pwfAccessibilitySettingsProvider);
    final notifier = ref.read(pwfAccessibilitySettingsProvider.notifier);
    final isAr = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('ar');

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAr ? 'أدوات الوصول' : 'Accessibility tools',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isAr
                    ? 'تم نقل أدوات الوصول إلى طبقة الواجهة العامة بدل صفحة مستقلة. يطبَّق حجم النص فورًا على صفحات المنصة العامة.'
                    : 'Accessibility tools now live in the shared public interface instead of a separate page. Text scaling applies immediately across public pages.',
                style: const TextStyle(color: Color(0xFF6B7280), height: 1.6),
              ),
              const SizedBox(height: 18),
              _Card(
                title: isAr ? 'حجم النص' : 'Text size',
                child: Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: notifier.decreaseFont,
                      icon: const Icon(Icons.remove),
                      label: Text(isAr ? 'تصغير' : 'Smaller'),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isAr
                            ? 'الحجم الحالي: ${settings.fontPx}px'
                            : 'Current size: ${settings.fontPx}px',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton.icon(
                      onPressed: notifier.increaseFont,
                      icon: const Icon(Icons.add),
                      label: Text(isAr ? 'تكبير' : 'Larger'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Card(
                title: isAr ? 'خيارات القراءة' : 'Reading options',
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilterChip(
                      selected: settings.highContrast,
                      label: Text(isAr ? 'تباين مرتفع' : 'High contrast'),
                      onSelected: (_) => notifier.toggleHighContrast(),
                    ),
                    FilterChip(
                      selected: settings.readingMode,
                      label: Text(isAr ? 'وضع القراءة' : 'Reading mode'),
                      onSelected: (_) => notifier.toggleReadingMode(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Card(
                title: isAr ? 'إعدادات جاهزة' : 'Presets',
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _PresetChip(
                      active: settings.preset == PwfAccessibilityPreset.senior,
                      label: isAr ? 'كبار السن' : 'Senior',
                      onTap: () =>
                          notifier.setPreset(PwfAccessibilityPreset.senior),
                    ),
                    _PresetChip(
                      active: settings.preset == PwfAccessibilityPreset.kids,
                      label: isAr ? 'الأطفال' : 'Kids',
                      onTap: () =>
                          notifier.setPreset(PwfAccessibilityPreset.kids),
                    ),
                    _PresetChip(
                      active:
                          settings.preset == PwfAccessibilityPreset.recitation,
                      label: isAr ? 'التلاوة' : 'Recitation',
                      onTap: () =>
                          notifier.setPreset(PwfAccessibilityPreset.recitation),
                    ),
                    _PresetChip(
                      active: settings.preset == PwfAccessibilityPreset.none,
                      label: isAr ? 'إعادة الضبط' : 'Reset',
                      onTap: notifier.reset,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(isAr ? 'إغلاق' : 'Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.active,
    required this.label,
    required this.onTap,
  });

  final bool active;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      backgroundColor: active ? const Color(0xFF0F4C81) : null,
      labelStyle: TextStyle(
        color: active ? Colors.white : null,
        fontWeight: FontWeight.w700,
      ),
      label: Text(label),
      onPressed: onTap,
    );
  }
}
