import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pwf_prayer_times_provider.dart';
import '../theme/pwf_home_tokens.dart';
import 'pwf_hover_card.dart';

class PwfPrayerTimesSection extends ConsumerWidget {
  final String city;

  const PwfPrayerTimesSection({super.key, this.city = 'القدس'});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pwfPrayerTimesProvider(city));
    final data = state.valueOrNull;

    final times = <MapEntry<String, String>>[
      MapEntry('الفجر', data?.fajr ?? '--:--'),
      MapEntry('الشروق', data?.sunrise ?? '--:--'),
      MapEntry('الظهر', data?.dhuhr ?? '--:--'),
      MapEntry('العصر', data?.asr ?? '--:--'),
      MapEntry('المغرب', data?.maghrib ?? '--:--'),
      MapEntry('العشاء', data?.isha ?? '--:--'),
    ];

    final badgeText = data == null
        ? (state.isLoading ? 'جاري التحديث' : 'قيد الربط')
        : 'محدث';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'مواقيت الصلاة',
                style: PwfHomeTokens.sectionTitleText(context),
              ),
            ),
            TextButton.icon(
              onPressed: () => ref.invalidate(pwfPrayerTimesProvider(city)),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('تحديث'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        PwfHoverCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.place, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    city,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const Spacer(),
                  Text(
                    badgeText,
                    style: TextStyle(
                      color: PwfHomeTokens.grayColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final t in times) _TimeChip(label: t.key, time: t.value),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                data == null
                    ? (!state.hasError
                          ? 'سيتم ربط مواقيت الصلاة تلقائيًا عبر API لاحقًا دون تغيير التصميم.'
                          : 'تعذر جلب مواقيت الصلاة حاليًا. يمكنك الضغط على “تحديث”.')
                    : 'تحديث تلقائي لمواقيت الصلاة عبر API (مصدر: ${data.source}).',
                style: TextStyle(color: PwfHomeTokens.grayColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String label;
  final String time;

  const _TimeChip({required this.label, required this.time});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: PwfHomeTokens.backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: PwfHomeTokens.grayColor.withValues(alpha: 0.22),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(width: 10),
            Text(
              time,
              style: TextStyle(
                color: PwfHomeTokens.primaryColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
