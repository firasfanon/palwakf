part of '../go_router_config.dart';

RouteBase _buildPublicShellRoute() {
  return ShellRoute(
    builder: (context, state, child) => PublicShell(child: child),
    routes: [
      GoRoute(
        path: AppRoutes.root,
        redirect: (context, state) => AppRoutes.home,
      ),

      // Aliases for legacy /services links (public homepage cards)
      GoRoute(
        path: '/e-services',
        redirect: (context, state) => AppRoutes.eservices,
      ),
      GoRoute(
        path: '/services/prayer-times',
        redirect: (context, state) => AppRoutes.prayerTimes,
      ),
      GoRoute(
        path: '/request-service',
        redirect: (context, state) => AppRoutes.serviceRequestEntry,
      ),
      GoRoute(
        path: '/track-request',
        redirect: (context, state) => AppRoutes.serviceRequestTracking,
      ),
      GoRoute(
        path: '/services/donations',
        redirect: (context, state) => AppRoutes.zakat,
      ),
      GoRoute(
        path: '/donations',
        redirect: (context, state) => AppRoutes.zakat,
      ),
      GoRoute(path: '/donate', redirect: (context, state) => AppRoutes.zakat),

      // Legacy "system" aliases kept after reclassifying these as platform services.
      GoRoute(
        path: AppRoutes.zakatSystem,
        redirect: (context, state) => AppRoutes.zakat,
      ),
      GoRoute(
        path: AppRoutes.prayerTimesSystem,
        redirect: (context, state) => AppRoutes.prayerTimes,
      ),
      GoRoute(
        path: AppRoutes.quranSystem,
        redirect: (context, state) => AppRoutes.quran,
      ),

      GoRoute(
        path: AppRoutes.underConstruction,
        // Use a single implementation so users can always reach the
        // completed pages from the fallback screen.
        builder: (context, state) => const UnderConstructionScreen(),
      ),
      GoRoute(
        path: AppRoutes.news,
        redirect: (context, state) => UnitRoutes.news('home'),
      ),
      GoRoute(
        path: AppRoutes.newsDetail,
        redirect: (context, state) => UnitRoutes.news('home'),
      ),
      GoRoute(
        path: AppRoutes.announcements,
        redirect: (context, state) => UnitRoutes.announcements('home'),
      ),
      GoRoute(
        path: AppRoutes.activities,
        redirect: (context, state) => UnitRoutes.activities('home'),
      ),
      GoRoute(
        path: AppRoutes.events,
        builder: (context, state) =>
            const PwfEventsPublicScreen(unitSlug: 'home'),
      ),
      GoRoute(
        path: '/events/:id',
        builder: (context, state) => PwfPlatformCenterContentDetailScreen(
          unitSlug: 'home',
          familyKey: 'events',
          id: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.services,
        builder: (context, state) => kIsWeb
            ? const PwfServicesWebScreen(unitSlug: 'home')
            : const ServicesScreen(),
      ),
      GoRoute(
        path: AppRoutes.eservices,
        builder: (context, state) => kIsWeb
            ? const PwfEServicesWebScreen(unitSlug: 'home')
            : const EServicesScreen(),
      ),
      GoRoute(
        path: AppRoutes.serviceRequestEntry,
        builder: (context, state) =>
            const PwfPublicRequestEntryScreen(unitSlug: 'home'),
      ),
      GoRoute(
        path: AppRoutes.serviceRequestTracking,
        builder: (context, state) =>
            const PwfPublicRequestTrackingScreen(unitSlug: 'home'),
      ),
      GoRoute(
        path: AppRoutes.socialServices,
        builder: (context, state) => kIsWeb
            ? const PwfSocialServicesWebScreen(unitSlug: 'home')
            : const SocialServicesScreen(),
      ),
      GoRoute(
        path: AppRoutes.mediaCenter,
        builder: (context, state) =>
            const PwfMediaCenterPublicHubScreen(unitSlug: 'home'),
      ),
      GoRoute(
        path: AppRoutes.legalReferences,
        builder: (context, state) =>
            const PwfLegalReferencesPublicScreen(unitSlug: 'home'),
      ),
      GoRoute(
        path: '/legal-references/:id',
        builder: (context, state) => PwfPlatformCenterContentDetailScreen(
          unitSlug: 'home',
          familyKey: 'legal-references',
          id: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.sanctitiesObservatory,
        builder: (context, state) =>
            const PwfSanctitiesObservatoryPublicScreen(unitSlug: 'home'),
      ),
      GoRoute(
        path: '/sanctities-observatory/:id',
        builder: (context, state) => PwfPlatformCenterContentDetailScreen(
          unitSlug: 'home',
          familyKey: 'sanctities-observatory',
          id: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.socialPosts,
        builder: (context, state) => const PwfMediaFamilyPublicScreen(
          unitSlug: 'home',
          familyKey: 'social-posts',
        ),
      ),
      GoRoute(
        path: '/social-posts/:id',
        builder: (context, state) => PwfPlatformCenterContentDetailScreen(
          unitSlug: 'home',
          familyKey: 'social-posts',
          id: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.pressReleases,
        builder: (context, state) => const PwfMediaFamilyPublicScreen(
          unitSlug: 'home',
          familyKey: 'press-releases',
        ),
      ),
      GoRoute(
        path: '/press-releases/:id',
        builder: (context, state) => PwfPlatformCenterContentDetailScreen(
          unitSlug: 'home',
          familyKey: 'press-releases',
          id: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.officialStatements,
        builder: (context, state) => const PwfMediaFamilyPublicScreen(
          unitSlug: 'home',
          familyKey: 'official-statements',
        ),
      ),
      GoRoute(
        path: '/official-statements/:id',
        builder: (context, state) => PwfPlatformCenterContentDetailScreen(
          unitSlug: 'home',
          familyKey: 'official-statements',
          id: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.awarenessCampaigns,
        builder: (context, state) => const PwfMediaFamilyPublicScreen(
          unitSlug: 'home',
          familyKey: 'awareness-campaigns',
        ),
      ),
      GoRoute(
        path: '/awareness-campaigns/:id',
        builder: (context, state) => PwfPlatformCenterContentDetailScreen(
          unitSlug: 'home',
          familyKey: 'awareness-campaigns',
          id: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.mosques,
        builder: (context, state) => kIsWeb
            ? const PwfMosquesAwqafWebScreen(unitSlug: 'home')
            : const MosquesScreen(),
      ),
      GoRoute(
        path: AppRoutes.projects,
        builder: (context, state) => kIsWeb
            ? const PwfProjectsWebScreen(unitSlug: 'home')
            : const ProjectsScreen(),
      ),
      GoRoute(
        path: AppRoutes.about,
        builder: (context, state) => kIsWeb
            ? const PwfAboutWebScreen(unitSlug: 'home')
            : const AboutScreen(),
      ),
      GoRoute(
        path: AppRoutes.minister,
        builder: (context, state) => const MinisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.visionMission,
        builder: (context, state) => kIsWeb
            ? const PwfVisionMissionWebScreen(unitSlug: 'home')
            : const VisionMissionScreen(),
      ),
      GoRoute(
        path: AppRoutes.structure,
        builder: (context, state) => kIsWeb
            ? const PwfOrgStructureWebScreen(unitSlug: 'home')
            : const StructureScreen(),
      ),
      GoRoute(
        path: AppRoutes.formerMinisters,
        builder: (context, state) => kIsWeb
            ? const PwfFormerMinistersWebScreen(unitSlug: 'home')
            : const FormerMinistersScreen(),
      ),
      GoRoute(
        path: AppRoutes.contact,
        builder: (context, state) => kIsWeb
            ? const PwfContactWebScreen(unitSlug: 'home')
            : const ContactScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacy,
        builder: (context, state) =>
            const PwfPrivacyPolicyWebScreen(unitSlug: 'home'),
      ),
      GoRoute(
        path: AppRoutes.terms,
        builder: (context, state) =>
            const PwfTermsOfUseWebScreen(unitSlug: 'home'),
      ),
      GoRoute(
        path: AppRoutes.sitemap,
        builder: (context, state) =>
            const PwfSiteMapWebScreen(unitSlug: 'home'),
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => SearchScreen(
          initialQuery: state.uri.queryParameters['q'] ?? '',
          unitSlug: 'home',
        ),
      ),
      GoRoute(
        path: AppRoutes.fridaySermon,
        builder: (context, state) => const FridaySermonScreen(),
      ),

      // Zakat / Prayer Times / Quran (Public)
      GoRoute(
        path: AppRoutes.zakat,
        builder: (context, state) =>
            const PwfZakatPublicScreen(unitSlug: 'home'),
      ),
      GoRoute(
        path: AppRoutes.prayerTimes,
        builder: (context, state) =>
            const PwfPrayerTimesPublicScreen(unitSlug: 'home'),
      ),
      GoRoute(
        path: AppRoutes.quran,
        builder: (context, state) =>
            const PwfQuranPublicScreen(unitSlug: 'home'),
      ),
      GoRoute(
        path: AppRoutes.chat,
        builder: (context, state) {
          final sid = state.uri.queryParameters['sid'];
          if (kIsWeb) {
            return PwfWebPageScaffold(
              unitSlug: 'home',
              child: PublicChatbotPage(
                unitId: 'home',
                publicSessionId: sid,
                embedInPublicShell: true,
              ),
            );
          }
          return PublicChatbotPage(unitId: 'home', publicSessionId: sid);
        },
      ),

      // Complaints (Public) — use the completed screen (not the placeholder)
      GoRoute(
        path: AppRoutes.complaints,
        builder: (context, state) => const PwfComplaintsScreen(
          unitSlug: 'home',
          embedInPublicShell: true,
        ),
      ),

      // Aliases for old links (keep quick-links/buttons working)
      GoRoute(
        path: '/services/complaints',
        redirect: (context, state) => AppRoutes.complaints,
      ),
      GoRoute(
        path: '/complaints-system',
        redirect: (context, state) => AppRoutes.complaints,
      ),

      GoRoute(
        path: AppRoutes.notFound,
        builder: (context, state) => const NotFoundScreen(),
      ),

      GoRoute(
        path: '/systems/:systemKey',
        builder: (context, state) => PwfDynamicSystemHomePage(
          systemKey: state.pathParameters['systemKey'] ?? '',
        ),
        routes: [
          GoRoute(
            path: 'dashboard',
            redirect: (context, state) => AppRoutes.adminDynamicSystem(
              state.pathParameters['systemKey'] ?? '',
            ),
          ),
        ],
      ),

      // Unit-scoped public routes (/:unitSlug/*)
      GoRoute(
        path: '/:unitSlug',
        redirect: (context, state) {
          final slug =
              PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
          if (UnitPathUtils.isReservedFirstSegment(slug)) {
            return AppRoutes.notFound;
          }
          return null;
        },
        builder: (context, state) {
          final slug =
              PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
          return UnitHomeScreen(unitSlug: slug);
        },
        routes: [
          GoRoute(
            path: 'systems/:systemKey',
            builder: (context, state) => PwfDynamicSystemHomePage(
              systemKey: state.pathParameters['systemKey'] ?? '',
            ),
            routes: [
              GoRoute(
                path: 'dashboard',
                redirect: (context, state) {
                  final systemKey = state.pathParameters['systemKey'] ?? '';
                  return AppRoutes.adminDynamicSystem(systemKey);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'services',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return kIsWeb
                  ? PwfServicesWebScreen(unitSlug: slug)
                  : const ServicesScreen();
            },
          ),
          GoRoute(
            path: 'eservices',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return kIsWeb
                  ? PwfEServicesWebScreen(unitSlug: slug)
                  : const EServicesScreen();
            },
          ),
          GoRoute(
            path: 'news',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return kIsWeb
                  ? PwfNewsListWebScreen(unitSlug: slug)
                  : NewsScreen(unitSlug: slug);
            },
          ),
          GoRoute(
            path: 'news/:id',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              final contentId = state.pathParameters['id'] ?? '';
              return kIsWeb
                  ? PwfNewsDetailWebScreen(
                      unitSlug: slug,
                      contentId: contentId,
                    )
                  : NewsDetailRouteScreen(
                      unitSlug: slug,
                      id: int.tryParse(contentId) ?? 0,
                      contentId: contentId,
                    );
            },
          ),
          GoRoute(
            path: 'announcements',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return kIsWeb
                  ? PwfAnnouncementsListWebScreen(unitSlug: slug)
                  : AnnouncementsScreen(unitSlug: slug);
            },
          ),
          GoRoute(
            path: 'announcements/:id',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              final contentId = state.pathParameters['id'] ?? '';
              return kIsWeb
                  ? PwfAnnouncementDetailWebScreen(
                      unitSlug: slug,
                      contentId: contentId,
                    )
                  : const UnderConstructionScreen();
            },
          ),
          GoRoute(
            path: 'activities',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return kIsWeb
                  ? PwfActivitiesListWebScreen(unitSlug: slug)
                  : ActivitiesScreen(unitSlug: slug);
            },
          ),
          GoRoute(
            path: 'events',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return PwfEventsPublicScreen(unitSlug: slug);
            },
          ),
          GoRoute(
            path: 'events/:id',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return PwfPlatformCenterContentDetailScreen(
                unitSlug: slug,
                familyKey: 'events',
                id: state.pathParameters['id'] ?? '',
              );
            },
          ),
          GoRoute(
            path: 'activities/:id',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              final contentId = state.pathParameters['id'] ?? '';
              return kIsWeb
                  ? PwfActivityDetailWebScreen(
                      unitSlug: slug,
                      contentId: contentId,
                    )
                  : const UnderConstructionScreen();
            },
          ),
          GoRoute(
            path: 'services/request',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return PwfPublicRequestEntryScreen(unitSlug: slug);
            },
          ),
          GoRoute(
            path: 'services/track',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return PwfPublicRequestTrackingScreen(unitSlug: slug);
            },
          ),
          GoRoute(
            path: 'media',
            redirect: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return UnitRoutes.gallery(slug);
            },
          ),
          GoRoute(
            path: 'gallery',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return kIsWeb
                  ? PwfMediaGalleryWebScreen(unitSlug: slug)
                  : const UnderConstructionScreen();
            },
          ),
          GoRoute(
            path: 'media-center',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return PwfMediaCenterPublicHubScreen(unitSlug: slug);
            },
          ),
          GoRoute(
            path: 'legal-references',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return PwfLegalReferencesPublicScreen(unitSlug: slug);
            },
          ),
          GoRoute(
            path: 'legal-references/:id',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return PwfPlatformCenterContentDetailScreen(
                unitSlug: slug,
                familyKey: 'legal-references',
                id: state.pathParameters['id'] ?? '',
              );
            },
          ),
          GoRoute(
            path: 'sanctities-observatory',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return PwfSanctitiesObservatoryPublicScreen(unitSlug: slug);
            },
          ),
          GoRoute(
            path: 'sanctities-observatory/:id',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return PwfPlatformCenterContentDetailScreen(
                unitSlug: slug,
                familyKey: 'sanctities-observatory',
                id: state.pathParameters['id'] ?? '',
              );
            },
          ),
          GoRoute(
            path: 'social-posts',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return PwfMediaFamilyPublicScreen(
                unitSlug: slug,
                familyKey: 'social-posts',
              );
            },
          ),
          GoRoute(
            path: 'social-posts/:id',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return PwfPlatformCenterContentDetailScreen(
                unitSlug: slug,
                familyKey: 'social-posts',
                id: state.pathParameters['id'] ?? '',
              );
            },
          ),
          GoRoute(
            path: 'press-releases',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return PwfMediaFamilyPublicScreen(
                unitSlug: slug,
                familyKey: 'press-releases',
              );
            },
          ),
          GoRoute(
            path: 'press-releases/:id',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return PwfPlatformCenterContentDetailScreen(
                unitSlug: slug,
                familyKey: 'press-releases',
                id: state.pathParameters['id'] ?? '',
              );
            },
          ),
          GoRoute(
            path: 'official-statements',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return PwfMediaFamilyPublicScreen(
                unitSlug: slug,
                familyKey: 'official-statements',
              );
            },
          ),
          GoRoute(
            path: 'official-statements/:id',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return PwfPlatformCenterContentDetailScreen(
                unitSlug: slug,
                familyKey: 'official-statements',
                id: state.pathParameters['id'] ?? '',
              );
            },
          ),
          GoRoute(
            path: 'awareness-campaigns',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return PwfMediaFamilyPublicScreen(
                unitSlug: slug,
                familyKey: 'awareness-campaigns',
              );
            },
          ),
          GoRoute(
            path: 'awareness-campaigns/:id',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return PwfPlatformCenterContentDetailScreen(
                unitSlug: slug,
                familyKey: 'awareness-campaigns',
                id: state.pathParameters['id'] ?? '',
              );
            },
          ),
          GoRoute(
            path: 'friday-sermons',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return kIsWeb
                  ? PwfFridaySermonsWebScreen(unitSlug: slug)
                  : const UnderConstructionScreen();
            },
          ),
          GoRoute(
            path: 'social-services',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return kIsWeb
                  ? PwfSocialServicesWebScreen(unitSlug: slug)
                  : const SocialServicesScreen();
            },
          ),
          GoRoute(
            path: 'mosques',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return kIsWeb
                  ? PwfMosquesAwqafWebScreen(unitSlug: slug)
                  : const MosquesScreen();
            },
          ),
          GoRoute(
            path: 'projects',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return kIsWeb
                  ? PwfProjectsWebScreen(unitSlug: slug)
                  : const ProjectsScreen();
            },
          ),
          GoRoute(
            path: 'about',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return kIsWeb
                  ? PwfAboutWebScreen(unitSlug: slug)
                  : const AboutScreen();
            },
          ),
          GoRoute(
            path: 'minister',
            builder: (context, state) => const MinisterScreen(),
          ),
          GoRoute(
            path: 'vision-mission',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return kIsWeb
                  ? PwfVisionMissionWebScreen(unitSlug: slug)
                  : const VisionMissionScreen();
            },
          ),
          GoRoute(
            path: 'structure',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return kIsWeb
                  ? PwfOrgStructureWebScreen(unitSlug: slug)
                  : const StructureScreen();
            },
          ),
          GoRoute(
            path: 'former-ministers',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return kIsWeb
                  ? PwfFormerMinistersWebScreen(unitSlug: slug)
                  : const FormerMinistersScreen();
            },
          ),
          GoRoute(
            path: 'contact',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return kIsWeb
                  ? PwfContactWebScreen(unitSlug: slug)
                  : const ContactScreen();
            },
          ),
          GoRoute(
            path: 'privacy',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return PwfPrivacyPolicyWebScreen(unitSlug: slug);
            },
          ),
          GoRoute(
            path: 'terms',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return PwfTermsOfUseWebScreen(unitSlug: slug);
            },
          ),
          GoRoute(
            path: 'sitemap',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return PwfSiteMapWebScreen(unitSlug: slug);
            },
          ),
          GoRoute(
            path: 'search',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return SearchScreen(
                initialQuery: state.uri.queryParameters['q'] ?? '',
                unitSlug: slug,
              );
            },
          ),
          GoRoute(
            path: 'chat',
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              final sid = state.uri.queryParameters['sid'];
              if (kIsWeb) {
                return PwfWebPageScaffold(
                  unitSlug: slug,
                  child: PublicChatbotPage(
                    unitId: slug,
                    publicSessionId: sid,
                    embedInPublicShell: true,
                  ),
                );
              }
              return PublicChatbotPage(unitId: slug, publicSessionId: sid);
            },
          ),
          GoRoute(
            path: 'complaints',
            redirect: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              if (slug == 'admin') return AppRoutes.adminComplaints;
              return null;
            },
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return PwfComplaintsScreen(
                unitSlug: slug,
                embedInPublicShell: true,
              );
            },
          ),
          GoRoute(
            path: 'zakat',
            redirect: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              if (slug == 'admin') return AppRoutes.adminZakat;
              return null;
            },
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return PwfZakatPublicScreen(unitSlug: slug);
            },
          ),
          GoRoute(
            path: 'prayer-times',
            redirect: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              if (slug == 'admin') return AppRoutes.adminPrayerTimes;
              return null;
            },
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return PwfPrayerTimesPublicScreen(unitSlug: slug);
            },
          ),
          GoRoute(
            path: 'quran',
            redirect: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              if (slug == 'admin') return AppRoutes.adminQuran;
              return null;
            },
            builder: (context, state) {
              final slug =
                  PwfUnitSlugRegistry.internalSlugFor(state.pathParameters['unitSlug'] ?? 'home');
              return PwfQuranPublicScreen(unitSlug: slug);
            },
          ),
        ],
      ),
    ],
  );
}
