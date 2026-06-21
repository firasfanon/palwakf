# PalWakf Platform Comprehensive Guide — Platform 13 addendum

The public-unit operating boundary is now specified as:

`route slug -> core.org_units.id -> owner profile/composition/content -> Flutter`.

The path excludes `public.*` runtime dependencies. Unit profile, verified social links, content, composition, and administration must remain scoped by `org_unit_id`. Public error pages must never render raw database diagnostics.

---

## Platform 13 — Unit Public Sovereign Operational Closure (2026-06-19)

### Approved operating rule

```text
route slug → core.org_units.id → owner schema Profile/Composition/Content → Flutter
```

### Owner boundaries

| Domain | Owner schema | Public runtime condition |
|---|---|---|
| Unit identity | `core.org_units` | canonical public route resolves to unit UUID |
| Hero/contact/footer | `core.org_unit_public_profiles` | profile must be `published` |
| Social links | `core.org_unit_social_links` | link must be `verified + published + public` |
| Page composition | `platform_experience.org_unit_public_compositions` | entry must be `published` |
| Unit content | `media_center.unit_public_content_records` | content must be `published` |
| Workflow audit | `media_center.unit_public_content_workflow_events` | internal only |

### Security rule

The existing `core.user_scope_assignments` and `core.user_scope_assignment_units` remain the single RBAC truth. Owner write operations are guarded by schema RPCs; Flutter never holds `service_role`, and raw public base-table writes are not part of this runtime.

### Pending gates

SQL staging apply, API schema exposure, role-negative UAT, Browser/Mobile evidence, analyzer/test/web build, and production approval.

## Platform 13 — Media Center API Exposure + Runtime Read Contract (2026-06-20)

### Root cause

The owner schema `media_center` was absent from the Supabase/PostgREST exposed-schema list, producing `PGRST106` and HTTP 406 for schema-qualified Flutter reads. This is an API configuration gate, not a data, RLS, or widget-layout failure.

### Enforced public contract

- Public Flutter reads use `client.schema('media_center')` only for named owner runtime views.
- Route context resolves to `owner_org_unit_id` before content filtering.
- No public fallback is permitted to legacy `public.news`, `public.announcements`, `public.activities`, or `public.media_gallery_items`.
- No fabricated/sample content may be substituted on owner runtime failure.
- The UI must render a safe Arabic recovery message, never raw PostgREST/schema diagnostics.
- Exposing `media_center` in the Supabase Dashboard must be followed by narrowly scoped schema usage and SELECT grants on the nine runtime views only.

### Certification requirements

Dashboard exposure confirmation, guarded SQL validation, Flutter analyze/test/web-build outputs, browser Network evidence for `/home` and unit routes, and mobile retest remain mandatory before promotion.


---

## Platform 14 — Flutter Detail Runtime Binding Closure (2026-06-20)

### Correction / supersession

For public Media Center data, the prior notion that Flutter should read owner views directly is superseded by the least-privilege public edge:

```text
Flutter public list    -> public.rpc_public_media_feed_v2
Flutter public detail  -> public.rpc_public_media_detail_v2
Owner views            -> internal source only
media_center schema    -> not in Supabase Exposed Schemas
```

### Mandatory detail rule

A public details page must call the detail RPC with exact `unit_ref + content_id + family_key` on fresh navigation and refresh. It must not reconstruct a record from a Feed list, state extra, memory cache, first N rows, or direct `media_center` REST.

### Route identity rule

Legacy DTO `int id` may be a nonreversible compatibility hash. Public navigation must preserve the server issued opaque `content_id` as `runtimeContentId`/`publicDetailId`. Hash-only legacy links are not permitted to trigger a feed scan.

### Current gate

Static binding audit passed. Flutter analyzer/test/web release build, Browser Detail RPC 200, no-direct-REST negative evidence, scope-negative evidence, and Android UAT are pending. Production is not approved.

---

## Platform 14 — Canonical Home Unit Resolver Correction + Homepage Composition Runtime Closure (2026-06-20)

