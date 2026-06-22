# PalWakf Platform Comprehensive Guide — Update Note

## Platform 13 — Unit Analytics, SEO & Public Performance Closure (2026-06-17)

- Unit identity is sovereignly resolved from `core.org_units` through approved read wrappers/RPCs. Public tables and cache surfaces are not truth sources.
- The historical static contract records unit-aware SEO metadata, canonical public slugs, a unit sitemap, analytics events, and mobile public performance assertions.
- This historical contract does not authorize a current `core.org_units` slug migration or alias/redirect rollout. The `bth`/`bethlehem` and `jiricho`/`jericho` canonical slug plus alias contract remains separately deferred.
- Governance boundary: no SQL, `service_role`, schema change, `waqf_assets` mutation, or production approval was part of this closure.


---


## Platform 15N1 — Verifier Tooling Hotfix
The Platform 15N administrative control-plane verifier is ASCII-only and PowerShell 5.1 parser-safe. This does not alter route authorization, roles, RLS, SQL, or public runtime behavior.

---

## Platform 15O.1 — Responsive Admin Surface Overflow Closure (2026-06-22)

- Scope: Flutter-only responsive remediation after local Browser UAT observed a RenderFlex overflow in the unit surface selector.
- Unit/system selectors now use expanded, ellipsis-safe menu content.
- Shared admin-surface headers stack scope badges below the title block in constrained widths.
- No SQL, database, RLS, grant, route authorization, content, or production change.
- Candidate status only; Browser UAT retest at 1440/1024/768/390 remains mandatory.

## Platform 15O.2 — Global Responsive Chrome and Admin Action-Bar Overflow Closure
- Flutter-only responsive UI candidate following Browser UAT overflow evidence.
- Keeps public Chrome usable under DevTools-docked and narrow viewports through adaptive container gutters, wrapped top-bar controls, and a stronger header stack threshold.
- Keeps unit/system surface management operations reachable at narrow width through a shared AppBar overflow menu.
- Browser closure evidence remains pending; it does not affect database authorization or production approval.


## Platform 15O.3 — Unit-Admin Own-Unit Surface Contract
- `super_admin` keeps universal platform authority.
- `unit_admin` gets route admission to `/admin/unit-surfaces-management` only when the requested `unit` canonicalizes to the authenticated actor unit.
- This does not grant home/ministry/system authority and does not replace owner RPC/RLS enforcement.
- The Dashboard and selector must not advertise or expose cross-unit management to a Unit Admin.


---



## 2026-06-22 Continuation Status

# Current Gate Status — 2026-06-22

```text
PLATFORM15O2_RESPONSIVE_LAYOUT_EVIDENCE_POSITIVE
PLATFORM15O2_FORMAL_CONSOLE_REGRESSION_CLOSURE_PENDING
PLATFORM15O3_STATIC_CHECK_PASSED
PLATFORM15O3_TARGETED_TESTS_PASSED
PLATFORM15O3_COMPILE_CLOSURE_REJECTED
GO_ROUTER_USERROLE_IMPORT_COLLISION_OPEN
UNIT_WORKSPACE_ROUTE_HELPER_SCOPE_OPEN
BROWSER_UAT_NOT_VALID
PLATFORM15K_RUNTIME_PUBLICATION_EVIDENCE_PENDING
DIRECTORATES_14_PREFLIGHT_READ_ONLY_ACCEPTED
DIRECTORATES_14_WEB_RESEARCH_RUN_01_COMPLETE
DIRECTORATES_CONTACT_QUEUE_ACCEPTED_AS_GOVERNANCE_QUEUE
DIRECTORATES_NORMALIZATION_PACK_PENDING
CANONICAL_SLUG_ALIAS_CONTRACT_DEFERRED
LEGAL_SYSTEM_ADAPTER_CONTRACTS_READY_FOR_STAGING_PREFLIGHT
PRODUCTION_NOT_APPROVED
```


See `handoff/SESSION_HANDOFF_PLATFORM15_FINAL_CONSOLIDATED_2026_06_22.md` for the operational resume point.

---

## Platform 15O.3.1 — Unit Admin Scope Route Authorization Compile Closure Evidence Acceptance (2026-06-22)

- تم إغلاق تعارض `UserRole` عبر إخفاء enum المكرر من `admin_user.dart` مع اعتماد enum السيادي من `core/enums`.
- تم نقل `_unitSurfacesRoute` إلى private file-level helper مشترك بين لوحة مساحة العمل وبطاقة الوحدة.
- الأدلة الفعلية: اختباري Flutter PASS (`+3` و`+2`)، `flutter analyze` بلا errors (19 warnings/info)، `flutter build web --release` PASS، وChrome debug launch PASS.
- تحذيرات Wasm dry run لا تمنع build الويب القياسي، وتبقى Analyzer/Wasm debt خارج نطاق الدفعة.
- لا يُعد Chrome launch Browser UAT. بوابة P1 ما زالت مطلوبة لـbthadmin وSuper User وفحص 390px.
- لا SQL/RLS/RBAC/GRANT/RPC/core mutation، لا alias/redirect، لا directorate publication، ولا production approval.

