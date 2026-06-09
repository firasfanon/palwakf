import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/repositories/pwf_prayer_times_repository.dart';
import '../domain/models/pwf_prayer_models.dart';
import '../domain/services/pwf_geolocation_service.dart';
import '../domain/services/pwf_qibla_service.dart';

class PwfPrayerTimesViewState {
  final AsyncValue<List<PwfPrayerCity>> citiesAsync;
  final AsyncValue<List<PwfPrayerCalcMethod>> methodsAsync;
  final PwfPrayerCity? city;
  final PwfPrayerCalcMethod? method;

  final DateTime date;
  final AsyncValue<PwfPrayerTimesDay> times;

  final bool notificationsEnabled;
  final int remindBeforeMinutes;
  final DateTime focusedMonth;

  final double qiblaBearingDeg;
  final PwfGeoPoint? lastKnownPosition;

  const PwfPrayerTimesViewState({
    required this.citiesAsync,
    required this.methodsAsync,
    required this.city,
    required this.method,
    required this.date,
    required this.times,
    required this.notificationsEnabled,
    required this.remindBeforeMinutes,
    required this.focusedMonth,
    required this.qiblaBearingDeg,
    required this.lastKnownPosition,
  });

  PwfPrayerTimesViewState copyWith({
    AsyncValue<List<PwfPrayerCity>>? citiesAsync,
    AsyncValue<List<PwfPrayerCalcMethod>>? methodsAsync,
    PwfPrayerCity? city,
    bool citySet = false,
    PwfPrayerCalcMethod? method,
    bool methodSet = false,
    DateTime? date,
    AsyncValue<PwfPrayerTimesDay>? times,
    bool? notificationsEnabled,
    int? remindBeforeMinutes,
    DateTime? focusedMonth,
    double? qiblaBearingDeg,
    PwfGeoPoint? lastKnownPosition,
  }) {
    return PwfPrayerTimesViewState(
      citiesAsync: citiesAsync ?? this.citiesAsync,
      methodsAsync: methodsAsync ?? this.methodsAsync,
      city: citySet ? city : this.city,
      method: methodSet ? method : this.method,
      date: date ?? this.date,
      times: times ?? this.times,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      remindBeforeMinutes: remindBeforeMinutes ?? this.remindBeforeMinutes,
      focusedMonth: focusedMonth ?? this.focusedMonth,
      qiblaBearingDeg: qiblaBearingDeg ?? this.qiblaBearingDeg,
      lastKnownPosition: lastKnownPosition ?? this.lastKnownPosition,
    );
  }
}

class PwfPrayerTimesController extends StateNotifier<PwfPrayerTimesViewState> {
  final PwfPrayerTimesRepository _repo;
  final PwfGeolocationService _geo;
  final SupabaseClient _client;

  PwfPrayerTimesController(this._repo, this._geo, this._client)
    : super(
        PwfPrayerTimesViewState(
          citiesAsync: const AsyncValue.loading(),
          methodsAsync: const AsyncValue.loading(),
          city: null,
          method: null,
          date: DateTime.now(),
          times: const AsyncValue.loading(),
          notificationsEnabled: false,
          remindBeforeMinutes: 10,
          focusedMonth: DateTime(DateTime.now().year, DateTime.now().month, 1),
          qiblaBearingDeg: 45, // match HTML initial look
          lastKnownPosition: null,
        ),
      ) {
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.wait([_loadCities(), _loadMethods()]);
    await _applyMySettingsIfAny();
    _recomputeQibla();
    await _loadTimes();
  }

  Future<void> _loadCities() async {
    state = state.copyWith(citiesAsync: const AsyncValue.loading());
    final av = await AsyncValue.guard(() => _repo.listCities(activeOnly: true));
    state = state.copyWith(citiesAsync: av);
  }

  Future<void> _loadMethods() async {
    state = state.copyWith(methodsAsync: const AsyncValue.loading());
    final av = await AsyncValue.guard(
      () => _repo.listMethods(activeOnly: true),
    );
    state = state.copyWith(methodsAsync: av);
  }

