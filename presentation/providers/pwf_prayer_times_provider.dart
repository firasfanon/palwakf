import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/pwf_prayer_times.dart';
import '../../data/services/pwf_prayer_times_service.dart';

/// Family provider: prayer times per Arabic city label.
///
/// Use `ref.refresh(pwfPrayerTimesProvider(cityAr))` when needed.
final pwfPrayerTimesProvider = FutureProvider.family<PwfPrayerTimes?, String>((
  ref,
  cityAr,
) async {
  const service = PwfPrayerTimesService();
  return service.getToday(cityAr: cityAr);
});
