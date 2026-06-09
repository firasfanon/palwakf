import '../../domain/models/pwf_prayer_models.dart';

abstract class PwfPrayerTimesRepository {
  Future<List<PwfPrayerCity>> listCities({bool activeOnly = true});
  Future<List<PwfPrayerCalcMethod>> listMethods({bool activeOnly = true});

  Future<PwfPrayerTimesDay> getPrayerTimes({
    required String cityId,
    required DateTime day,
    required String methodCode,
  });

  Future<List<PwfPrayerTimesDay>> getPrayerTimesRange({
    required String cityId,
    required DateTime fromDay,
    required DateTime toDay,
    required String methodCode,
  });

  Future<PwfUserPrayerSettings?> getMySettings();
  Future<void> upsertMySettings({
    required String userId,
    String? cityId,
    String? methodCode,
    bool? notificationsEnabled,
    int? remindBeforeMinutes,
    String? tz,
  });
}
