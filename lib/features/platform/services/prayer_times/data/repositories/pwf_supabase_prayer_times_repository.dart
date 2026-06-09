import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/pwf_prayer_models.dart';
import 'pwf_prayer_times_repository.dart';
import 'package:waqf/core/database/pwf_database_owner_surfaces.dart';

class PwfSupabasePrayerTimesRepository implements PwfPrayerTimesRepository {
  final SupabaseClient _client;

  PwfSupabasePrayerTimesRepository(this._client);

  @override
  Future<List<PwfPrayerCity>> listCities({bool activeOnly = true}) async {
    final q = _client.from(PwfDatabaseOwnerSurfaces.corePrayerCities).select();
    final rows = activeOnly
        ? await q.eq('is_active', true).order('name_ar')
        : await q.order('name_ar');
    return (rows as List)
        .map((e) => PwfPrayerCity.fromMap(Map<String, dynamic>.from(e)))
        .toList(growable: false);
  }

  @override
  Future<List<PwfPrayerCalcMethod>> listMethods({
    bool activeOnly = true,
  }) async {
    final q = _client
        .from(PwfDatabaseOwnerSurfaces.corePrayerCalcMethods)
        .select();
    final rows = activeOnly
        ? await q.eq('is_active', true).order('code')
        : await q.order('code');
    return (rows as List)
        .map((e) => PwfPrayerCalcMethod.fromMap(Map<String, dynamic>.from(e)))
        .toList(growable: false);
  }

  @override
  Future<PwfPrayerTimesDay> getPrayerTimes({
    required String cityId,
    required DateTime day,
    required String methodCode,
  }) async {
    final dateStr = _dateOnly(day);
    final row = await _client
        .from(PwfDatabaseOwnerSurfaces.corePrayerTimesDaily)
        .select('fajr,sunrise,dhuhr,asr,maghrib,isha,day')
        .eq('city_id', cityId)
        .eq('day', dateStr)
        .eq('method_code', methodCode)
        .maybeSingle();

    if (row == null) {
      throw StateError(
        'No prayer times for $dateStr (city=$cityId, method=$methodCode)',
      );
    }

    final d = DateTime.parse((row['day'] ?? dateStr).toString());
    return PwfPrayerTimesDay.fromMap(day: d, m: Map<String, dynamic>.from(row));
  }

  @override
  Future<List<PwfPrayerTimesDay>> getPrayerTimesRange({
    required String cityId,
    required DateTime fromDay,
    required DateTime toDay,
    required String methodCode,
  }) async {
    final fromStr = _dateOnly(fromDay);
    final toStr = _dateOnly(toDay);
    final rows = await _client
        .from(PwfDatabaseOwnerSurfaces.corePrayerTimesDaily)
        .select('fajr,sunrise,dhuhr,asr,maghrib,isha,day')
        .eq('city_id', cityId)
        .eq('method_code', methodCode)
        .gte('day', fromStr)
        .lte('day', toStr)
        .order('day');

    return (rows as List)
        .map((e) {
          final m = Map<String, dynamic>.from(e);
          final d = DateTime.parse(m['day'].toString());
          return PwfPrayerTimesDay.fromMap(day: d, m: m);
        })
        .toList(growable: false);
  }

  @override
  Future<PwfUserPrayerSettings?> getMySettings() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;

    final row = await _client
        .from(PwfDatabaseOwnerSurfaces.coreUserPrayerSettings)
        .select(
          'user_id,city_id,method_code,notifications_enabled,remind_before_minutes,tz',
        )
        .eq('user_id', uid)
        .maybeSingle();

    if (row == null) return null;
    return PwfUserPrayerSettings.fromMap(Map<String, dynamic>.from(row));
  }

  @override
  Future<void> upsertMySettings({
    required String userId,
    String? cityId,
    String? methodCode,
    bool? notificationsEnabled,
    int? remindBeforeMinutes,
    String? tz,
  }) async {
    final payload = <String, dynamic>{
      'user_id': userId,
      if (cityId != null) 'city_id': cityId,
      if (methodCode != null) 'method_code': methodCode,
      if (notificationsEnabled != null)
        'notifications_enabled': notificationsEnabled,
      if (remindBeforeMinutes != null)
        'remind_before_minutes': remindBeforeMinutes,
      if (tz != null) 'tz': tz,
    };

    await _client
        .from(PwfDatabaseOwnerSurfaces.coreUserPrayerSettings)
        .upsert(payload);
  }

  String _dateOnly(DateTime d) {
    final x = DateTime(d.year, d.month, d.day);
    final mm = x.month.toString().padLeft(2, '0');
    final dd = x.day.toString().padLeft(2, '0');
    return '${x.year}-$mm-$dd';
  }
}
