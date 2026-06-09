import '../models/pwf_prayer_models.dart';
import 'pwf_geolocation_service_stub.dart'
    if (dart.library.html) 'pwf_geolocation_service_web.dart';

abstract class PwfGeolocationService {
  Future<PwfGeoPoint?> getCurrentPosition();
}

PwfGeolocationService createPwfGeolocationService() =>
    createPwfGeolocationServiceImpl();
