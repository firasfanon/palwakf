import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/announcement.dart';
import '../../data/models/activity.dart';
import '../../data/models/news_article.dart';
import 'unit_context_provider.dart';
import 'unit_announcements_provider.dart';
import 'unit_activities_provider.dart';
import 'unit_news_provider.dart';

/// A simple parameter object for preview providers.
///
/// We keep it immutable so Riverpod can cache it safely.

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
      final unitId = await ref.watch(unitIdBySlugExactProvider(p.unitSlug).future);
      if (unitId == null || unitId.isEmpty) return const <Announcement>[];
      final repo = ref.read(announcementRepositoryProvider);
      return repo.getActiveAnnouncementsForUnit(
        unitId,
        unitSlug: p.unitSlug,
        limit: p.limit,
      );
    });

/// Upcoming activities preview for a given unit.
///
/// Uses repository-side filtering (status=upcoming + start_date>=now) and
/// orders soonest first.
final unitUpcomingActivitiesPreviewProvider =
    FutureProvider.family<List<Activity>, UnitPreviewParams>((ref, p) async {
      final unitId = await ref.watch(unitIdBySlugExactProvider(p.unitSlug).future);
      if (unitId == null || unitId.isEmpty) return const <Activity>[];
      final repo = ref.read(unitActivityRepositoryProvider);
      return repo.getUpcomingActivitiesForUnit(
        unitId,
        unitSlug: p.unitSlug,
        limit: p.limit,
      );
    });

/// Latest published news preview for a given unit.
///
/// Fail-open: if unit scoping isn't available (e.g., missing unit_id) or any
/// error happens, this returns an empty list.
final unitLatestNewsPreviewProvider =
    FutureProvider.family<List<NewsArticle>, UnitPreviewParams>((ref, p) async {
      try {
        final unitId = await ref.watch(unitIdBySlugExactProvider(p.unitSlug).future);
        if (unitId == null || unitId.isEmpty) return const <NewsArticle>[];
        final service = ref.read(unitNewsServiceProvider);
        return service.getLatestNewsForUnit(
          unitId,
          unitSlug: p.unitSlug,
          limit: p.limit,
        );
      } catch (_) {
        return const <NewsArticle>[];
      }
    });

/// Complementary news preview for a given scope.
///
/// Unit public surfaces must not import ministry/home news.
/// Platform 13 owner-runtime cutover: the public home page must not import
/// provincial content as a complementary block, and unit pages must not import
/// ministry/home rows. Cross-scope previews are therefore disabled until a
/// governed owner-schema aggregation surface is approved.
final complementaryLatestNewsPreviewProvider =
    FutureProvider.family<List<NewsArticle>, UnitPreviewParams>((ref, p) async {
      return const <NewsArticle>[];
    });

/// Complementary announcements preview for a given scope.
///
/// Unit public surfaces must not import ministry/home announcements.
/// Disabled for the same owner-runtime separation rule used by news.
final complementaryAnnouncementsPreviewProvider =
    FutureProvider.family<List<Announcement>, UnitPreviewParams>((ref, p) async {
      return const <Announcement>[];
    });

/// Complementary upcoming activities preview for a given scope.
///
/// Unit public surfaces must not import ministry/home activities.
/// Disabled for the same owner-runtime separation rule used by news.
final complementaryUpcomingActivitiesPreviewProvider =
    FutureProvider.family<List<Activity>, UnitPreviewParams>((ref, p) async {
      return const <Activity>[];
    });

