import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/pwf_zakat_official_config_contract.dart';
import 'package:waqf/core/database/pwf_database_owner_surfaces.dart';

class PwfZakatPublicConfigRepository {
  const PwfZakatPublicConfigRepository(this._client);

  final SupabaseClient _client;

  Future<PwfZakatPublicConfig> fetchActiveConfig() async {
    try {
      final rows = await _client
          .from(PwfDatabaseOwnerSurfaces.vZakatPublicConfigV1)
          .select()
          .limit(1);

      if (rows.isNotEmpty) {
        final row = Map<String, dynamic>.from(rows.first as Map);
        return PwfZakatPublicConfig.fromJson(row);
      }
    } catch (_) {
      // The official zakat-schema-backed wrapper may not be applied yet in a local/staging
      // environment. Keep the page functional while preserving the visible
      // certification guard.
    }

    return PwfZakatOfficialConfigContract.fallbackConfig();
  }
}
