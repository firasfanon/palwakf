import 'package:supabase_flutter/supabase_flutter.dart';

import 'pwf_technical_services_repository.dart';

extension PwfTechnicalServicesWorkflowRepository on PwfTechnicalServicesRepository {
  Future<void> transitionRequest({
    required String requestId,
    required String transition,
    String? note,
    Map<String, dynamic> result = const {},
  }) async {
    await Supabase.instance.client.rpc(
      'rpc_platform_technical_service_request_transition_v1',
      params: {
        'p_request_id': requestId,
        'p_transition': transition,
        'p_note': note,
        'p_result': result,
      },
    );
  }
}
