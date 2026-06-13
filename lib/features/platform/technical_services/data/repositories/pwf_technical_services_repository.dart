import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/pwf_technical_service_models.dart';

class PwfTechnicalServicesRepository {
  const PwfTechnicalServicesRepository({SupabaseClient? client})
      : _client = client;

  final SupabaseClient? _client;

  SupabaseClient get _supabase => _client ?? Supabase.instance.client;

  Future<PwfTechnicalServicesDashboard> fetchDashboard() async {
    try {
      final result = await _supabase.rpc('rpc_platform_technical_services_dashboard_v1');
      return PwfTechnicalServicesDashboard.fromJson(result);
    } catch (error) {
      return PwfTechnicalServicesDashboard.fallback(reason: error.toString());
    }
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
    await _supabase.rpc(
      'rpc_platform_technical_service_request_create_v1',
      params: {
        'p_service_type': serviceType,
        'p_action_type': actionType,
        'p_title': title,
        'p_description': description,
        'p_risk_level': riskLevel,
        'p_scheduled_for': scheduledFor?.toUtc().toIso8601String(),
        'p_payload': payload,
      },
    );
  }

  Future<void> createMaintenanceWindow({
    required String title,
    required String messageAr,
    required DateTime startsAt,
    required DateTime endsAt,
    required List<String> affectedSurfaces,
  }) async {
    await _supabase.rpc(
      'rpc_platform_maintenance_window_create_v1',
      params: {
        'p_title': title,
        'p_message_ar': messageAr,
        'p_starts_at': startsAt.toUtc().toIso8601String(),
        'p_ends_at': endsAt.toUtc().toIso8601String(),
        'p_affected_surfaces': affectedSurfaces,
      },
    );
  }

  Future<void> recordRelease({
    required String releaseTag,
    required String gitCommitHash,
    required String deployUrl,
    required String status,
  }) async {
    await _supabase.rpc(
      'rpc_platform_technical_release_record_create_v1',
      params: {
        'p_release_tag': releaseTag,
        'p_git_commit_hash': gitCommitHash,
        'p_deploy_url': deployUrl,
        'p_status': status,
      },
    );
  }

  Future<void> refreshHealthSnapshot() async {
    await _supabase.rpc('rpc_platform_technical_health_snapshot_refresh_v1');
  }
}