# CHANGELOG

## 2026-06-13 — Platform 12 Home Search + Homepage Sections Source Consolidation Mega Batch

### Consolidated

- Bound public home search to governed routes with query parameters.
- Added URL query synchronization from web/mobile search screens.
- Preserved search as a local public-route index pending future database-backed RPC approval.
- Certified homepage sections runtime source chain through `public.v_platform_homepage_sections_compat_v1`.
- Hardened canonical section alias deduplication in `HomepageRepository.fetchAllSectionsForUnit`.
- Added deterministic ordering for scoped homepage section reads.
- Kept semantic overlap cleanup as a UX/content policy decision, not an automatic deletion.
- Added consolidated Mega Batch documentation, error record, and UAT checklist.

### Evidence absorbed

- `/home/search?q=مسجد` returns one result for المساجد.
- Read-only section diagnostics confirmed canonical duplicate keys and semantic active overlaps.
- Browser evidence showed constrained-width `WebAppBar` overflow requiring responsive verification.

### SQL status

```text
no-sql-executed
guarded-dml-prepared-not-authorized
semantic-family-policy-decision-required
```

### Preserved

- Android runtime UAT remains deferred.
- No service-role usage.
- No production approval.


## 2026-06-11 — Stabilization Governance Priority Pack

### Added

- Data Contract Validation Policy
- CMS Payload Contracts
- Governed Media Attachments Design
- RBAC Identity Source of Truth Decision
- PalWakf Smoke Test Suite
- Technical Services Operational Runbook

### Key Decisions

- Public reads remain through compatibility views/wrappers.
- CMS simple admin writes may remain direct table access only with payload validation.
- Publish/transition/decision actions should use RPC.
- `attachment_url` is not added as a quick public table column.
- Governed attachments should be handled through owner-schema attachment registry.
- `platform_access` should be treated as the platform RBAC authority for new development.
- Technical Services is metadata/request/evidence driven; dangerous operations remain outside Flutter.

### No Changes

- No SQL changes.
- No RLS changes.
- No production approval.
- No service-role usage in Flutter.


## 2026-06-11 — Priority Implementation Mega Batch

### Added

- `PwfPayloadContract` generic DTO/schema validation helper.
- `CmsPayloadContracts` for News, Announcements, and Activities.
- Unit tests for CMS payload contracts.
- Governed media attachments SQL/RLS draft under `sql_drafts/`.
- RBAC identity read-only evidence probes under `sql_diagnostics/`.
- Executable smoke suite under `tools/smoke/`.
- Technical Services UAT closure evidence template.

### Preserved

- CMS direct table access for simple create/update operations.
- RPC-first policy for governed decisions and technical services operations.
- No SQL apply.
- No RLS mutation.
- No service-role usage in Flutter.


## 2026-06-11 — Smoke Suite Authenticated Full Pass Evidence

### Accepted Evidence

- `SMK-05` Media Center public news compatibility view returned HTTP 200.
- `SMK-06` Media Center public announcements compatibility view returned HTTP 200.
- `SMK-07` Media Center public activities compatibility view returned HTTP 200.
- `SMK-08` Technical Services dashboard RPC returned HTTP 200 using authenticated admin user context.
- Smoke summary: `passed=4 skipped=0 failed=0`.

### Decision

`SMK-08` is closed as Passed. The Technical Services protected RPC is verified without service-role usage.


## 2026-06-11 — Remaining Closure Evidence Gate

### Added

- CMS Add News Network Evidence Gate.
- Technical Services Operations Center Browser Evidence Gate.
- RBAC Identity Source-of-Truth read-only SQL evidence gate.
- Remaining closure decision matrix.

### Status

- No SQL apply.
- No RLS change.
- No service-role usage.
- Production approval remains deferred.


## 2026-06-11 — Remaining Closure Partial Evidence Intake

### Accepted

- CMS Add News network evidence accepted: `news_articles` returned HTTP 201.
- Technical Services Backup route evidence accepted.
- Technical Services protected dashboard RPC remained HTTP 200.

### Pending

- Operations Center screenshot specifically showing Evidence/Notifications/Decisions.
- Full RBAC identity source-of-truth SQL result intake.

### Decision

`PALWAKF_REMAINING_CLOSURE_PARTIAL_EVIDENCE_ACCEPTED_TWO_ITEMS_PENDING`


## 2026-06-11 — Near-Final Closure Evidence Intake

### Accepted

- Technical Services Operations Center browser screenshot accepted.
- Evidence/Notifications/Decisions cards visible.
- RBAC `platform_access` structural evidence accepted:
  - admin users
  - permissions
  - role-permission map
  - user permissions
  - user scope assignments
  - user system roles/permissions

### Pending

- `identity_foreign_keys` evidence proving or clarifying the admin identity link to `auth.users`.

### Decision

`PALWAKF_NEAR_FINAL_CLOSURE_ACCEPTED_RBAC_AUTH_USERS_FK_PENDING`


## 2026-06-11 — Final Closure Evidence Complete with RBAC Auth Link Review Required

### Accepted

- Analyzer clean evidence.
- CMS contract tests passed.
- Smoke suite full pass.
- CMS Add News HTTP 201 evidence.
- Technical Services protected RPC HTTP 200 evidence.
- Technical Services Operations Center browser evidence.
- RBAC `platform_access` structural authority evidence.

### RBAC Finding

The FK diagnostic returned no rows. A physical FK from `platform_access.admin_users` to `auth.users` was not proven.

### Decision

`PALWAKF_STABILIZATION_EVIDENCE_COMPLETE_WITH_RBAC_AUTH_LINK_REVIEW_REQUIRED`

### No Mutation

- No SQL apply.
- No RLS change.
- No FK creation.
- No service-role usage.


## 2026-06-11 — RBAC Auth Users Link Remediation Design

### Added

- Read-only diagnostics for platform_access/admin_users to auth.users consistency.
- Decision matrix for physical FK vs logical contract vs compatibility view vs bridge table.
- Draft SQL for candidate remediation paths.
- Result intake template.

### No Mutation

- No SQL apply.
- No FK created.
- No RLS mutation.
- No service-role usage.


## 2026-06-11 — RBAC Auth Users Link Readiness Result Intake

### Accepted

- `platform_access.admin_users` row count: 86.
- `auth.users` row count: 86.
- Matched-by-ID count: 86.
- Orphan admin users: 0.
- Email mismatches: 0.

### Decision

`RBAC_AUTH_USERS_PHYSICAL_FK_READY_FOR_AUTHORIZED_APPLY_DESIGN`

### Final Stabilization Evidence Decision

`PALWAKF_STABILIZATION_EVIDENCE_COMPLETE_RBAC_FK_READY_FOR_AUTHORIZED_APPLY_DESIGN`

### No Mutation

- No SQL apply.
- No FK created.
- No RLS change.
- No production approval.


## 2026-06-11 — Platform Identity RBAC Authority Consolidation Mega Batch

### Prepared

- Authorized FK apply SQL for `platform_access.admin_users.id -> auth.users.id`.
- Pre-apply read-only guard.
- Post-apply verification SQL.
- Rollback SQL.
- Smoke/browser regression documentation.
- Test plan and closure criteria.

### Authorization

User authorized FK apply scope, verification, rollback, smoke/tests/docs, with no service-role in Flutter and no automatic production approval.

### Current Status

`operator-apply-pending`

No SQL has been executed by the assistant.


## 2026-06-11 — Platform Identity RBAC Authority Consolidation Closure

### Applied and Verified

- `platform_access_admin_users_id_auth_users_id_fk` was created and validated.
- Post-apply data integrity passed:
  - platform_access admins: 86
  - auth users: 86
  - matched by ID: 86
  - orphans: 0
  - email mismatches: 0