### Incident evidence
The public `/home` route requested homepage Composition with UUID `8e83f304-427f-4e97-b07a-53bc6d048be2`. SQL confirmed that identifier is not present in `core.org_units`. The official Ministry record is:

```text
slug = home
id   = de83f304-427f-4e97-b07a-53bc6d048be2
```

### Mandatory identity rule

```text
route slug → owner profile runtime → source_payload.id → owner composition/content scope
```

`source_payload.id` is the canonical `core.org_units.id` and takes precedence over top-level runtime identifiers when they disagree. Flutter must not hardcode a Ministry UUID, create duplicate Composition entries for stale IDs, or fall back to global/legacy public homepage sections after resolver failure.

### Current gate

```text
CANONICAL_HOME_UNIT_RESOLVER_CODE_PREPARED
BROWSER_RELEASE_HOMEPAGE_COMPOSITION_UAT_PENDING
UNIT_REGRESSION_UAT_PENDING
MOBILE_UAT_PENDING
PRODUCTION_NOT_APPROVED
```


---

## Platform 14 — Header Repository Return-Type Compile Hotfix (2026-06-20)

### Compile boundary rule

`_fetchByInternalSlug` and `_fetchByUnitId` return `HeaderSettings?` after they map the raw PostgREST response. A caller must return that model directly; it must not send the model through `_fromRuntimeProfile`, which accepts only a raw `Map<String, dynamic>`.

### Scope and safety

This is a Flutter-only compile repair. It does not alter canonical unit resolution, homepage Composition data, owner-surface contract, RLS/ACL, exposed schemas, or public API behavior. The compile gate must pass before homepage browser UAT resumes.


---

## Platform 14 — Ministry Homepage Composition Publication Governance (2026-06-20)

### Canonical source

- Ministry public home resolves to `core.org_units.slug = home`, UUID `de83f304-427f-4e97-b07a-53bc6d048be2`.
- Composition source is `platform_experience.org_unit_public_compositions`.
- Public runtime view emits only `status = published`.

### Publishing rule

The Ministry Home Composition must transition through: `draft → review → approved → published`. No direct SQL status update is allowed. Approval and publication are authenticated, scoped, and separated from the original composer. Owner-schema workflow audit events capture each transition and its composition snapshot.

### Current operational finding

At evidence time, all 32 ministry composition rows were draft. This is the direct reason `/#/home` rendered a blank body while the public Shell remained visible.

---

## Platform 14 — Global Super User Effective Authority Resolution + Unit Surfaces Workflow UI Gate Closure (2026-06-20)

### Evidence

A protected active Super User could submit the Ministry Home Composition to review even though physical `platform_access.user_scope_assignments` and `public.rpc_user_scope_assignments_list_v1` returned no rows. The UI scope reader was therefore incomplete: it represented explicit unit scope only and omitted global Super User authority already enforced by owner workflow contracts.

### Canonical rule

```text
Effective unit-surface authority
= derived active protected super_admin authority
  OR explicit active site scope applying to target unit
```

Physical scope rows remain source of truth for delegated/non-superuser unit authority. The derived superuser row is not persisted as a fake scope assignment.

### UI workflow rule

The Unit Surfaces governance panel reads the authenticated Composition admin list to determine its actual status. It must only offer the next valid action:

```text
draft → submit_review
review → approve
approved → publish
published → archive (if authorized by a separate lifecycle decision)
```

Workflow RPCs retain final four-eyes enforcement.

### Current gate

```text
EFFECTIVE_AUTHORITY_CONTRACT_PREPARED
MINISTRY_HOME_COMPOSITION_STATUS_REVIEW
STAGING_APPLY_AND_BROWSER_UAT_PENDING
PRODUCTION_NOT_APPROVED
```


---

## Platform 14 — Universal Super Admin Authority Contract (2026-06-20)

