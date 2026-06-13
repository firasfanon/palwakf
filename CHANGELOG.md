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