### Important Finding

A pre-existing FK already existed:

`admin_users_id_fkey: FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE`

The new FK is therefore redundant from a schema hygiene perspective.

### Decision

`PALWAKF_PLATFORM_IDENTITY_RBAC_AUTHORITY_CONSOLIDATION_APPLIED_AND_VERIFIED_DUPLICATE_FK_DETECTED`

### Recommendation

Optional cleanup may drop the new duplicate FK while preserving the original FK.


## 2026-06-11 — Final Regression Handoff + Media Center Governed Attachments Mega Pack

### Prepared

- Final stabilization regression and handoff pack.
- Media Center governed attachments contract.
- CMS contract additions for governed attachments.
- SQL drafts for `media_center.content_attachments`.
- RLS/public-wrapper/upsert-RPC drafts.
- Verification and rollback SQL.
- Smoke/browser regression plan.

### Preserved

- No SQL apply.
- No RLS apply.
- No service-role in Flutter.
- No automatic production approval.


## 2026-06-11 — Document Center Unification and Lifecycle Governance Mega Batch

### Added

- `lib/features/document_center/` unified document center feature.
- Read-only repository that loads:
  - document intelligence jobs
  - platform service request attachments
  - media center content assets
- Unified `/admin/documents` portal.
- Document lifecycle governance policy.
- SQL drafts for document type registry and lifecycle columns.
- Read-only inventory and verification SQL.

### Changed

- `/admin/documents` now routes to `DocumentCenterUnifiedPage` instead of the old static sample screen.

### Preserved

- No SQL apply.
- No RLS apply.
- No destructive file operations.
- No duplicate `content_attachments` table.
- No service-role in Flutter.
- No production approval.


## 2026-06-12 — Document Center SQL Schema-safe + News Hero Runtime Hotfix

### Fixed

- Removed invalid `ca.status` reference from the Document Center unified SQL view draft.
- Reworked `_NewsHeroCard` responsive layout to avoid `Expanded` inside vertical unbounded constraints.

### Evidence Accepted

- Analyzer clean.
- CMS payload contract tests passed.
- Smoke suite public media checks passed; protected Technical Services RPC skipped without admin token.
- Storage counts: document-intelligence=5, media-gallery=6.

### Preserved

- No SQL apply.
- No RLS apply.
- No service-role.
- No production approval.


## 2026-06-12 — Document Center Public Wrappers Runtime Closure Hotfix

### Fixed

- Removed direct Flutter REST reads from non-exposed owner schemas:
  - `platform_services`
  - `media_center`
- Added optional public-wrapper read contract for `/admin/documents`.
- Added public wrapper SQL drafts.
- Reworked News Hero wide layout to provide finite height and avoid unbounded flex errors.

### Preserved

- No SQL apply.
- No RLS apply.
- No service-role usage.
- No production approval.


## 2026-06-12 — Document Center Public Wrappers Apply and Runtime Retest

### Prepared

- Apply SQL for:
  - `public.v_document_center_service_attachments_v1`
  - `public.v_document_center_media_assets_v1`
- Read-only verification SQL.
- Rollback SQL.
- Runtime retest runbook and closure template.

### Preserved

- Owner schemas remain private.
- No direct Flutter reads from `platform_services` or `media_center`.
- No RLS mutation.
- No service-role usage.
- No production approval.


## 2026-06-12 — Document Center Public Wrappers Applied and Runtime Retest Closure

### Accepted

- Public wrappers applied:
  - `public.v_document_center_service_attachments_v1`
  - `public.v_document_center_media_assets_v1`
- Authenticated select verified for both wrappers.
- `/admin/documents` runtime retest passed without visible PGRST106 panel.
- `/home/news` runtime retest passed without visible RenderFlex error.
- Storage counts confirmed:
  - document-intelligence = 5
  - media-gallery = 6

### Decision

`DOCUMENT_CENTER_PUBLIC_WRAPPERS_APPLIED_AND_RUNTIME_RETEST_PASSED`

### Preserved

- No RLS mutation.
- No data mutation.
- No service-role usage.
- No production approval.


## 2026-06-12 — Document Lifecycle Policy Registry Apply and Attachment Classification

### Prepared

- Apply SQL for `platform_documents.document_types`.
- Seed document type policy rows.
- Lifecycle columns for `platform_services.service_request_attachments`.
- Backfill/classification of existing service attachments.
- Lifecycle-aware `/admin/documents` public wrappers.
- Verification SQL and rollback SQL.
- Runtime retest runbook.

### Preserved

- No file deletion.
- No `storage.objects` mutation.
- No destructive media center mutation.
- No RLS mutation.
- No service-role usage.
- No production approval.


## 2026-06-12 — Document Lifecycle View Replace Order Hotfix

### Fixed

- Replaced `CREATE OR REPLACE VIEW` flow with drop-and-create for document center public wrappers.
- Addresses PostgreSQL ERROR 42P16 caused by attempting to insert lifecycle columns before an existing view column.

### Preserved

- No file deletion.
- No storage mutation.
- No owner schema exposure.
- No RLS mutation.
- No service-role usage.
- No production approval.


## 2026-06-12 — Document Lifecycle Registry Applied with Empty Source Surfaces

### Accepted

- `platform_documents.document_types` exists.
- Document type count = 5.
- Service attachment wrapper exists.
- Media asset wrapper exists.
- Production approved remains false.

### Finding

- Classified service attachment count = 0.
- Service wrapper row count = 0.
- Media wrapper row count = 0.

### Decision

`DOCUMENT_LIFECYCLE_POLICY_REGISTRY_APPLIED_EMPTY_SOURCE_SURFACES_ACCEPTED`

### Preserved

- No file deletion.
- No storage mutation.
- No RLS mutation.
- No service-role usage.
- No production approval.


## 2026-06-12 — Controlled File Center Source Record Seed / Storage Object Mapping

### Prepared

- Read-only storage object mapping inventory.
- Neutral `platform_documents.file_object_registry` apply candidate.
- Seed from `storage.objects` for:
  - media-gallery
  - document-intelligence
- Public wrapper `public.v_document_center_storage_objects_v1`.
- Verification and rollback SQL.
- Runtime retest runbook.

### Preserved

- No file deletion.
- No `storage.objects` mutation.
- No fake service attachment rows.
- No fake media asset rows.
- No RLS mutation.
- No service-role usage.
- No production approval.


## 2026-06-12 — File Center Storage Mapping Unit-aware Scope Before Apply

### Prepared

- Unit-aware storage object registry mapping.
- Administrative unit defaults:
  - restricted
  - unassigned
  - storage_only scope
- Integrity verification for:
  - no public storage-only files
  - no unit assignment without explicit status
  - no unassigned files outside restricted visibility

### Preserved

- No file deletion.
- No `storage.objects` mutation.
- No fake service attachment rows.
- No fake media asset rows.
- No RLS mutation.
- No service-role usage.
- No production approval.


## 2026-06-12 — File Center Unit-aware Org Units Schema-safe Hotfix

### Fixed

- Removed direct diagnostic reference to `core.org_units.type`.
- Added schema-safe optional org unit field projection via `to_jsonb(ou)->>'field'`.
- Updated storage object wrapper to avoid direct optional org unit columns.

### Preserved

- Default restricted/unassigned storage mapping.
- No administrative unit inference.
- No file deletion.
- No storage mutation.
- No fake owner records.
- No RLS mutation.
- No service-role usage.
- No production approval.


## 2026-06-12 — File Center Unit-aware Storage Mapping Applied

### Accepted