- Canonical root source: `platform_access.admin_users` with active `is_superuser=true` and `role=super_admin`.
- Super Admin has universal direct authority over all units, registered systems, protected routes, operational surfaces, activation states, publication workflows and platform administration.
- No synthetic unit/system scopes are created for Super Admin.
- Non-superuser roles remain constrained by existing RBAC, scope and separation-of-duties contracts.
- Flutter must hydrate global authority through `public.rpc_platform_effective_authority_v1`; compatibility views are fallback only for ordinary users.
- Owner-side actions must preserve audit evidence; this authority contract is not a license for unaudited direct table writes.

---

## Platform 14 — Universal Super Admin Flutter Effective Authority Adoption (2026-06-20)

- Database Foundation is already applied: `platform_access.fn_is_active_super_admin_v1(uuid)` and parameterless `public.rpc_platform_effective_authority_v1()`.
- Flutter adoption is aligned to the actual owner DTO and self-scoped `auth.uid()` contract; it must not send `p_user_id`.
- A verified owner-side `super_admin` produces a universal `AccessProfile` before compatibility role/unit-scope hydration, allowing existing Sidebar, GoRouter, static-system, dynamic-system, and UI guard short-circuits to operate consistently.
- Compatibility role/permission data remains ordinary-user fallback only and cannot independently establish universal authority.
- Session auth events clear client authority cache before the next router guard decision.
- Pending: local Flutter compile/test/build plus positive and negative browser UAT. Domain RPC authorizer adoption remains a separate controlled wave.

---

## Platform 14 — Final Consolidated Handoff Status (2026-06-21)

- Foundation Database Authority is applied and validated in Staging through `platform_access.fn_is_active_super_admin_v1(uuid)` and `public.rpc_platform_effective_authority_v1()`.
- The current Flutter candidate baseline includes authority adoption, role-aware subpage surfaces, SystemKey namespace correction, and Core Org Units schema qualification repair.
- Browser evidence previously revealed `core.core.org_units` PGRST205; code is prepared to resolve it through owner-schema relation splitting, but final baseline browser UAT is still required.
- Super User UI visibility does not certify database-side domain write/publication authority. Those waves remain pending after final Flutter UAT.
- Media Center direct public schema exposure remains blocked; production is not approved.
- Canonical continuation: `SESSION_HANDOFF_PLATFORM14_FINAL_CONSOLIDATED_2026_06_21.md`.

---

## Platform 15 — Final Authority Runtime Verification + Core Org Units Schema Closure Result Intake (2026-06-21)

### Nature and boundary

This is a validation, integration, governance, and approval-gate batch. It does not apply SQL, alter RLS/ACL/GRANT/REVOKE, mutate business data, expose schemas, or approve production.

### Static baseline finding

The current candidate source statically contains the Universal Super Admin Flutter adoption, role-aware subpage action markers, `core/enums` `SystemKey` import repair, and the owner-schema `org_units` query pattern. No `core.core.org_units` literal or `schema('core').from(PwfDatabaseOwnerSurfaces.orgUnits)` composition was found under `lib/**/*.dart`.

### Non-negotiable runtime evidence

Acceptance requires all of the following on the same current baseline:

```text
flutter test (authority, role-aware, core org-units contracts)
flutter analyze
flutter build web --release
static verifier outputs
Super User Browser UAT (Dashboard, My Activity, Unit Surfaces, System Surfaces)
rpc_platform_effective_authority_v1 = HTTP 200 with canonical DTO
absence of core.core.org_units and PGRST205
ordinary scoped-user negative UAT
```

UI action visibility is not evidence that a domain publication or approval RPC succeeds. Any domain action must provide actual RPC/network result and owner audit evidence in its separate controlled wave.

### Current gate

```text
STATIC_SOURCE_CONTRACTS_PASSED_RUNTIME_EVIDENCE_PENDING
DATABASE_SIDE_DOMAIN_AUTHORIZER_WAVE_NOT_STARTED
MEDIA_CENTER_SECURITY_WORKSTREAM_UNCHANGED_AND_ISOLATED
PRODUCTION_NOT_APPROVED
```



---

