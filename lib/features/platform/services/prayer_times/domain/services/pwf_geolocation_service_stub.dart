import '../models/pwf_prayer_models.dart';
import 'pwf_geolocation_service.dart';

class _PwfGeolocationServiceStub implements PwfGeolocationService {
  @override
  Future<PwfGeoPoint?> getCurrentPosition() async => null;
}

PwfGeolocationService createPwfGeolocationServiceImpl() =>
    _PwfGeolocationServiceStub();
