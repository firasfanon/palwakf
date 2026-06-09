import 'dart:math' as math;

import '../models/pwf_prayer_models.dart';

class PwfQiblaService {
  // Kaaba
  static const PwfGeoPoint kaaba = PwfGeoPoint(21.4225, 39.8262);

  /// Bearing degrees (0° = North, 90° = East)
  static double bearingDegrees({required PwfGeoPoint from}) {
    final lat1 = _deg2rad(from.lat);
    final lon1 = _deg2rad(from.lng);
    final lat2 = _deg2rad(kaaba.lat);
    final lon2 = _deg2rad(kaaba.lng);

    final dLon = lon2 - lon1;

    final y = math.sin(dLon) * math.cos(lat2);
    final x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    var brng = math.atan2(y, x);
    brng = _rad2deg(brng);
    brng = (brng + 360) % 360;
    return brng;
  }

  static String cardinalLabel(double degrees, {required bool isArabic}) {
    const dirsAr = <String>[
      'شمال',
      'شمال شرقي',
      'شرق',
      'جنوب شرقي',
      'جنوب',
      'جنوب غربي',
      'غرب',
      'شمال غربي',
    ];
    const dirsEn = <String>['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final idx = ((degrees + 22.5) / 45).floor() % 8;
    return isArabic ? dirsAr[idx] : dirsEn[idx];
  }

  static double _deg2rad(double d) => d * math.pi / 180.0;
  static double _rad2deg(double r) => r * 180.0 / math.pi;
}
