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

  // Public-schema Phase 1 remediation. Runtime reads use the approved
  // compatibility wrapper; admin writes remain on the preserved legacy table
  // until owner-write RPC migration is explicitly approved for this surface.
  static const String _sitePagesReadSurface = 'v_platform_site_pages_compat_v1';
  static const String _sitePagesLegacyWriteTable = 'site_pages';

  Future<PwfSitePage?> getPageBySlugForUnit({
    required String slug,
    required String unitId,
  }) async {
    final normalizedSlug = slug.trim();
    if (!_publicRuntimeCmsLookupsEnabled || normalizedSlug.isEmpty) return null;
    final normalizedUnitId = unitId.trim();
    if (normalizedUnitId.isNotEmpty) {
      final scoped = await _sb
          .from(_sitePagesReadSurface)
          .select('*')
          .eq('slug', normalizedSlug)
          .eq('unit_id', normalizedUnitId)
          .maybeSingle();

      if (scoped != null) {
        return PwfSitePage.fromJson(scoped);
      }
    }

    return getGlobalPageBySlug(slug: slug);
  }

  Future<PwfSitePage?> getGlobalPageBySlug({required String slug}) async {
    final normalizedSlug = slug.trim();
    if (!_publicRuntimeCmsLookupsEnabled || normalizedSlug.isEmpty) return null;
    final global = await _sb
        .from(_sitePagesReadSurface)
        .select('*')
        .eq('slug', normalizedSlug)
        .filter('unit_id', 'is', null)
        .maybeSingle();

    if (global == null) return null;
    return PwfSitePage.fromJson(global);
  }

  Future<PwfSitePage> upsertGlobalPage({
    required String slug,
    required String titleAr,
    required String titleEn,
    required String subtitleAr,
    required String subtitleEn,
    required String bodyAr,
    required String bodyEn,
    required bool isPublished,
  }) async {
    final normalizedSlug = slug.trim();
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final payload = <String, dynamic>{
      'slug': normalizedSlug,
      'unit_id': null,
      'title_ar': titleAr.trim(),
      'title_en': titleEn.trim(),
      'subtitle_ar': subtitleAr.trim(),
      'subtitle_en': subtitleEn.trim(),
      'body_ar': bodyAr.trim(),
      'body_en': bodyEn.trim(),
      'is_published': isPublished,
      'updated_at': nowIso,
    };

    final existing = await _sb
        .from(_sitePagesReadSurface)
        .select('id')
        .eq('slug', normalizedSlug)
        .filter('unit_id', 'is', null)
        .maybeSingle();

    final existingId = (existing?['id'] ?? '').toString().trim();
    final saved = existingId.isEmpty
        ? await _sb
              .from(_sitePagesLegacyWriteTable)
              .insert(payload)
              .select('*')
              .single()
        : await _sb
              .from(_sitePagesLegacyWriteTable)
              .update(payload)
              .eq('id', existingId)
              .select('*')
              .single();

    return PwfSitePage.fromJson(saved);
  }
}