- `platform_documents.file_object_registry` present.
- `public.v_document_center_storage_objects_v1` present.
- Registry row count = 11.
- Unassigned count = 11.
- Restricted count = 11.
- Production approved = false.

### Decision

`FILE_CENTER_UNIT_AWARE_STORAGE_MAPPING_APPLIED_AND_VERIFIED`

### Preserved

- No administrative unit inference.
- No public visibility without owner mapping.
- No fake owner records.
- No file deletion.
- No storage mutation.
- No RLS mutation.
- No service-role usage.
- No production approval.


## 2026-06-13 — File Center + Home News + Public API Edge Mega Batch

### Added

- Explicit file-center unit assignment and owner record mapping workflow SQL candidate.
- Public API-edge RPCs for assignment/mapping, backed by `platform_documents`.
- Document Center storage-object surface.
- Document Center storage-object metrics and governance chips.
- Public schema API-edge-only governance decision.

### Changed

- News service logs public wrappers as API edge backed by `media_center`.
- Legacy public base table fallback is disabled by default unless `PWF_ALLOW_LEGACY_PUBLIC_MEDIA_BASE_FALLBACK=true`.

### Preserved

- No public base tables.
- No owner source-of-truth migration into public.
- No file deletion.
- No storage mutation.
- No fake owner records.
- No RLS mutation.
- No service-role usage.
- No production approval.


## 2026-06-13 — File Center + Home News + Public API Edge Evidence Closure

### Accepted

- File Center explicit assignment/mapping workflow applied.
- `platform_documents.file_object_mapping_events` present.
- `public.rpc_file_object_assign_unit_scope_v1` present.
- `public.rpc_file_object_mark_owner_mapping_v1` present.
- `public.v_media_news_compat_v1` present.
- `public.v_media_announcements_compat_v1` present.
- `public.v_media_activities_compat_v1` present.
- `public.v_document_center_storage_objects_v1` present.
- Flutter analyze clean.
- CMS payload contract tests passed.
- Smoke suite passed 3, skipped 1, failed 0.
- Chrome runtime launched with media center API-edge rows.

### Preserved

- No public base tables created.
- Public schema remains API edge only.
- Legacy public base tables remain inventory warnings, not remediated in this batch.
- No service-role usage.
- No production approval.


## 2026-06-13 — Media Center Mobile Application MVP

### Added

- Standalone mobile route `/app/media-center`.
- Mobile-first Media Center app page.
- Bottom navigation for news, announcements, and activities.
- Pull-to-refresh and quick search.
- Detail bottom sheet for mobile.
- Owner-schema/API-edge mobile repository.
- Runtime logs marking `public.v_media_*` as API edge only.

### Preserved

- No SQL apply.
- No public base tables.
- No owner source-of-truth migration into public.
- No media-gallery auto-publication.
- No service-role usage.
- No production approval.


## 2026-06-13 — Official-first Media Center Mobile Publishing App MVP

### Added

- Quick mobile publishing route `/app/media-center/publish`.
- Official public detail route `/official/media/:family/:id`.
- Mobile publish draft model and repository.
- Upload image support to `media-gallery` without automatic public exposure.
- Draft / submit for review / direct publish workflow.
- Share official URL flow.
- Public detail page that reads only published official content.
- Android host configuration for mobile publishing app identity and permissions.
- SQL candidate RPCs for official-first mobile publishing.

### Preserved

- `media_center` remains source of truth.
- `public` remains API edge only.
- No public base tables.
- No service-role usage.
- No RLS mutation in this batch.
- No production approval.


## 2026-06-13 — Official-first Mobile Publishing Analyzer Cleanup

### Fixed

- Removed unnecessary `dart:typed_data` import.
- Removed unused `package:go_router/go_router.dart` import.

### Preserved

- No SQL changes.
- No public base tables.
- No service-role usage.
- No production approval.


## 2026-06-13 — BreakingNewsSlider Null-safe Runtime Hotfix

### Fixed

- Removed unsafe null-check on `settingsState.settings!`.
- Added fallback `const BreakingNewsSectionSettings()` while settings are still loading.

### Preserved

- No SQL changes.
- No public base tables.
- No service-role usage.
- No RLS/storage mutation.
- No production approval.


## 2026-06-13 — Media Center Mobile Visual Contract Alignment

### Added

- Shared mobile visual contract widget/theme for the official-first media app.

### Changed

- Aligned `/app/media-center` with PalWakf dark/gold identity.
- Aligned `/app/media-center/publish` with official-first publishing hierarchy.
- Aligned `/official/media/:family/:id` as a public official-link detail interface.
- Replaced default Material visual emphasis with PalWakf platform colors.

### Preserved

- No SQL changes.
- No public base tables.
- No service-role usage.
- No RLS/storage mutation.
- No production approval.


## 2026-06-13 — Media Center Mobile Operational Workflow + Android Readiness

### Added

- Mobile operational home route `/app/media`.
- Operational entry page for official-first media workflows.
- Android debug build readiness script.
- SQL read-only readiness verification for mobile publishing RPCs.

### Preserved

- No SQL apply.
- No public base tables.
- No service-role usage.
- No production approval.


## 2026-06-13 — Android Core Library Desugaring Build Hotfix

### Fixed

- Enabled core library desugaring in `android/app/build.gradle.kts`.
- Added `desugar_jdk_libs` dependency.
- Fixed Android debug build script to fail hard on native command failures and verify APK output.

### Preserved

- No SQL changes.
- No public base tables.
- No service-role usage.
- No production approval.


## 2026-06-13 — Android Build Script PowerShell Variable Hotfix

### Fixed

- Corrected PowerShell interpolation from `$LASTEXITCODE:` to `$($LASTEXITCODE):`.

### Preserved

- No SQL changes.
- No Android Gradle changes.
- No public base tables.
- No service-role usage.
- No production approval.


## 2026-06-13 — Media Center Mobile Offline Drafts + Field Reporter Workflow

### Added

- Local draft store using SharedPreferences.
- Local drafts provider.
- `/app/media-center/drafts` route.
- Local drafts page.
- Save-to-phone action in quick publish page.
- Resume editing local draft.
- Operational home card for phone drafts.

### Preserved

- Local draft is not official content.
- Official source of truth remains `media_center` after RPC submission.
- No SQL apply.
- No public base tables.
- No service-role usage.
- No production approval.


## 2026-06-13 — Offline Drafts Analyzer Imports Hotfix

### Fixed

- Imported `MediaCenterLocalDraft` defining library in `go_router_config.dart`.
- Imported `media_center_publish_models.dart` in the local drafts page so `labelAr` extension is visible.

### Preserved

- No SQL changes.
- No Gradle changes.
- No public base tables.
- No service-role usage.
- No production approval.


## 2026-06-13 — Offline Drafts Route Type Decoupling Analyzer Hotfix

### Fixed

- Removed `MediaCenterLocalDraft` type dependency from `common_routes_group.dart`.
- Moved route extra type-check into `MediaCenterQuickPublishPage`.
- Removed direct `labelAr` extension dependency from local drafts page.

### Preserved

- No SQL changes.
- No Gradle changes.
- No public base tables.
- No service-role usage.
- No production approval.


## 2026-06-13 — Offline Drafts Final Analyzer Unused Import Hotfix

### Fixed

- Removed unused `MediaCenterLocalDraft` store import from `go_router_config.dart`.

### Preserved

- No SQL changes.
- No Gradle changes.
- No public base tables.
- No service-role usage.
- No production approval.


## 2026-06-13 — Android Kotlin Metadata Toolchain Alignment Hotfix

### Fixed

