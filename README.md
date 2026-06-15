# PalWakf Platform 12 Baseline

This baseline belongs to session `تطوير المنصة 12`.

Latest Mega Batch:

```text
Platform 12 — Homepage Management Sovereign Runtime Contract Mega Batch
```

Key decisions:

- `/admin/home-management` and `/home` are governed by one sovereign runtime contract.
- Homepage section state is RPC-first: admin read, save, and runtime read.
- Each section has a registry definition: family, source, renderer, owner, and visibility rule.
- Duplicated representatives inside one family are removed from runtime by deactivation, not physical delete.
- Breaking news is independent from normal news and must not disappear inside the news family.
- Media gallery owns photos/videos only; activities/events remain in their own family.
- SQL is prepared under `sql_apply` but not executed.
- No service-role usage. Production is not approved.
- Android runtime UAT remains deferred.

See:

```text
LATEST_BASELINE_POINTER.md
docs/platform12/PLATFORM12_HOMEPAGE_MANAGEMENT_SOVEREIGN_RUNTIME_CONTRACT_MEGA_BATCH_2026_06_13.md
docs/platform12/UAT_HOMEPAGE_MANAGEMENT_SOVEREIGN_RUNTIME_CONTRACT_2026_06_13.md
docs/platform12/error_records/ERROR_RECORD_HOMEPAGE_MANAGEMENT_SOVEREIGN_RUNTIME_CONTRACT_2026_06_13.md
docs/platform12_homepage_management_sovereign_runtime_contract/HOMEPAGE_MANAGEMENT_SOVEREIGN_RUNTIME_CONTRACT.md
```

## Platform 12 — Homepage Visual Contract Alignment Mega Batch — 2026-06-13

This baseline centralizes the public homepage visual system through `PwfHomeVisualContract`, `PwfSectionContainer`, and `PwfSectionTitle`. It does not execute SQL and does not change the sovereign homepage management RPC contract.

## Platform 12 — Public Subpages Visual Contract + About/Vision Development Mega Batch

This baseline extends the homepage visual contract to homepage-derived public subpages and develops `/about` and `/vision-mission`.

Validation:

```powershell
flutter analyze
flutter test
flutter run -d chrome
```

Primary verification routes:

```text
/about
/vision-mission
/media-center
/services
/e-services
/home
```

## Platform 12 — Homepage First Fold Visual Refinement Mega Batch — 2026-06-13

This baseline includes first-fold homepage visual refinements: hero-width breaking news, full-height hero image coverage, continuous section background flow, secondary featured complementary news, news thumbnails, one-line e-services governance chips, and delayed scroll-to-top visibility.

Validation: run `flutter analyze`, `flutter test`, `flutter run -d chrome`, then inspect `/home` and `/admin/home-management`.

## Platform 12 — Homepage Surface Continuity + Hero Height Closure — 2026-06-15

This baseline includes the Mega Batch that increases/rebalances homepage hero height according to user evidence, lowers the hero image focal point, and removes the grey-band surface drift below minister/statistics sections by using one white sovereign homepage canvas.

Primary docs:

- `docs/platform12/PLATFORM12_HOMEPAGE_SURFACE_CONTINUITY_HERO_HEIGHT_CLOSURE_MEGA_BATCH_2026_06_15.md`
- `docs/platform12/UAT_HOMEPAGE_SURFACE_CONTINUITY_HERO_HEIGHT_CLOSURE_2026_06_15.md`

No SQL executed. No service-role usage. Production not approved. Android runtime UAT remains deferred.


## Platform 12 — Homepage Adaptive Hero + Surface Band Closure — 2026-06-15

This baseline includes the Mega Batch that responds to retest evidence for `/home`: the hero now uses a stronger adaptive first-fold height, the image focal point is lowered further, the media gallery no longer owns an external gradient/margin wrapper, and the renderer adds a white sovereign slot around runtime sections to prevent grey/foreign bands when sections are disabled from `/admin/home-management`.

Primary docs:

- `docs/platform12/PLATFORM12_HOMEPAGE_ADAPTIVE_HERO_SURFACE_BAND_CLOSURE_MEGA_BATCH_2026_06_15.md`
- `docs/platform12/UAT_HOMEPAGE_ADAPTIVE_HERO_SURFACE_BAND_CLOSURE_2026_06_15.md`
- `docs/platform12/error_records/ERROR_RECORD_HOMEPAGE_ADAPTIVE_HERO_SURFACE_BAND_CLOSURE_2026_06_15.md`

Validation: run `flutter analyze`, `flutter test`, `flutter run -d chrome`, then inspect `/home` after enabling/disabling breaking news and gallery-related sections.

No SQL executed. No service-role usage. Production not approved. Android runtime UAT remains deferred.

## Platform 12 — Public Subpages Unified Visual Polish — 2026-06-15

This baseline includes the Mega Batch that standardizes homepage-derived public subpages after the homepage visual and surface-continuity work. It reworks the shared public intro, stats cards, empty states, platform frontend hub cards, static fallback pages, and scroll-to-top behavior so pages such as `/home/news`, `/home/services`, `/home/contact`, `/home/chat`, `/home/social-posts`, and `/home/activities` use one visual rhythm while preserving each page's operational specificity.

Primary docs:

- `docs/platform12/PLATFORM12_PUBLIC_SUBPAGES_UNIFIED_VISUAL_POLISH_MEGA_BATCH_2026_06_15.md`
- `docs/platform12/UAT_PUBLIC_SUBPAGES_UNIFIED_VISUAL_POLISH_2026_06_15.md`
- `docs/platform12/error_records/ERROR_RECORD_PUBLIC_SUBPAGES_UNIFIED_VISUAL_POLISH_2026_06_15.md`

Validation: run `flutter analyze`, `flutter test`, `flutter run -d chrome`, then inspect the listed public subpages in DevTools.

No SQL executed. No service-role usage. Production not approved. Android runtime UAT remains deferred.

## Platform 12 — Public Subpages Visual System Rework — 2026-06-15

This baseline includes the Mega Batch that replaces piecemeal public-subpage visual polishing with a compact shared public-subpage visual system. It reduces oversized hero/title boxes, improves text contrast, hides technical governance data from the citizen-facing layer, compacts metric cards and status blocks, and uses subpage-aware spacing below the public header.

Primary docs:

- `docs/platform12/PLATFORM12_PUBLIC_SUBPAGES_VISUAL_SYSTEM_REWORK_MEGA_BATCH_2026_06_15.md`
- `docs/platform12/UAT_PUBLIC_SUBPAGES_VISUAL_SYSTEM_REWORK_2026_06_15.md`
- `docs/platform12/error_records/ERROR_RECORD_PUBLIC_SUBPAGES_VISUAL_SYSTEM_REWORK_2026_06_15.md`

Validation: run `flutter analyze`, `flutter test`, `flutter run -d chrome`, then inspect the listed public subpages in DevTools.

No SQL executed. No service-role usage. Production not approved. Android runtime UAT remains deferred.

## Platform 12 — Public Subpages Analyze/Test Contract Closure Mega Batch — 2026-06-15

This baseline closes the local analyzer/test blockers produced after the public-subpages visual-system rework. It fixes invalid Flutter font weights, removes stale unused code, simplifies a redundant analyzer type check, restores the royal-red visual token inside the central visual contract, and rebases stale tests to the compact visual-system contract. No SQL executed. No service-role usage. Production not approved. Android runtime UAT remains deferred.

## Platform 12 — Public Governance Residue Closure

Latest Platform 12 public-subpage baseline removes residual citizen-facing technical governance labels and closes the stale root widget-test template issue. Run:

```powershell
flutter analyze
flutter test
flutter run -d chrome
```

Then inspect the public subpages and confirm technical diagnostics appear only in admin/docs, not in citizen-facing pages.


## Platform 12 — Public Subpages Full Visual Audit + Governance Residue Closure Mega Batch

This baseline continues Platform 12 public-site work by applying a full visual/copy audit across public subpages. It removes public governance/source banners from interactive tools, compacts mastheads, hides developer notes from citizen-facing pages, and updates contract tests accordingly.