## Platform 15A — Local Evidence Intake + Static Verifier Hotfix (2026-06-21)

- Accepted local evidence: the Core Org Units schema-qualification contract test passed (`+2`), and `flutter build web --release` completed with `Built build\web`.
- `flutter analyze` reported 13 warnings, so analyzer gate remains open; compilation errors were not reported in the supplied output.
- `platform14_verify_core_org_units_schema_qualification.ps1` had a PowerShell parser defect caused by invalid quote escaping. A tooling-only correction is supplied; actual rerun evidence remains required.
- Platform 15 runner was not executed because a literal placeholder path was passed. Use the real project root or `(Get-Location).Path`.
- Authority contract test, role-aware subpage contract test, static verifier suite, Super User browser UAT, and ordinary scoped-user negative UAT are still pending.
- No Flutter application source, SQL, RLS, grants, exposed schemas, public fallback, or Media Center behavior changed in this intake/hotfix. Production remains unapproved.

---

## Platform 15 — Public Homepage Hero Islamic Landmarks Visual Identity Closure Mega Batch (2026-06-21)

### Nature and boundary

- **Nature:** Flutter public-surface development, local asset integration, visual identity governance, and runtime-evidence preparation.
- **Scope:** Ministry `/home` Hero only.
- **Excluded:** SQL, database mutation, RLS/ACL/GRANT/REVOKE, exposed schemas, `media_center`, public fallback behavior, unit Hero governance, and all domain-system work.

### Operational implementation

- The active Hero renderer is `PwfHeroSliderSection`, not merely the older legacy `HeroSlider` widget.
- `home` now resolves the local `PwfHomeHeroLandmarks` catalog before any profile or database Hero read.
- Approved exact order: القدس الشريف → الحرم الإبراهيمي الشريف → مقام النبي موسى.
- Assets are local optimized WebP files, 1920×1080 each, with source/license/transform/checksum controlled in `HERO_LANDMARKS_ASSET_MANIFEST.md`.
- Remote Unsplash fallback URLs were removed from the operational Hero section.
- Directorate Hero isolation remains intact: non-home units retain their own profile/owner-scoped runtime path and do not borrow ministry landmarks.
- Rotation is seven seconds and respects `MediaQuery.accessibleNavigation`; per-slide focal alignment is passed into the public image renderer.

### Current gate

```text
LOCAL_HOME_HERO_LANDMARKS_CANDIDATE_IMPLEMENTED
ASSET_LICENSE_MANIFEST_PRESENT
NO_NEW_REMOTE_HERO_SOURCE_LITERAL
UNIT_HERO_SOVEREIGNTY_PRESERVED
MEDIA_CENTER_UNCHANGED
NO_DATABASE_OR_RLS_OR_GRANT_CHANGE
FLUTTER_TEST_ANALYZE_BUILD_PENDING_AFTER_APPLY
BROWSER_UAT_PENDING
PRODUCTION_NOT_APPROVED
```

### Evidence tooling and package boundary

- The Hero batch supplies `tools/platform15_verify_home_hero_landmarks.ps1` and `tools/platform15_run_home_hero_islamic_landmarks_validation.ps1` to capture local asset/source verification and Flutter command outputs on the real operator workstation.
- Packaging-only static integrity passed for asset presence, SHA-256 values, 1920×1080 dimensions, exact slide order, local-only catalog content, home-first resolution, no Unsplash literal in the active Hero renderer, reduced-motion hook, focal alignment wiring, and `BoxFit.cover` presence.
- This is not Flutter runtime acceptance: focused/full tests, analyzer, web build, and desktop/mobile browser UAT must be captured after the source change.
- The updates-only archive is scoped to the explicit Hero change set and excludes inherited Platform 15A authority tooling; see `ERROR_RECORD_PLATFORM15_HERO_ISLAMIC_LANDMARKS.md` Record 03.


---

## Platform 15B — Public Homepage Hero Verifier Encoding Hotfix (2026-06-21)

### Nature

Validation-tool correction and evidence intake only. No visual/Flutter source, local Hero asset, database, security, `media_center`, or unit-hero ownership mutation is included.