- Upgraded Kotlin Gradle Plugin from 2.1.0 to 2.3.10.
- Upgraded Android Gradle Plugin from 8.9.1 to 8.11.1.
- Upgraded Gradle wrapper from 8.12 to 8.14.
- Enabled Kotlin in-process compilation to avoid daemon connection instability.
- Updated Android build script to stop existing Gradle daemons before build.

### Preserved

- No SQL changes.
- No media_center/public schema mutations.
- No public base tables.
- No service-role usage.
- No production approval.


## 2026-06-13 — Android Kotlin compilerOptions DSL Hotfix

### Fixed

- Migrated Android app Kotlin target configuration from deprecated/error `kotlinOptions.jvmTarget` string DSL to `kotlin.compilerOptions`.
- Added `JvmTarget.JVM_11` compiler options.
- Guarded Gradle daemon stop in the Android build script when Java is unavailable in the current shell.

### Preserved

- No SQL changes.
- No media_center/public schema mutations.
- No public base tables.
- No service-role usage.
- No production approval.


## 2026-06-13 — Android Duplicate MainActivity Cleanup Hotfix

### Fixed

- Removed duplicate Java `MainActivity` from full baseline.
- Retained Kotlin `MainActivity` as the canonical Android entrypoint.
- Added cleanup script for updates-only application.
- Updated Android debug build script to run duplicate cleanup before building.

### Deleted From Full Baseline

```text
android/app/src/main/java/com/example/waqf/MainActivity.java
```

### Preserved

- No SQL changes.
- No media_center/public schema mutations.
- No public base tables.
- No service-role usage.
- No production approval.


## 2026-06-13 — Media Center Mobile Android Debug Build Success Evidence Closure

### Accepted

- Android debug APK built successfully.
- Flutter analyzer gate clean.
- CMS payload contract tests passed.
- Duplicate MainActivity cleanup executed.
- Android build script successfully produced an APK.

### APK

```text
build\app\outputs\flutter-apk\app-debug.apk
```

### Preserved

- No SQL changes.
- No media_center/public schema mutations.
- No public base tables.
- No service-role usage.
- No production approval.

### Next

- Android runtime device/emulator UAT.


## 2026-06-13 — Media Center Mobile Android Runtime Device UAT Pack

### Added

- Android runtime UAT install/launch script.
- Android device/emulator UAT checklist.
- Runtime UAT runbook.
- Evidence closure template.

### Preserved

- No SQL changes.
- No media_center/public schema mutations.
- No public base tables.
- No service-role usage.
- No production approval.


## 2026-06-13 — Android Runtime UAT ADB Locator Windows Hotfix

### Fixed

- UAT script now resolves `adb.exe` from common Windows Android SDK locations.
- Added `-DeviceSerial` parameter for multi-device UAT.

### Preserved

- No SQL changes.
- No Flutter changes.
- No Android build changes.
- No media_center/public schema mutations.
- No public base tables.
- No service-role usage.
- No production approval.


## 2026-06-13 — Android Runtime UAT Device Availability Gate Hotfix

### Fixed

- UAT script now checks for a ready Android device/emulator before APK install.
- Added clearer setup instructions when no device is available.
- Added `-EmulatorName`, `-DeviceSerial`, and `-ListOnly` support.
- Added `scripts/list_android_devices_and_emulators.ps1`.

### Preserved

- No SQL changes.
- No Flutter changes.
- No Android build changes.
- No media_center/public schema mutations.
- No public base tables.
- No service-role usage.
- No production approval.


## 2026-06-13 — Media Center Mobile Development Procedures MD Archive

### Added

- Archived the completed Media Center mobile application development procedures as Markdown.

### File

```text
docs/mobile/MEDIA_CENTER_MOBILE_DEVELOPMENT_PROCEDURES_2026_06_13.md
```

### Preserved

- No code changes.
- No SQL changes.
- No media_center/public schema mutations.
- No public base tables.
- No service-role usage.
- No production approval.


## 2026-06-13 — Media Center Mobile Session Handoff + Updated Baseline

### Added

- Comprehensive session handoff.
- Next session prompt.
- Updated baseline README.
- Next runbook.
- Session decision record.

### Handoff Files

```text
docs/handoff/MEDIA_CENTER_MOBILE_SESSION_HANDOFF_2026_06_13.md
docs/handoff/NEXT_SESSION_PROMPT_MEDIA_CENTER_MOBILE_2026_06_13.md
docs/handoff/UPDATED_BASELINE_README_MEDIA_CENTER_MOBILE_2026_06_13.md
docs/handoff/MEDIA_CENTER_MOBILE_NEXT_RUNBOOK_2026_06_13.md
docs/handoff/MEDIA_CENTER_MOBILE_SESSION_DECISION_RECORD_2026_06_13.md
```

### Current Accepted State

```text
flutter-analyze-clean
cms-tests-passed
android-debug-apk-built
mobile-procedures-md-archived
android-runtime-uat-pending-device
```

### Preserved

```text
no code functional change
no SQL
no media_center/public schema mutation
no public base tables
no service_role
production-not-approved
```

## 2026-06-13 — Platform 12 Web Search Overflow + Section Duplicate Evidence Intake

### Evidence accepted

- `/home/search?q=مسجد` renders search results.
- Browser console reported `RenderFlex overflowed` from the public web app bar under constrained viewport.
- Homepage section diagnostics confirmed canonical duplicate keys and semantic active overlaps.

### Fixed

- Hardened `WebAppBar` with responsive `LayoutBuilder` behavior.
- Collapsed full navigation into compact menu under constrained widths.
- Switched logo to icon-only under narrow widths.
- Reduced app bar padding/gaps under constrained widths.
- Stacked web search results/sidebar under 900px.
- Replaced fixed search-result summary row with wrap-safe layout.

### Added

- Evidence intake document:

```text
docs/platform12/WEB_SEARCH_OVERFLOW_AND_SECTION_DUPLICATES_EVIDENCE_INTAKE_2026_06_13.md
```

- Error record:

```text
docs/platform12/ERROR_RECORD_WEB_SEARCH_OVERFLOW_2026_06_13.md
```

- Guarded duplicate-remediation SQL pack:

```text
sql_sandbox/platform12_homepage_sections_duplicate_remediation_guarded/
```

### SQL status

```text
no-sql-executed
legacy-alias-duplicate-dml-prepared-not-authorized
semantic-family-policy-decision-required
```

### Preserved

- Android runtime UAT remains deferred.
- No SQL executed by this Mega Batch.
- No public base table mutation executed.
- No service-role usage.
- No production approval.

## 2026-06-13 — Platform 12 Home Search Waqf Query + WebAppBar Overflow Closure Mega Batch

### Evidence accepted

- `/home/search?q=مسجد` renders correctly at normal browser width and returns the `المساجد` result.
- `/home/search?q=وقف` with `الوثائق` selected returned an empty result state.
- Chrome DevTools constrained-width evidence still showed `RenderFlex overflowed` from `WebAppBar`.

### Fixed / hardened

- Added waqf-domain coverage to the governed local public-route search index.
- Added `مستكشف الوقف` as a public indexed result pointing to `/mustakshif`.
- Added Arabic normalization and query expansion for `وقف`, `اوقاف`, `الاوقاف`, and related waqf terms.
- Applied equivalent web/mobile search-index behavior for parity.
- Hardened `WebAppBar` with conservative compact navigation threshold, constrained logo width, scaled action strip, fixed compact action controls, and scale-down full navigation.

### Added

