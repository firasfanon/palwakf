import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/pwf_technical_services_operations_repository_extension.dart';
import 'pwf_technical_services_providers.dart';

extension PwfTechnicalServicesOperationsController on PwfTechnicalServicesController {
  Future<void> addEvidenceAndRefresh(
    WidgetRef ref, {
    required String requestId,
    required String evidenceType,
    required String title,
    String? description,
    String? url,
    String? checksum,
    Map<String, dynamic> payload = const {},
  }) async {
    final repository = ref.read(pwfTechnicalServicesRepositoryProvider);
    await repository.addEvidence(
      requestId: requestId,
      evidenceType: evidenceType,
      title: title,
      description: description,
      url: url,
      checksum: checksum,
      payload: payload,
    );
    await refresh();
  }

  Future<void> recordDecisionAndRefresh(
    WidgetRef ref, {
    required String requestId,
    required String decisionType,
    required String decisionLabel,
    String? decisionReason,
    Map<String, dynamic> payload = const {},
  }) async {
    final repository = ref.read(pwfTechnicalServicesRepositoryProvider);
    await repository.recordDecision(
      requestId: requestId,
      decisionType: decisionType,
      decisionLabel: decisionLabel,
      decisionReason: decisionReason,
      payload: payload,
    );
    await refresh();
  }

  Future<void> markNotificationReadAndRefresh(
    WidgetRef ref,
    String notificationId,
  ) async {
    final repository = ref.read(pwfTechnicalServicesRepositoryProvider);
    await repository.markNotificationRead(notificationId);
    await refresh();
  }
}
