import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:waqf/core/database/pwf_database_owner_surfaces.dart';
import 'package:waqf/core/unit/pwf_unit_slug_registry.dart';
import 'package:waqf/features/platform/home/data/models/pwf_unit_public_sovereign_models.dart';

final pwfUnitPublicProfileBySlugProvider =
    FutureProvider.family<PwfUnitPublicProfile?, String>((ref, slug) async {
  final normalized = PwfUnitSlugRegistry.internalSlugFor(slug);
  if (normalized.isEmpty) return null;
  try {
    final client = Supabase.instance.client;
    final query = PwfDatabaseOwnerSurfaces.fromOwnerSchema(
      client,
      PwfDatabaseOwnerSurfaces.unitPublicSurfaceProfileRuntimeV1,
    );
    final response = await query
        .select()
        .eq('internal_slug', normalized)
        .maybeSingle();
    if (response == null) return null;
    return PwfUnitPublicProfile.fromJson(
      Map<String, dynamic>.from(response as Map),
    );
  } catch (_) {
    return null;
  }
});