```text
docs/platform12/PLATFORM12_HOME_SEARCH_WAQF_QUERY_APPBAR_OVERFLOW_CLOSURE_MEGA_BATCH_2026_06_13.md
docs/platform12/ERROR_RECORD_HOME_SEARCH_WAQF_QUERY_APPBAR_OVERFLOW_2026_06_13.md
docs/platform12/UAT_HOME_SEARCH_WAQF_QUERY_APPBAR_OVERFLOW_2026_06_13.md
docs/platform12/evidence/search_waqf_no_results_narrow_devtools_2026_06_13.png
docs/platform12/evidence/search_masjid_result_normal_width_2026_06_13.png
```

### Current status

```text
platform12-home-search-waqf-query-appbar-overflow-closure-mega-batch-prepared
search-masjid-normal-width-confirmed-by-user-evidence
search-waqf-documents-gap-accepted-and-index-expanded
web-appbar-constrained-width-overflow-hardened
homepage-sections-source-decision-preserved
semantic-family-policy-decision-required
android-runtime-uat-deferred
no-sql-executed
no-service-role
production-not-approved
```

### Preserved

- No SQL executed.
- No public base table mutation.
- No service-role usage.
- No `waqf_assets` mutation.
- Android runtime UAT remains deferred.

## 2026-06-13 — Platform 12 Footer Overflow + Flutter Test Harness Closure Mega Batch

### Evidence accepted

- `flutter analyze` completed with `No issues found`.
- `flutter test` failed because `test/widget_test.dart` still imported `package:palwakf/main.dart` and expected a default `MyApp` counter application.
- `flutter run -d chrome` launched successfully, loaded environment variables, initialized storage and Supabase, and rendered the app.
- The remaining runtime layout error is from `WebFooter`, not `WebAppBar`:

```text
A RenderFlex overflowed by 29 pixels on the right.
Row:file:///C:/Users/DELL/StudioProjects/palwakf/lib/presentation/widgets/web/web_footer.dart:123:13
constraints: BoxConstraints(0.0<=w<=645.0, 0.0<=h<=Infinity)
```

### Fixed / hardened

- Reworked `WebFooter` to use responsive `LayoutBuilder` behavior.
- Replaced the fixed bottom copyright/action `Row` with compact stacked layout under constrained width and `Expanded/Flexible` layout at wider widths.
- Wrapped privacy/terms buttons using `Wrap`.
- Added section wrapping/stacking for narrow footer widths.
- Replaced stale Flutter template `widget_test.dart` with a neutral test-harness guard.

### Added

```text
docs/platform12/PLATFORM12_FOOTER_OVERFLOW_TEST_HARNESS_CLOSURE_MEGA_BATCH_2026_06_13.md
docs/platform12/UAT_FOOTER_OVERFLOW_TEST_HARNESS_CLOSURE_2026_06_13.md
docs/platform12/error_records/ERROR_RECORD_FOOTER_OVERFLOW_AND_STALE_WIDGET_TEST_2026_06_13.md
docs/platform12/evidence/search_waqf_footer_overflow_devtools_2026_06_13.png
docs/platform12/evidence/flutter_analyze_test_run_footer_overflow_log_2026_06_13.txt
ARTIFACT_MANIFEST_platform12_footer_overflow_test_harness_closure_mega_batch_2026_06_13.json
```

### Current status

```text
platform12-footer-overflow-test-harness-closure-mega-batch-prepared
flutter-analyze-clean-accepted-from-user-evidence
flutter-test-stale-template-failure-accepted-and-remediated
webfooter-constrained-width-overflow-hardened
search-waqf-results-confirmed-by-user-evidence
homepage-sections-source-decision-preserved
semantic-family-policy-decision-required
android-runtime-uat-deferred
no-sql-executed
no-service-role
production-not-approved
```

### Preserved

- No SQL executed.
- No public base table mutation.
- No service-role usage.
- No `waqf_assets` mutation.
- Android runtime UAT remains deferred.

## 2026-06-13 — Platform 12 Home Page Section Polish + Semantic Runtime Policy Mega Batch

### Scope

Continued homepage and section refinement after search, WebAppBar, WebFooter, and test-harness closure.

### Fixed / hardened

- Added semantic-family metadata to the canonical homepage section catalog.
- Added runtime family policy for close substitutes:
  - `pwf_news_tabs` supersedes `pwf_news` when both are active.
  - `pwf_eservices_portal` supersedes `pwf_quick_services` when both are active.
  - `pwf_important_links` supersedes `pwf_quick_links_grid` when both are active.
  - `pwf_media_gallery` supersedes split image/video gallery sections only when the unified gallery is active.
- `PwfHomeSectionsRenderer` now applies the semantic policy before rendering, without mutating DB rows.
- Admin homepage section management now exposes semantic-family policy warnings and chips.
- Added semantic policy contract tests.
- Added read-only SQL diagnostic preview for runtime policy decisions.

### Added

```text
docs/platform12/PLATFORM12_HOME_PAGE_SECTION_POLISH_SEMANTIC_POLICY_MEGA_BATCH_2026_06_13.md
docs/platform12/UAT_HOME_PAGE_SECTION_POLISH_SEMANTIC_POLICY_2026_06_13.md
docs/platform12/error_records/ERROR_RECORD_HOME_SEMANTIC_SECTION_OVERLAP_2026_06_13.md
sql_sandbox/platform12_home_sections_semantic_policy_audit_read_only/01_home_sections_semantic_policy_runtime_preview.sql
test/features/platform/home/pwf_home_sections_semantic_policy_test.dart
ARTIFACT_MANIFEST_platform12_home_page_section_polish_semantic_policy_mega_batch_2026_06_13.json
```

### Current status

```text
platform12-home-page-section-polish-semantic-policy-mega-batch-prepared
semantic-family-runtime-policy-added
homepage-runtime-section-overlap-reduced-without-sql
admin-section-policy-visibility-added
semantic-policy-contract-test-added
footer-overflow-prior-closure-preserved
android-runtime-uat-deferred
no-sql-executed
no-service-role
production-not-approved
```

### Preserved

- No SQL executed.
- No public base table mutation.
- No service-role usage.
- No `waqf_assets` mutation.
- Android runtime UAT remains deferred.

## 2026-06-13 — Platform 12 Gallery + Activities Duplicate Closure Mega Batch

### Scope

Closed the remaining semantic repetition reported by the user on the public homepage for:

- Media gallery / image gallery.
- Activities / standalone events.

### Fixed / hardened

- Changed `media_gallery_family` runtime policy from partial unified-supersedes behavior to one-representative rendering.
- Kept priority order: `pwf_media_gallery` → `pwf_media_gallery_images` → `pwf_media_gallery_videos`.
- Merged activities and events into `activities_events_family`.
- Kept `pwf_activities` as the preferred canonical homepage representative over `pwf_events_section`.
- Removed the Events tab from `PwfMediaGallerySection`; gallery now displays visual media only: photos and videos.
- Expanded legacy/canonical aliases for gallery, image gallery, video gallery, activities, and events section keys.
- Updated the read-only SQL semantic policy preview to reflect the new one-representative rules.
- Expanded semantic policy contract tests to cover gallery split suppression and activities/events suppression.

### Added

```text
docs/platform12/PLATFORM12_GALLERY_ACTIVITIES_DUPLICATE_CLOSURE_MEGA_BATCH_2026_06_13.md
docs/platform12/UAT_GALLERY_ACTIVITIES_DUPLICATE_CLOSURE_2026_06_13.md
docs/platform12/error_records/ERROR_RECORD_GALLERY_ACTIVITIES_DUPLICATE_2026_06_13.md
ARTIFACT_MANIFEST_platform12_gallery_activities_duplicate_closure_mega_batch_2026_06_13.json
```

### Current status