  Future<void> _applyMySettingsIfAny() async {
    final settings = await _repo.getMySettings();
    final cities = state.citiesAsync.valueOrNull ?? const <PwfPrayerCity>[];
    final methods =
        state.methodsAsync.valueOrNull ?? const <PwfPrayerCalcMethod>[];

    PwfPrayerCity? selectedCity;
    PwfPrayerCalcMethod? selectedMethod;

    if (settings != null) {
      if (settings.cityId != null) {
        selectedCity = cities
            .where((c) => c.id == settings.cityId)
            .cast<PwfPrayerCity?>()
            .firstWhere((e) => e != null, orElse: () => null);
      }
      if (settings.methodCode != null) {
        selectedMethod = methods
            .where((m) => m.code == settings.methodCode)
            .cast<PwfPrayerCalcMethod?>()
            .firstWhere((e) => e != null, orElse: () => null);
      }
      state = state.copyWith(
        notificationsEnabled: settings.notificationsEnabled,
        remindBeforeMinutes: settings.remindBeforeMinutes,
      );
    }

    selectedCity ??= cities.isNotEmpty ? cities.first : null;
    selectedMethod ??= methods.isNotEmpty ? methods.first : null;

    state = state.copyWith(
      city: selectedCity,
      citySet: true,
      method: selectedMethod,
      methodSet: true,
    );
  }

  Future<void> setCity(PwfPrayerCity city) async {
    state = state.copyWith(city: city, citySet: true);
    _recomputeQibla();
    await _persistMySettings(cityId: city.id);
    await _loadTimes();
  }

  Future<void> setMethod(PwfPrayerCalcMethod method) async {
    state = state.copyWith(method: method, methodSet: true);
    await _persistMySettings(methodCode: method.code);
    await _loadTimes();
  }

  Future<void> setDate(DateTime date) async {
    state = state.copyWith(date: date);
    await _loadTimes();
  }

  Future<void> toggleNotifications() async {
    final next = !state.notificationsEnabled;
    state = state.copyWith(notificationsEnabled: next);
    await _persistMySettings(notificationsEnabled: next);
  }

  void prevMonth() {
    final m = DateTime(
      state.focusedMonth.year,
      state.focusedMonth.month - 1,
      1,
    );
    state = state.copyWith(focusedMonth: m);
  }

  void nextMonth() {
    final m = DateTime(
      state.focusedMonth.year,
      state.focusedMonth.month + 1,
      1,
    );
    state = state.copyWith(focusedMonth: m);
  }

  Future<PwfGeoPoint?> autoDetectLocationAndPickNearestCity() async {
    final pos = await _geo.getCurrentPosition();
    if (pos == null) return null;

    final cities = state.citiesAsync.valueOrNull ?? const <PwfPrayerCity>[];
    if (cities.isEmpty) return pos;

    PwfPrayerCity nearest = cities.first;
    double best = double.infinity;

    for (final c in cities) {
      final d = _haversineKm(pos.lat, pos.lng, c.lat, c.lng);
      if (d < best) {
        best = d;
        nearest = c;
      }
    }

    state = state.copyWith(lastKnownPosition: pos);
    await setCity(nearest);
    return pos;
  }

  Future<void> _loadTimes() async {
    final city = state.city;
    final method = state.method;

    if (city == null || method == null) {
      state = state.copyWith(times: const AsyncValue.loading());
      return;
    }

    state = state.copyWith(times: const AsyncValue.loading());
    final av = await AsyncValue.guard(() {
      return _repo.getPrayerTimes(
        cityId: city.id,
        day: state.date,
        methodCode: method.code,
      );
    });
    state = state.copyWith(times: av);
  }

  void _recomputeQibla() {
    final city = state.city;
    final ref =
        state.lastKnownPosition ??
        (city != null
            ? PwfGeoPoint(city.lat, city.lng)
            : const PwfGeoPoint(31.9038, 35.2034));
    final bearing = PwfQiblaService.bearingDegrees(from: ref);
    state = state.copyWith(qiblaBearingDeg: bearing);
  }

  Future<void> _persistMySettings({
    String? cityId,
    String? methodCode,
    bool? notificationsEnabled,
  }) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return;

    await _repo.upsertMySettings(
      userId: uid,
      cityId: cityId,
      methodCode: methodCode,
      notificationsEnabled: notificationsEnabled,
      remindBeforeMinutes: state.remindBeforeMinutes,
      tz: 'Asia/Hebron',
    );
  }

  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(lat1)) *
            math.cos(_deg2rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  double _deg2rad(double d) => d * math.pi / 180.0;
}