### Error and correction

The Platform 15 Hero static verifier was delivered with Arabic string literals inside a UTF-8 script without a BOM. Windows PowerShell 5.1 decoded that executable file through a legacy code page and stopped with a parser error before it could inspect the local Hero catalog. The remediation is an ASCII-only PowerShell verifier that reads the Dart catalog with explicit UTF-8 encoding. The companion runner is also ASCII-only and now displays captured command output while preserving logs.

### Evidence rule

A runner heading is not test evidence. The batch may claim the relevant test/analyze/build gate only when the corresponding command output or generated evidence log is supplied and reviewed. The static verifier must first return `PLATFORM15_HOME_HERO_LANDMARKS_STATIC_CHECK_PASSED`; desktop and mobile browser UAT remain mandatory afterward.

### Current gate

```text
POWERSHELL_STATIC_VERIFIER_FIXED_RERUN_REQUIRED
HERO_SOURCE_AND_ASSETS_UNCHANGED_BY_THIS_HOTFIX
NO_DATABASE_OR_SECURITY_MUTATION
PRODUCTION_NOT_APPROVED
```


---

## Platform 15C — Home Hero Direct Model Import Compile Hotfix (2026-06-21)

### Nature

- **Nature:** Flutter compile hotfix + verification-contract strengthening.
- **Scope:** `PwfHeroSliderSection` type import only, the focused Hero contract test, and the static Hero verifier.
- **Excluded:** Hero assets/content/rotation/layout behavior, SQL, database state, Supabase, RLS, GRANT/REVOKE, exposed schemas, `media_center`, public fallback, unit Hero governance, and authority flows.

### Incident and correction

Local Chrome compilation exposed that `PwfHeroSliderSection` referred to `HeroSlide` through a `show HeroSlide` import from `hero_slider.dart`. That library imports `HeroSlide` internally but does not declare or re-export it. Dart therefore resolves no `HeroSlide` type in the operating Hero library, cascading into `Object?` member-access and `List<dynamic>` assignment errors.

The operating Hero now imports `HeroSlide` directly from its defining library:

```dart
import 'package:waqf/data/repositories/homepage_repository.dart' show HeroSlide;
```

The legacy provider import is constrained to `heroSlidesForUnitProvider` only. The focused Hero contract test now imports the operating widget so its type graph must compile during the focused test stage. The static verifier also asserts these import boundaries.

### Current gate

```text
HERO_SLIDE_DIRECT_MODEL_IMPORT_COMPILE_HOTFIX_CANDIDATE_PREPARED
FOCUSED_HERO_CONTRACT_TEST_MUST_BE_RERUN
FULL_FLUTTER_TEST_ANALYZE_WEB_BUILD_PENDING_AFTER_15C
BROWSER_UAT_BLOCKED_UNTIL_COMPILE_EVIDENCE_PASSES
MEDIA_CENTER_UNCHANGED
NO_DATABASE_OR_RLS_OR_GRANT_CHANGE
PRODUCTION_NOT_APPROVED
```

---

## Platform 15E — Admin Sidebar Information Architecture + UI/UX Closure Mega Batch (2026-06-21)

### Nature and boundary

- **Nature:** Flutter admin-shell UI/UX development and navigation information-architecture refinement.
- **Scope:** `WebSidebar` and the central `AdminPanelRegistry` only.
- **Excluded:** GoRouter route definitions, RBAC decision contracts, access-profile rules, database/Supabase, SQL, RLS, grants, exposed schemas, public routes, `media_center` runtime/security behavior, and domain workflows.

### Information architecture decision

The former two-column grid of eight workspaces inside a 264px sidebar was replaced with one compact **workspace selector**. Selecting a workspace filters the sidebar without forcibly navigating away from the operator's current page. Navigation entries are now compact and category-first; descriptions remain hidden in normal operation and are reserved for maintenance visibility modes.

Approved daily-use workspace order:

```text
الرئيسية
الواجهة العامة
خدمات الجمهور
الإعلام والنشر
الأنظمة التشغيلية
إدارة المنصة
الرقابة والجودة
المطور
```

Each workspace is ordered internally by operating purpose. Examples include: workday/support, public surfaces, service intake/digital access, official publishing/media, waqf assets/sector systems, institutional structure/platform operations, and audit/readiness.

### Runtime behavior preserved

- All registered routes remain in the central registry.
- Existing sidebar visibility continues to use `AccessProfile`, `AdminRouteAccessContracts`, dynamic-system checks, and Super User short-circuits.
- Category choice changes only the navigation context; it does not grant access and it does not redirect to a default route.
- The sidebar is wider when expanded (`304px`) and tighter when collapsed (`76px`), with compact labels, active-route highlighting, tooltips in collapsed mode, and expandable category sections.

### Current gate

```text
ADMIN_SIDEBAR_INFORMATION_ARCHITECTURE_CANDIDATE_PREPARED
CENTRAL_REGISTRY_ROUTE_COVERAGE_PRESERVED_BY_STATIC_REVIEW
NO_ROUTE_OR_RBAC_OR_DATABASE_MUTATION
MEDIA_CENTER_SECURITY_WORKSTREAM_UNCHANGED
FOCUSED_SIDEBAR_TEST_PENDING_ON_OPERATOR_WORKSTATION
FLUTTER_ANALYZE_AND_WEB_BUILD_PENDING_AFTER_15E
DESKTOP_AND_NARROW_DESKTOP_BROWSER_UAT_PENDING
PRODUCTION_NOT_APPROVED
```

---

## Platform 15F — Admin Shell Material Boundary Runtime Hotfix (2026-06-21)

### الطبيعة والنطاق

- **الطبيعة:** إصلاح Flutter Runtime موضعي لمعالجة خطأ Material ancestor في لوحة التحكم.
- **الدافع:** دليل Chrome لصفحة `/admin/dashboard` أظهر Flutter red screen برسالة `No Material widget found` ضمن منطقة الشريط الجانبي بعد Platform 15E.
- **النطاق البرمجي:** `PlatformAdminShell` فقط، مع اختبارات وأدوات تحقق وتوثيق لهذا الإصلاح.
- **خارج النطاق:** GoRouter، RBAC، AccessProfile، scopes، Super User، SQL، Supabase، RLS، grants، exposed schemas، public runtime، و`media_center`.

### السبب الجذري

كان مسار desktop في `PlatformAdminShell` يرجع `Row` مباشرة. وبما أن `WebSidebar` يحتوي عناصر تفاعل Material (`PopupMenuButton`، `IconButton`، `InkWell`)، لم يكن لديها Material ancestor مضمون داخل الـshell. لا يتعلق الخلل ببيانات المستخدم أو قراءة الصلاحيات أو سجل الأبواب.

### العلاج

تم وضع Material boundary مشتركة حول صف الغلاف المكتبي:

```dart
return Material(
  color: const Color(0xFFF8FAFC),
  child: Row(...),
);
```

وهذا يغطي الشريط الجانبي وشريط المستخدم العلوي من دون تغيير عرض الشريط أو فئاته أو منطق الرؤية أو المسارات.

### بوابة الحالة الحالية

```text
ADMIN_SHELL_MATERIAL_BOUNDARY_RUNTIME_HOTFIX_CANDIDATE_PREPARED
BROWSER_RED_SCREEN_ROOT_CAUSE_FIXED_IN_SOURCE
FOCUSED_TESTS_ANALYZE_AND_WEB_BUILD_PENDING
SUPERUSER_AND_SCOPED_USER_BROWSER_RETEST_PENDING
PLATFORM15E_SIDEBAR_INFORMATION_ARCHITECTURE_REQUIRES_RUNTIME_ACCEPTANCE
NO_DATABASE_OR_RBAC_OR_ROUTE_CHANGE
MEDIA_CENTER_UNCHANGED
PRODUCTION_NOT_APPROVED
```
