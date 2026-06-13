import 'package:supabase_flutter/supabase_flutter.dart';

import 'pwf_technical_services_repository.dart';

extension PwfTechnicalServicesOperationsRepository on PwfTechnicalServicesRepository {
  SupabaseClient get _client => Supabase.instance.client;

  Future<void> addEvidence({
    required String requestId,
    required String evidenceType,
    required String title,
    String? description,
    String? url,
    String? checksum,
    Map<String, dynamic> payload = const {},
  }) async {
    await _client.rpc('rpc_platform_technical_evidence_add_v1', params: {
      'p_request_id': requestId,
      'p_evidence_type': evidenceType,
      'p_title': title,
      'p_description': description,
      'p_url': url,
      'p_checksum': checksum,
      'p_payload': payload,
    });
  }

  Future<void> recordDecision({
    required String requestId,
    required String decisionType,
    required String decisionLabel,
    String? decisionReason,
    Map<String, dynamic> payload = const {},
  }) async {
    await _client.rpc('rpc_platform_technical_operation_decision_record_v1', params: {
      'p_request_id': requestId,
      'p_decision_type': decisionType,
      'p_decision_label': decisionLabel,
      'p_decision_reason': decisionReason,
      'p_payload': payload,
    });
  }

  Future<void> markNotificationRead(String notificationId) async {
    await _client.rpc('rpc_platform_technical_notification_mark_read_v1', params: {
      'p_notification_id': notificationId,
    });
  }
}