```text
platform12-gallery-activities-duplicate-closure-mega-batch-prepared
media-gallery-one-representative-runtime-policy-added
activities-events-one-representative-runtime-policy-added
gallery-events-tab-removed-to-avoid-semantic-duplication
semantic-policy-contract-tests-expanded
homepage-sections-source-decision-preserved
footer-overflow-prior-closure-preserved
android-runtime-uat-deferred
no-sql-executed
no-service-role
production-not-approved
```

### Preserved

- No SQL executed.
- No public base table mutation.
- No service-role usage.
- No `waqf_assets` mutation.
- Android runtime UAT remains deferred.

## 2026-06-13 — Platform 12 Media Gallery Compile Boundary Closure Mega Batch

### Scope

Closed a Flutter web compile blocker reported after the gallery/activities duplicate-closure Mega Batch.

### Evidence accepted

Chrome runtime failed while compiling `PwfMediaGallerySection` because stale activity helpers remained after removing the gallery events tab:

```text
Type 'Activity' not found.
Type 'ActivityType' not found.
```

### Fixed / hardened

- Removed stale `_GalleryCardData.fromActivity(Activity a)` from the compiled media gallery section.
- Removed stale `_activityTypeAr(ActivityType t)` from the compiled media gallery section.
- Preserved the gallery content boundary as visual media only: photos/videos.
- Kept activities/events under the activities section and outside the gallery tabs.
- Updated the legacy/mirror gallery surface for consistency.
- Added a source-boundary contract test to prevent reintroducing activity/event dependencies into `PwfMediaGallerySection`.

### Added

```text
docs/platform12/PLATFORM12_MEDIA_GALLERY_COMPILE_BOUNDARY_CLOSURE_MEGA_BATCH_2026_06_13.md
docs/platform12/UAT_MEDIA_GALLERY_COMPILE_BOUNDARY_CLOSURE_2026_06_13.md
docs/platform12/error_records/ERROR_RECORD_MEDIA_GALLERY_ACTIVITY_STALE_REFERENCE_2026_06_13.md
test/features/platform/home/pwf_media_gallery_source_boundary_test.dart
ARTIFACT_MANIFEST_platform12_media_gallery_compile_boundary_closure_mega_batch_2026_06_13.json
```

### Current status

```text
platform12-media-gallery-compile-boundary-closure-mega-batch-prepared
media-gallery-stale-activity-references-removed
media-gallery-visual-media-only-boundary-preserved
activities-events-section-ownership-preserved
source-boundary-contract-test-added
homepage-sections-source-decision-preserved
android-runtime-uat-deferred
no-sql-executed
no-service-role
production-not-approved
```

### Preserved

- No SQL executed.
- No public base table mutation.
- No service-role usage.
- No `waqf_assets` mutation.
- Android runtime UAT remains deferred.


## 2026-06-13 — Platform 12 Home Management Runtime Alignment Mega Batch

### Scope

Aligned the public home page runtime with `/admin/home-management` so section hide/show and repositioning are not overridden by global/unscoped fallback rows.

### Cause accepted

The homepage runtime merged multiple scopes but could prefer an active fallback/global row over a more specific admin-scoped inactive row. This made admin changes appear unreliable. Semantic `preferOne` families could also be saved with multiple active representatives even though the renderer later suppressed siblings.

### Implemented

- Added scope-specific row precedence in `HomepageRepository.fetchAllSectionsForUnit`:
  current unit → home unit → global sentinel → unscoped legacy.
- Removed active-row preference from effective row selection.
- Added admin-side semantic family enforcement in `PwfHomepageSectionsManager`.
- Activating one representative in a `preferOne` family now deactivates siblings immediately.
- New sections added from the admin catalog are inactive by default until explicitly enabled.
- Added a source-contract test for admin/runtime alignment.

### Added

```text
docs/platform12/PLATFORM12_HOME_MANAGEMENT_RUNTIME_ALIGNMENT_MEGA_BATCH_2026_06_13.md
docs/platform12/UAT_HOME_MANAGEMENT_RUNTIME_ALIGNMENT_2026_06_13.md
docs/platform12/error_records/ERROR_RECORD_HOME_MANAGEMENT_RUNTIME_SCOPE_MERGE_MISMATCH_2026_06_13.md
test/features/platform/home/pwf_home_admin_runtime_alignment_contract_test.dart
ARTIFACT_MANIFEST_platform12_home_management_runtime_alignment_mega_batch_2026_06_13.json
```

### Current status

```text
platform12-home-management-runtime-alignment-mega-batch-prepared
runtime-section-scope-precedence-hardened
admin-home-management-hide-order-active-state-now-wins-over-global-fallbacks
admin-semantic-family-single-active-enforcement-added
new-admin-catalog-section-default-inactive
home-management-runtime-alignment-contract-test-added
android-runtime-uat-deferred
no-sql-executed
no-service-role
production-not-approved
```

### Preserved

- No SQL executed.
- No public base table mutation.
- No service-role usage.
- No `waqf_assets` mutation.
- Android runtime UAT remains deferred.

## 2026-06-13 — Platform 12 Home Management Unique Scope Write Closure Mega Batch

### Scope

Closed the `/admin/home-management` duplicate-key failure reported from browser evidence:

```text
PostgrestException(message: duplicate key value violates unique constraint "ux_homepage_sections_scope", code: 23505)
```

### Cause accepted

The admin surface was checking existing homepage section rows through `public.v_platform_homepage_sections_compat_v1` before inserting into `public.homepage_sections`. The compatibility view is a runtime read surface and may not expose every inactive/scoped row present in the preserved write table. The insert could therefore collide with the unique scope constraint.

### Implemented

- Hardened `HomepageRepository.saveSectionsMeta` with write-surface conflict detection.
- Added guarded insert-or-update behavior and 23505 retry-as-update fallback.
- Canonicalized section names before admin writes.
- Expanded legacy/canonical aliases for activities/events/gallery families.
- Hardened `PwfUnitPagesRepository` section writes against the same duplicate-scope failure.
- Added source contract test for the admin unique-scope write rule.
- Added read-only SQL diagnostics for exact/canonical scope duplicates.

### Added

```text
docs/platform12/PLATFORM12_HOME_MANAGEMENT_UNIQUE_SCOPE_WRITE_CLOSURE_MEGA_BATCH_2026_06_13.md
docs/platform12/UAT_HOME_MANAGEMENT_UNIQUE_SCOPE_WRITE_CLOSURE_2026_06_13.md
docs/platform12/error_records/ERROR_RECORD_HOME_MANAGEMENT_UNIQUE_SCOPE_DUPLICATE_KEY_2026_06_13.md
docs/platform12/evidence/admin_home_management_duplicate_key_ux_homepage_sections_scope_2026_06_13.png
sql_sandbox/platform12_home_management_unique_scope_write_diagnostics_read_only/01_homepage_sections_unique_scope_diagnostics_read_only.sql
test/features/platform/home/pwf_home_admin_unique_scope_write_contract_test.dart
ARTIFACT_MANIFEST_platform12_home_management_unique_scope_write_closure_mega_batch_2026_06_13.json
```

### Current status

```text
platform12-home-management-unique-scope-write-closure-mega-batch-prepared
admin-home-management-23505-duplicate-scope-evidence-accepted
write-surface-conflict-detection-hardened
compat-view-runtime-read-preserved
admin-legacy-write-surface-preserved-until-owner-rpc-approval
home-management-runtime-alignment-preserved
android-runtime-uat-deferred
no-sql-executed
no-service-role
production-not-approved
```

### Preserved

- No SQL executed.
- No public base table schema change.
- No service-role usage.
- No `waqf_assets` mutation.
- Android runtime UAT remains deferred.

## 2026-06-13 — Platform 12 — Home Management Toggle Persistence Closure Mega Batch

