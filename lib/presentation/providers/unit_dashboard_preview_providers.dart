import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/announcement.dart';
import '../../data/models/activity.dart';
import '../../data/models/news_article.dart';
import 'unit_context_provider.dart';
import 'supabase_providers.dart';
import 'unit_announcements_provider.dart';
import 'unit_activities_provider.dart';
import 'unit_news_provider.dart';
import 'package:waqf/core/database/pwf_database_owner_surfaces.dart';

/// A simple parameter object for preview providers.
///
/// We keep it immutable so Riverpod can cache it safely.

String _normalizeScopeSlug(String slug) {
  final s = slug.trim().toLowerCase();
  return s.isEmpty ? 'home' : s;
}

bool _isHomeScope(String slug) => _normalizeScopeSlug(slug) == 'home';

class UnitPreviewParams {
  final String unitSlug;
  final int limit;

  const UnitPreviewParams({required this.unitSlug, this.limit = 3});

  @override
  bool operator ==(Object other) {
    return other is UnitPreviewParams &&
        other.unitSlug == unitSlug &&
        other.limit == limit;
  }

  @override
  int get hashCode => Object.hash(unitSlug, limit);
}

/// Latest active announcements for a given unit.
///
/// Uses repository-side filtering (active + valid_until).
final unitLatestAnnouncementsPreviewProvider =
    FutureProvider.family<List<Announcement>, UnitPreviewParams>((
      ref,
      p,
    ) async {
      final unitId = await ref.watch(unitIdBySlugProvider(p.unitSlug).future);
      final repo = ref.read(announcementRepositoryProvider);
      return repo.getActiveAnnouncementsForUnit(unitId, limit: p.limit);
    });

/// Upcoming activities preview for a given unit.
///
/// Uses repository-side filtering (status=upcoming + start_date>=now) and
/// orders soonest first.
final unitUpcomingActivitiesPreviewProvider =
    FutureProvider.family<List<Activity>, UnitPreviewParams>((ref, p) async {
      final unitId = await ref.watch(unitIdBySlugProvider(p.unitSlug).future);
      final repo = ref.read(unitActivityRepositoryProvider);
      return repo.getUpcomingActivitiesForUnit(unitId, limit: p.limit);
    });

/// Latest published news preview for a given unit.
///
/// Fail-open: if unit scoping isn't available (e.g., missing unit_id) or any
/// error happens, this returns an empty list.
final unitLatestNewsPreviewProvider =
    FutureProvider.family<List<NewsArticle>, UnitPreviewParams>((ref, p) async {
      try {
        final unitId = await ref.watch(unitIdBySlugProvider(p.unitSlug).future);
        final service = ref.read(unitNewsServiceProvider);
        return service.getLatestNewsForUnit(unitId, limit: p.limit);
      } catch (_) {
        return [];
      }
    });

/// Complementary news preview for a given scope.
///
/// - home => latest published items from non-home units/systems
/// - non-home => latest published ministry/home items
final complementaryLatestNewsPreviewProvider =
    FutureProvider.family<List<NewsArticle>, UnitPreviewParams>((ref, p) async {
      try {
        final normalized = _normalizeScopeSlug(p.unitSlug);
        final homeUnitId = await ref.watch(unitIdBySlugProvider('home').future);
        final service = ref.read(unitNewsServiceProvider);

        if (!_isHomeScope(normalized)) {
          final currentUnitId = await ref.watch(
            unitIdBySlugProvider(normalized).future,
          );
          if (currentUnitId == homeUnitId) return [];
          return service.getLatestNewsForUnit(homeUnitId, limit: p.limit);
        }

        final supabase = ref.read(supabaseServiceProvider).client;
        final response = await supabase
            .from(PwfDatabaseOwnerSurfaces.newsArticles)
            .select()
            .eq('status', 'published')
            .neq('unit_id', homeUnitId)
            .order('published_at', ascending: false)
            .limit(p.limit);

        return (response as List<dynamic>)
            .map((json) => NewsArticle.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (_) {
        return [];
      }
    });

/// Complementary announcements preview for a given scope.
///
/// - home => latest active items from non-home units/systems
/// - non-home => latest active ministry/home announcements
final complementaryAnnouncementsPreviewProvider =
    FutureProvider.family<List<Announcement>, UnitPreviewParams>((
      ref,
      p,
    ) async {
      try {
        final normalized = _normalizeScopeSlug(p.unitSlug);
        final homeUnitId = await ref.watch(unitIdBySlugProvider('home').future);
        final repo = ref.read(announcementRepositoryProvider);

        if (!_isHomeScope(normalized)) {
          final currentUnitId = await ref.watch(
            unitIdBySlugProvider(normalized).future,
          );
          if (currentUnitId == homeUnitId) return [];
          return repo.getActiveAnnouncementsForUnit(homeUnitId, limit: p.limit);
        }

        final supabase = ref.read(supabaseServiceProvider).client;
        final response = await supabase
            .from(PwfDatabaseOwnerSurfaces.announcements)
            .select()
            .eq('is_active', true)
            .neq('unit_id', homeUnitId)
            .order('created_at', ascending: false)
            .limit(p.limit);

        final now = DateTime.now();
        return (response as List<dynamic>)
            .map((json) => Announcement.fromDb(json as Map<String, dynamic>))
            .where((announcement) {
              if (announcement.validUntil == null) return true;
              final validUntil = announcement.validUntil!;
              return validUntil.isAfter(
                DateTime(
                  now.year,
                  now.month,
                  now.day,
                ).subtract(const Duration(microseconds: 1)),
              );
            })
            .toList();
      } catch (_) {
        return [];
      }
    });

/// Complementary upcoming activities preview for a given scope.
///
/// - home => upcoming items from non-home units/systems
/// - non-home => upcoming ministry/home items
final complementaryUpcomingActivitiesPreviewProvider =
    FutureProvider.family<List<Activity>, UnitPreviewParams>((ref, p) async {
      try {
        final normalized = _normalizeScopeSlug(p.unitSlug);
        final homeUnitId = await ref.watch(unitIdBySlugProvider('home').future);
        final repo = ref.read(unitActivityRepositoryProvider);

        if (!_isHomeScope(normalized)) {
          final currentUnitId = await ref.watch(
            unitIdBySlugProvider(normalized).future,
          );
          if (currentUnitId == homeUnitId) return [];
          return repo.getUpcomingActivitiesForUnit(homeUnitId, limit: p.limit);
        }

        final supabase = ref.read(supabaseServiceProvider).client;
        final today = DateTime.now();
        final todayIsoDate =
            '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
        final response = await supabase
            .from(PwfDatabaseOwnerSurfaces.activities)
            .select()
            .neq('unit_id', homeUnitId)
            .eq('status', 'upcoming')
            .gte('start_date', todayIsoDate)
            .order('start_date', ascending: true)
            .limit(p.limit);

        return (response as List<dynamic>)
            .map((json) => Activity.fromDb(json as Map<String, dynamic>))
            .toList();
      } catch (_) {
        return [];
      }
    });