### Current Gate Status — 2026-06-22

```text
PLATFORM15O3_1_COMPILE_CLOSURE_ACCEPTED
TARGETED_ROUTE_SCOPE_TESTS_PASSED
FLUTTER_ANALYZE_NO_ERROR_DIAGNOSTICS
WEB_RELEASE_BUILD_PASSED
CHROME_DEBUG_LAUNCH_PASSED
P1_BROWSER_UAT_PENDING
PLATFORM15K_RUNTIME_PUBLICATION_EVIDENCE_BLOCKED_BY_P1
DIRECTORATES_14_GOVERNANCE_ONLY
CANONICAL_SLUG_ALIAS_CONTRACT_DEFERRED
PRODUCTION_NOT_APPROVED
```

---

## Platform 16 — P5/P6 Local Execution Evidence Acceptance (2026-06-22)

### Accepted local execution scope

- The candidate overlay `PLATFORM16_P5_P6_OPERATIONAL_ROLLOUT_AND_MEDIA_CENTER_FORMAL_UAT_ACCELERATION_MEGA_BATCH` was applied locally to the Flutter project.
- A timestamped backup was created before overlay application:
  `C:\Users\DELL\StudioProjects\palwakf\.palwakf_backups\platform16_p5_p6_20260622_073804`.
- The 14-directorate local Hero asset scaffold was merged without overwriting existing image files.
- Static verifier passed for Media Center route registration, service-first dashboard markers, official-communication fields, and the public media RPC runtime gateway boundary.
- Flutter test evidence passed: `+5`, `+5`, `+3`, `+3` for the P5/P6 contract suite, scoped unit Media Center suite, least-privilege containment suite, and responsive public Chrome suite respectively.
- `flutter analyze` completed with no error diagnostics. The existing 19 `warning/info` items remain recorded as analyzer debt, outside this batch.
- `flutter build web --release` passed and generated `build\\web`.

### Exact scope boundary

- No SQL, RLS, grant, schema, Storage upload, directorate profile, publication, or production action was executed.
- This acceptance confirms local overlay application and static/build readiness only.
- It does **not** accept P6 formal Browser UAT, controlled-draft write/readback, negative-authorization Browser proof, public RPC Network proof, or responsive Browser evidence.
- It does **not** accept P5 as a fully closed operational rollout; P5 remains an inventory-driven runtime rollout program after local foundation acceptance.
- P1 Unit/Admin Browser UAT remains deferred and unaccepted; Platform 15K publication evidence remains blocked by P1.

### Current gate status

```text
PLATFORM16_P5_P6_CANDIDATE_OVERLAY_APPLIED
PLATFORM16_P5_P6_STATIC_ROLLOUT_CONTRACT_PASSED
UNIT_PUBLIC_ASSET_HERO_FOLDERS_14_CONFIRMED
MEDIA_CENTER_ROUTE_CONTRACT_PASSED
PUBLIC_MEDIA_RPC_GATEWAY_CONTRACT_PASSED
P5_LOCAL_FOUNDATION_ACCEPTED
P5_OPERATIONAL_ROLLOUT_FULL_ACCEPTANCE_PENDING
P6_STATIC_AND_BUILD_READINESS_ACCEPTED
P6_FORMAL_BROWSER_UAT_PENDING
P1_BROWSER_UAT_DEFERRED_NOT_ACCEPTED
PLATFORM15K_RUNTIME_PUBLICATION_EVIDENCE_BLOCKED_BY_P1
NO_SQL_RLS_GRANT_SCHEMA_STORAGE_PROFILE_PUBLICATION_OR_PRODUCTION_MUTATION
```

---

## Platform 16 — Unit Public Navigation Scope + Unit Media Center Sectional Sidebar Candidate (2026-06-22)

- **User-facing requirement:** a directorate/unit public navigation must not expose ministry-only information such as the Minister’s Word, Former Ministers, the ministry organizational structure, or the central ministry vision/mission. These remain visible only at `home` (the ministry scope). Unit routes retain their own profile, local vision/mission, local media center, and the permitted service center paths.
- **Unit editor requirement:** a unit-bound actor must see explicit local Media Center pages in the admin sidebar, not only one generic Media Center entry.
- **Implementation contract:** `/admin/unit-media-center` stays one scoped workspace. The query parameter `section` selects only one of six local pages: `news`, `announcements`, `activities`, `events`, `photos`, and `videos`. It does not create or expose central editorial routes, change RBAC, or expand the user’s unit scope.
- **Sidebar contract:** query-aware entry identities prevent the six local section entries from collapsing into one route or all appearing active together.
- **Out of scope:** SQL, RLS, grants, schema changes, storage uploads, profile/contact changes, public composition publication, `core.org_units` slug change, alias redirects, and production approval.
- **Required evidence after local apply:** targeted tests, `flutter analyze`, `flutter build web --release`, then browser UAT under `bthadmin` and Super User.

