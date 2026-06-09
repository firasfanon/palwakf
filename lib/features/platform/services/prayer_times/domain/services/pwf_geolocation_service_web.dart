// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import '../models/pwf_prayer_models.dart';
import 'pwf_geolocation_service.dart';

class _PwfGeolocationServiceWeb implements PwfGeolocationService {
  @override
  Future<PwfGeoPoint?> getCurrentPosition() async {
    final geo = html.window.navigator.geolocation;

    try {
      final pos = await geo.getCurrentPosition();
      final c = pos.coords;
      final lat = c?.latitude?.toDouble();
      final lng = c?.longitude?.toDouble();
      if (lat == null || lng == null) return null;
      if (lat == 0.0 && lng == 0.0) return null;
      return PwfGeoPoint(lat, lng);
    } catch (_) {
      return null;
    }
  }
}

PwfGeolocationService createPwfGeolocationServiceImpl() =>
    _PwfGeolocationServiceWeb();
