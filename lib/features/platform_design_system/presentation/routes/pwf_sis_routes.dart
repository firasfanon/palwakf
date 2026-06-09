import 'package:go_router/go_router.dart';
import '../pages/pwf_sis_platform_admin_adoption_page.dart';
import '../pages/pwf_sis_media_center_low_risk_adoption_page.dart';
import '../pages/pwf_sis_services_platform_content_adoption_page.dart';
import '../pages/pwf_sis_public_responsive_alignment_page.dart';

import '../pages/pwf_sis_component_gallery_page.dart';
import '../pages/pwf_sis_visual_identity_bridge_page.dart';
import '../pages/pwf_sis_rollout_evidence_page.dart';
import '../pages/pwf_sis_closure_review_page.dart';
import '../pages/pwf_sis_wave2_scope_page.dart';
import '../pages/pwf_sis_wave2_media_inventory_page.dart';
import '../pages/pwf_sis_wave2_media_library_pilot_page.dart';
import '../../../awqaf_system/presentation/pilot/pwf_sis_awqaf_system_pilot_page.dart';

class PwfSisRoutes {
  static const publicResponsiveAlignment =
      PwfSisPublicResponsiveAlignmentPage.routePath;
  static const servicesPlatformContentAdoption =
      PwfSisServicesPlatformContentAdoptionPage.routePath;
  static const mediaCenterLowRiskAdoption =
      PwfSisMediaCenterLowRiskAdoptionPage.routePath;
  static const platformAdminAdoption =
      PwfSisPlatformAdminAdoptionPage.routePath;
  const PwfSisRoutes._();

  static const designSystem = PwfSisComponentGalleryPage.routePath;
  static const visualIdentityBridge = PwfSisVisualIdentityBridgePage.routePath;
  static const awqafPilot = PwfSisAwqafSystemPilotPage.routePath;
  static const rolloutEvidence = PwfSisRolloutEvidencePage.routePath;
  static const closureReview = PwfSisClosureReviewPage.routePath;
  static const wave2Scope = PwfSisWave2ScopePage.routePath;
  static const wave2MediaInventory = PwfSisWave2MediaInventoryPage.routePath;
  static const wave2MediaLibraryPilot =
      PwfSisWave2MediaLibraryPilotPage.routePath;

  static List<GoRoute> routes() {
    return [
      GoRoute(
        path: designSystem,
        builder: (context, state) => const PwfSisComponentGalleryPage(),
      ),
      GoRoute(
        path: visualIdentityBridge,
        builder: (context, state) => const PwfSisVisualIdentityBridgePage(),
      ),
      GoRoute(
        path: awqafPilot,
        builder: (context, state) => const PwfSisAwqafSystemPilotPage(),
      ),
      GoRoute(
        path: rolloutEvidence,
        builder: (context, state) => const PwfSisRolloutEvidencePage(),
      ),
      GoRoute(
        path: closureReview,
        builder: (context, state) => const PwfSisClosureReviewPage(),
      ),
      GoRoute(
        path: wave2Scope,
        builder: (context, state) => const PwfSisWave2ScopePage(),
      ),
      GoRoute(
        path: wave2MediaInventory,
        builder: (context, state) => const PwfSisWave2MediaInventoryPage(),
      ),
      GoRoute(
        path: wave2MediaLibraryPilot,
        builder: (context, state) => const PwfSisWave2MediaLibraryPilotPage(),
      ),
      GoRoute(
        path: platformAdminAdoption,
        builder: (context, state) => const PwfSisPlatformAdminAdoptionPage(),
      ),
      GoRoute(
        path: mediaCenterLowRiskAdoption,
        builder: (context, state) =>
            const PwfSisMediaCenterLowRiskAdoptionPage(),
      ),
      GoRoute(
        path: servicesPlatformContentAdoption,
        builder: (context, state) =>
            const PwfSisServicesPlatformContentAdoptionPage(),
      ),
      GoRoute(
        path: publicResponsiveAlignment,
        builder: (context, state) =>
            const PwfSisPublicResponsiveAlignmentPage(),
      ),
    ];
  }
}
