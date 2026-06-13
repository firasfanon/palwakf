import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/pwf_technical_services_repository.dart';
import '../domain/models/pwf_technical_service_models.dart';

final pwfTechnicalServicesRepositoryProvider =
    Provider<PwfTechnicalServicesRepository>((ref) {
  return const PwfTechnicalServicesRepository();
});

final pwfTechnicalServicesControllerProvider = AsyncNotifierProvider<
    PwfTechnicalServicesController, PwfTechnicalServicesDashboard>(
  PwfTechnicalServicesController.new,
);

class PwfTechnicalServicesController
    extends AsyncNotifier<PwfTechnicalServicesDashboard> {
  PwfTechnicalServicesRepository get _repository =>
      ref.read(pwfTechnicalServicesRepositoryProvider);

  @override
  Future<PwfTechnicalServicesDashboard> build() {
    return _repository.fetchDashboard();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.fetchDashboard);
  }

  Future<void> createServiceRequest({
    required String serviceType,
    required String actionType,
    required String title,
    required String description,
    required String riskLevel,
    DateTime? scheduledFor,
    Map<String, dynamic> payload = const {},
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.createServiceRequest(
        serviceType: serviceType,
        actionType: actionType,
        title: title,
        description: description,
        riskLevel: riskLevel,
        scheduledFor: scheduledFor,
        payload: payload,
      );
      return _repository.fetchDashboard();
    });
  }

  Future<void> createMaintenanceWindow({
    required String title,
    required String messageAr,
    required DateTime startsAt,
    required DateTime endsAt,
    required List<String> affectedSurfaces,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.createMaintenanceWindow(
        title: title,
        messageAr: messageAr,
        startsAt: startsAt,
        endsAt: endsAt,
        affectedSurfaces: affectedSurfaces,
      );
      return _repository.fetchDashboard();
    });
  }

  Future<void> recordRelease({
    required String releaseTag,
    required String gitCommitHash,
    required String deployUrl,
    required String status,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.recordRelease(
        releaseTag: releaseTag,
        gitCommitHash: gitCommitHash,
        deployUrl: deployUrl,
        status: status,
      );
      return _repository.fetchDashboard();
    });
  }

  Future<void> refreshHealthSnapshot() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.refreshHealthSnapshot();
      return _repository.fetchDashboard();
    });
  }
}