---

## Platform 16 — PalWakf Public Roadmap Candidate (2026-06-22)

### Authorized scope
Add a ministry-home-only public navigation entry labeled `PalWakf`, opening `/palwakf`. The route presents a responsive, public roadmap of planned systems using explanatory cards.

### Scope isolation
- Navigation entry is gated by `isHome`; unit/directorate menus do not receive the central platform roadmap entry.
- The page is static public copy and does not expose internal planning records, administrative backlog data, or private system information.

### Planned-card catalogue
1. Waqf asset management.
2. Legal system.
3. Billing and collection.
4. Tasks and follow-up.
5. Mustakshif spatial/historical explorer.
6. Trust-aligned waqf assistant.
7. Knowledge and documentation center.
8. Unified services gateway.

### Authority and safety
No SQL, RLS, grants, schema, storage, profile, publication, production, or role-scope mutation is authorized by this candidate. Local Flutter evidence and browser UAT remain required before baseline acceptance.

---

## Platform 16 — Media Center and Public Temporal Ordering Candidate (2026-06-22)

- The local overlay was applied with `FILES_APPLIED=19` and a timestamped backup before the PowerShell verifier stopped on an UTF-8 parser failure.
- Scope: news, announcements, activities, events, photos, videos, official communications, and other dated material must render newest-to-oldest. Editorial flags such as pinned, priority, featured, `sort_order`, or `display_order` do not supersede chronological order.
- Local Flutter evidence and Browser ordering evidence were not completed in that command run. This remains unaccepted until the verifier, targeted tests, `flutter analyze`, `flutter build web --release`, and live Browser checks pass.
- No SQL, RLS, grant, schema, storage, profile, publication, or production action is included.


---

## Platform 16 — Unit Navigation and Media Section Overlay Local Status (2026-06-22)

- The local overlay was applied with `FILES_APPLIED=8` and a timestamped backup. Its verifier then failed due to a PowerShell UTF-8 parsing defect before Flutter checks began.
- Intended scope: unit public menus must exclude ministry-only pages; unit editors receive explicit local Media Center entries for news, announcements, activities, events, photos, and videos.
- Static and Browser acceptance remains pending. No SQL, RLS, grant, schema, storage, profile, publication, or production change is authorized.


---

## Platform 16 — PalWakf Public Roadmap Local Status (2026-06-22)

- The local overlay was applied with `FILES_APPLIED=6`; static route checks passed for `/palwakf` and ministry-home-only navigation.
- The original apply verifier stopped on an uninitialized PowerShell `$LASTEXITCODE`. The targeted PalWakf route test later passed.
- Full Flutter evidence is blocked by the Unit public-detail repository/provider contract mismatch recorded below. The roadmap feature is not yet accepted as a stable baseline.
- No database mutation, publication action, or production approval occurred.


---

## Platform 16 — Direct Public Media Detail Compile Recovery Candidate (2026-06-22)

- A compile regression was found after the public detail providers began calling `getActivityByContentIdForUnit`, `getAnnouncementByContentIdForUnit`, and `getNewsByContentIdForUnit` while the corresponding repository/service methods were absent.
- The corrective candidate restores those three methods as direct `rpc_public_media_detail_v2` reads through `PwfPublicMediaRuntimeGateway.fetchDetail`, preserving the server-side unit + family + opaque content id lock and prohibiting list/cache or ministry fallbacks.
- The prior guide-recovery command must not be considered successful: it wrote an empty local guide after its search found no matching backup. This candidate replaces that empty guide with this restored comprehensive baseline.
- Candidate only: local tests, `flutter analyze`, `flutter build web --release`, Chrome launch, and Browser UAT remain required. No SQL, RLS, grants, schema, storage, publication, or production action is authorized.


---

## Current Recovery Gate — 2026-06-22

```text
COMPREHENSIVE_GUIDE_RESTORATION_CANDIDATE_PREPARED
UNIT_PUBLIC_DETAIL_PROVIDER_REPOSITORY_CONTRACT_HOTFIX_PREPARED
FLUTTER_CHROME_COMPILE_BLOCKED_PENDING_LOCAL_APPLY
TEMPORAL_ORDERING_LOCAL_OVERLAY_APPLIED_NOT_ACCEPTED
UNIT_NAVIGATION_MEDIA_SECTIONS_LOCAL_OVERLAY_APPLIED_NOT_ACCEPTED
PALWAKF_ROADMAP_LOCAL_OVERLAY_APPLIED_NOT_ACCEPTED
P1_BROWSER_UAT_DEFERRED_NOT_ACCEPTED
P6_FORMAL_BROWSER_UAT_PENDING
PLATFORM15K_RUNTIME_PUBLICATION_EVIDENCE_BLOCKED_BY_P1
PRODUCTION_NOT_APPROVED
```
