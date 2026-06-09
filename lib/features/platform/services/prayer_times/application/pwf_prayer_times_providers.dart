import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/repositories/pwf_prayer_times_repository.dart';
import '../data/repositories/pwf_supabase_prayer_times_repository.dart';
import '../domain/services/pwf_geolocation_service.dart';
import 'pwf_prayer_times_controller.dart';

final pwfPrayerTimesRepositoryProvider = Provider<PwfPrayerTimesRepository>((
  ref,
) {
  return PwfSupabasePrayerTimesRepository(Supabase.instance.client);
});

final pwfGeolocationServiceProvider = Provider<PwfGeolocationService>((ref) {
  return createPwfGeolocationService();
});

final pwfPrayerTimesControllerProvider =
    StateNotifierProvider<PwfPrayerTimesController, PwfPrayerTimesViewState>((
      ref,
    ) {
      final repo = ref.watch(pwfPrayerTimesRepositoryProvider);
      final geo = ref.watch(pwfGeolocationServiceProvider);
      final client = Supabase.instance.client;
      return PwfPrayerTimesController(repo, geo, client);
    });
