import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/pwf_technical_services_workflow_repository_extension.dart';
import 'pwf_technical_services_providers.dart';

extension PwfTechnicalServicesWorkflowController on PwfTechnicalServicesController {
  Future<void> transitionRequestAndRefresh(
    WidgetRef ref, {
    required String requestId,
    required String transition,
    String? note,
    Map<String, dynamic> result = const {},
  }) async {
    final repository = ref.read(pwfTechnicalServicesRepositoryProvider);
    await repository.transitionRequest(
      requestId: requestId,
      transition: transition,
      note: note,
      result: result,
    );
    await refresh();
  }
}
