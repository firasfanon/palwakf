import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/pwf_site_page.dart';

/// Simple CMS repository for public pages.
///
/// Fail-open policy:
/// - If the table/column doesn't exist (older DB schema), repository throws and
///   callers should fallback to local content (no crash).
/// - If unit_id scoped row isn't found, it falls back to global page (unit_id IS NULL).
class PwfSitePagesRepository {
  const PwfSitePagesRepository();

  SupabaseClient get _sb => Supabase.instance.client;

  // Public runtime pages have complete local/compatibility fallbacks.
  // Disabling optional CMS lookups prevents red Console noise when the legacy
  // `site_pages` table or connection is unavailable during public UAT.
  static const bool _publicRuntimeCmsLookupsEnabled = false;

  Future<PwfSitePage?> getPageBySlugForUnit({
    required String slug,
    required String unitId,
  }) async {
    final normalizedSlug = slug.trim();
    if (!_publicRuntimeCmsLookupsEnabled || normalizedSlug.isEmpty) return null;
    // 1) Try unit-scoped page.
    final scoped = await _sb
        .from('site_pages')
        .select('*')
        .eq('slug', normalizedSlug)
        .eq('unit_id', unitId)
        .maybeSingle();

    if (scoped != null) {
      return PwfSitePage.fromJson(scoped);
    }

    // 2) Fallback to global page (unit_id IS NULL).
    final global = await _sb
        .from('site_pages')
        .select('*')
        .eq('slug', normalizedSlug)
        .filter('unit_id', 'is', null)
        .maybeSingle();

    if (global == null) return null;
    return PwfSitePage.fromJson(global);
  }
}