- Accepted browser evidence that a section enabled in `/admin/home-management` can revert to inactive immediately after Save.
- Root cause: the admin manager still reloaded from the public compatibility/runtime read surface, while the write path targets preserved `public.homepage_sections`. Inactive/scoped write rows can be omitted or overridden by compatibility/readback behavior.
- Added admin-only write-surface readback methods in `HomepageRepository`:
  - `fetchAllSectionsForAdmin()`
  - `fetchAllSectionsForAdminUnit(...)`
- Repointed `PwfHomepageSectionsManager` load/reload to the admin write-surface readback, while preserving runtime reads through `public.v_platform_homepage_sections_compat_v1` for the public homepage.
- Hardened write conflict lookup to prefer canonical `section_name` rows before legacy aliases. This prevents toggling a canonical section while the write path updates a legacy alias row and leaves the canonical row inactive.
- Added contract test `pwf_home_admin_write_surface_readback_contract_test.dart`.
- Added read-only SQL diagnostics for toggle/readback mismatches.
- No SQL executed. No service-role usage. Production not approved.

## 2026-06-13 — Platform 12 — Home Management Save Feedback + Runtime Visibility Closure Mega Batch

- Accepted operator evidence that a section can be enabled and saved in `/admin/home-management` without a confirmation message, then remain visible in the admin panel but absent from `/home`.
- Added explicit save confirmation feedback in the admin screen after a successful save.
- Invalidated homepage runtime providers after save so `/home` does not keep stale section metadata in the Riverpod cache.
- Preserved `public.v_platform_homepage_sections_compat_v1` as the base runtime read surface while adding a fail-open overlay from the preserved admin write surface `public.homepage_sections` until owner-write/read RPC closure is approved.
- Made DB-enabled `pwf_public_services_catalog` visibly render an empty-state block from homepage runtime when its data source is empty, preventing silent disappearance of an enabled section.
- Added contract test `test/features/platform/home/pwf_home_admin_runtime_visibility_contract_test.dart`.
- Added read-only SQL diagnostics for write-active rows missing from the runtime compatibility view.
- No SQL executed. No service-role usage. Production not approved.

## 2026-06-13 — Platform 12 — Homepage Management Sovereign Runtime Contract Mega Batch

- Accepted the architectural decision to stop incremental UI remediation and move to a sovereign runtime contract for `/admin/home-management` and `/home`.
- Added RPC-first repository integration for homepage section admin state, save state, and runtime state. Fallback is preserved only until SQL is applied in the target environment.
- Added `rpc_homepage_sections_registry_v1`, `rpc_homepage_sections_admin_state_v1`, `rpc_homepage_sections_save_state_v1`, and `rpc_homepage_sections_runtime_v1` SQL definitions under guarded `sql_apply`.
- Added a governed section registry inside Flutter: every section now has a family, source kind, owner label, renderer key, and contract note.
- Isolated breaking news as its own sovereign alerts family so it no longer disappears inside normal news. Enabled breaking news now renders a governed empty state when no items are published.
- Kept media gallery ownership limited to photos/videos and kept activities/events inside their own family.
- Removed physical delete from the admin save path; duplicate representatives are removed from runtime by deactivation through the save RPC design.
- Added admin chips showing section family, source, owner, empty-state capability, and contract notes.
- Added contract test `test/features/platform/home/pwf_homepage_sovereign_runtime_contract_test.dart`.
- SQL prepared, not executed. No service-role usage. Production not approved. Android runtime UAT remains deferred.

## 2026-06-13 — Platform 12 — Homepage Visual Contract Alignment Mega Batch

- Accepted the requirement to unify the visual formatting of all homepage sections according to the platform governing contract.
- Added a centralized visual system for public homepage sections in `PwfHomeVisualContract`.
- Added reusable visual primitives: `PwfVisualCard`, `PwfVisualIconTile`, `PwfVisualChip`, `PwfVisualEmptyState`, and `PwfVisualResponsiveGrid`.
- Repointed `PwfSectionContainer` to the centralized section background and spacing policy.
- Repointed `PwfSectionTitle` to the centralized typography/divider/subtitle scale using the approved blue/gold/royal-red identity.
- Wrapped breaking news in the common homepage section container while preserving its independent sovereign-alert family and without merging it with general news.
- Added contract test `test/features/platform/home/pwf_home_visual_contract_test.dart`.
- Preserved the Homepage Management Sovereign Runtime Contract and did not alter admin/runtime visibility semantics.
- No SQL executed. No service-role usage. Production not approved. Android runtime UAT remains deferred.

## 2026-06-13 — Platform 12 — Public Subpages Visual Contract + About/Vision Development Mega Batch

- Accepted the requirement to extend the homepage visual contract to all public subpages opened from the homepage/navigation surface.
- Reused `PwfHomeVisualContract` and its reusable primitives across public content pages, platform frontend hub pages, and static placeholder pages.
- Developed `/about` with a richer institutional ministry overview, work areas, digital transformation narrative, and ministry/directorate unit relationship.
- Developed `/vision-mission` with clear vision, mission, work pillars, and governing values aligned with PalWakf governance language.
- Reworked `_PwfContentPage` into a unified subpage visual pattern: sovereign hero, responsive visual grid, visual section cards, and governed actions.
- Reworked platform frontend hub cards, metrics, section titles, and info blocks to use centralized visual primitives and the approved blue/gold/royal-red identity.
- Reworked static placeholder pages to show governed empty states instead of unmanaged ad-hoc cards.
- Added contract test `test/features/platform/home/pwf_home_subpages_visual_contract_test.dart`.
- Preserved the Homepage Management Sovereign Runtime Contract and did not alter admin/runtime visibility semantics.
- No SQL executed. No service-role usage. Production not approved. Android runtime UAT remains deferred.

## 2026-06-13 — Platform 12 — Homepage First Fold Visual Refinement Mega Batch

- Accepted operator requirements for targeted homepage visual refinements after the sovereign runtime contract and visual contract alignment batches.
- Reworked `PwfBreakingNewsMarquee` into a full-width sovereign alert strip aligned with the hero first-fold surface instead of a detached section card.
- Hardened `PwfPublicImage` so network and local fallback images expand to the full allocated box with `SizedBox.expand`, explicit width/height, and `BoxFit.cover`, preventing gray bands below hero imagery.
- Tightened `PwfHomeVisualContract.sectionBackground` to use one continuous homepage background surface, reducing visible orphan bands when sections are disabled/reordered from `/admin/home-management`.
- Removed redundant outer spacing from minister word and e-services sections where `PwfSectionContainer` already owns page rhythm.
- Enhanced `PwfNewsSection` with a second featured complementary/subordinate-unit news card below the primary story when data exists.
- Added thumbnails/fallback thumbnails to side news cards and complementary news cards.
- Reworked e-services governance chips into a one-line horizontally scrollable governance row instead of multi-row wrapping.
- Made the scroll-to-top button hidden on first load and visible only after scrolling beyond approximately half the first viewport.
- Added `test/features/platform/home/pwf_homepage_first_fold_visual_refinement_test.dart`.
- No SQL executed. No service-role usage. Production not approved. Android runtime UAT remains deferred.

## 2026-06-15 — Platform 12 — Homepage Surface Continuity + Hero Height Closure Mega Batch

- Accepted user evidence that the hero image felt vertically pulled upward and that the hero needs an additional first-fold height allowance matching the supplied 54px evidence strip.
- Increased and rebalanced `PwfHeroSliderSection` height with a desktop `54px` extension, a controlled mobile/tablet extension, and a viewport-aware first-fold target.
- Adjusted hero image focal alignment to reduce the visual impression that the image is pulled upward while preserving `BoxFit.cover`.
- Repointed the public homepage light-mode canvas and section background contract to `PwfHomePalette.surface` to prevent orphan grey bands between sections.
- Removed the extra blue-tinted outer background from `PwfStatsSection`; `PwfSectionContainer` now owns the statistics section surface and rhythm.
- Preserved the scroll-to-top threshold behavior, sovereign homepage management runtime contract, and RPC-first strategy.
- Added `test/features/platform/home/pwf_homepage_surface_continuity_hero_height_test.dart` and adjusted the visual contract test to match the current breaking-news semantics label.
- No SQL executed. No service-role usage. Production not approved. Android runtime UAT remains deferred.


## 2026-06-15 — Platform 12 — Homepage Adaptive Hero + Surface Band Closure Mega Batch

- Accepted retest evidence that the hero still felt visually pulled upward and that disabling the breaking-news strip requires the hero to flex as the true first-fold block before lower homepage sections.
- Increased the desktop first-fold target to `viewportHeight * 0.80`, raised the hero allowance to `86px` on desktop and `42px` on narrow layouts, and rebalanced base hero heights.
- Lowered the hero image focal point to `Alignment(0, 0.36)` so DB-managed hero images reveal more of the lower visual field while preserving full-bleed `BoxFit.cover` with no grey image gaps.
- Removed the external gradient/margin wrapper from `PwfMediaGallerySection`; the gallery now participates directly in the shared `PwfSectionContainer` canvas and no longer leaves grey/foreign bands above or below when neighboring sections are hidden.
- Wrapped runtime-rendered homepage sections in a white sovereign section slot inside `PwfHomeSectionsRenderer` to prevent transparent or legacy outer wrappers from exposing non-contract page backgrounds.
- Expanded `pwf_homepage_surface_continuity_hero_height_test.dart` to guard adaptive first-fold height, lowered focal point, gallery no-band behavior, and renderer surface-slot behavior.
- No SQL executed. No service-role usage. Production not approved. Android runtime UAT remains deferred.

## 2026-06-15 — Platform 12 — Public Subpages Unified Visual Polish Mega Batch

- Accepted operator evidence that homepage-derived public subpages still appeared visually mixed after homepage visual alignment: inconsistent hero widths, card rhythm, typography, static placeholders, and always-visible scroll utility.
- Reworked `PwfPublicIntroCard` into a full-width responsive sovereign public-subpage hero using `PwfHomeVisualContract`, `PwfVisualIconTile`, and `PwfVisualChip`.
- Reworked public stats, surface cards, badges, loading states, and empty states to use the centralized visual primitives instead of legacy/ad-hoc wrappers.
- Updated `PwfWebPageScaffold` so the light-mode page canvas uses `PwfHomePalette.surface` and scroll-to-top is hidden on first load until the user scrolls beyond roughly 55% of the viewport.
- Reworked platform frontend hub hero/action cards to use one reusable visual rhythm while preserving each page's content family and actions.
- Reworked static placeholder pages to use the same public intro and governed empty-state pattern rather than a standalone card-only layout.
- Rebalanced CMS/static subpage hero height and icon treatment to match the public subpage contract.
- Added contract test `test/features/platform/home/pwf_public_subpages_unified_visual_polish_test.dart`.
- No SQL executed. No service-role usage. Production not approved. Android runtime UAT remains deferred.

## 2026-06-15 — Platform 12 — Public Subpages Visual System Rework Mega Batch

- Accepted operator decision to stop page-by-page visual polishing and rework public subpages through one shared visual system.
- Added compact public-subpage spacing in `PwfHomeVisualContract` and routed public subpage sections through that density in `PwfSectionContainer`.
- Reworked `PwfPublicIntroCard` into a smaller masthead-style citizen-facing page header with stronger contrast and reduced title-box height.
- Added filtering for technical notes in public intro cards so RPC/RLS/fallback/source/governance details are not rendered in the public citizen surface.
- Reworked public stats cards and surface cards into denser shared visual primitives.
- Reworded public services request status from technical RPC/fallback/backend language into citizen-facing status language.
- Collapsed public service governance notes and platform center governance strips from public page rendering; governance remains in admin docs/runbooks.
- Reworded visible platform frontend labels from technical governance language into public UX language.
- Added `test/features/platform/home/pwf_public_subpages_visual_system_rework_test.dart`.
- No SQL executed. No service-role usage. Production not approved. Android runtime UAT remains deferred.

## 2026-06-15 — Platform 12 — Public Subpages Analyze/Test Contract Closure Mega Batch

- Accepted local `flutter analyze` and `flutter test` evidence after the public-subpages visual-system rework.
- Fixed invalid `FontWeight.w650` usages in `PwfHomeVisualContract` by using valid Flutter font weights while preserving stronger public text contrast.
- Added a centralized `alertAccent` token in `PwfHomeVisualContract` mapped to `PwfHomePalette.royalRed` so the blue/gold/royal-red visual identity remains present in the contract.
- Removed the unused `_ContentCard` class from `pwf_static_pages.dart` after the static pages moved to the shared public intro/empty-state pattern.
- Removed an unnecessary duplicate-row type check in `pwf_unit_pages_repository.dart`.
- Rebased stale contract tests to the compact public-subpage masthead heights and current guarded write-surface lookup wording.
- No SQL executed. No service-role usage. Production not approved. Android runtime UAT remains deferred.

## 2026-06-15 — Platform 12 — Public Governance Residue + Test Harness Closure Mega Batch

- Accepted local evidence that public subpages still exposed residual technical governance language after the visual-system rework and that the local suite still had one unused import warning plus a stale Flutter template test failure.
- Removed remaining citizen-facing technical labels from public subpages: `SQL UAT`, `backend-first`, visible `fallback` badges, `unitSlug` renderer wording, and public references to `waqf_assets` in homepage-derived public content.
- Removed the unused `PwfHomePalette` import from `pwf_static_pages.dart` to close the last local `flutter analyze` warning.
- Replaced the stale root `test/widget_test.dart` template binding with a neutral harness test that does not import an obsolete package name or `MyApp`.
- Added `test/features/platform/home/pwf_public_governance_residue_closure_test.dart` to prevent re-exposing technical governance residue in public pages and to guard the stale widget-test closure.
- Public technical governance remains allowed in admin screens, runbooks, diagnostics, and SQL/RPC design files, but not in citizen-facing pages.
- No SQL executed. No service-role usage. Production not approved. Android runtime UAT remains deferred.


## 2026-06-16 — Platform 12 — Public Subpages Full Visual Audit + Governance Residue Closure Mega Batch

- Accepted new browser evidence that several public subpages still needed full visual refinement and that governance/source metadata was still visible on `/home/chat`, `/home/zakat`, and related public tools.
- Reworked `PwfPublicInteractiveToolShell` so public interactive pages no longer render route/source/readiness banners; technical binding remains internal documentation only.
- Hardened `PwfPublicIntroCard` to suppress governance/developer notes and replace technical subtitles with citizen-facing fallback copy when needed.
- Reduced public-subpage vertical density and masthead heights to make better use of the space below the platform toolbar.
- Reworded Zakat public page and calculator status copy from wrapper/fallback/PWF-SIS language into public-friendly guidance.
- Reworded the public chatbot top notice so it explains the current page context without showing source allowlists or source contracts.
- Rebuilt the complaints page header to use the shared public masthead and removed the second oversized dark header block.
- Reworded public frontend hub labels and service-tracking status chips so technical source labels are not shown to visitors.
- Updated contract tests for the denser masthead system and added coverage for interactive public tools hiding source/governance residue.
- No SQL executed. No service-role usage. Production not approved. Android runtime UAT remains deferred.
