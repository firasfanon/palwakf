# PalWakf Platform Comprehensive Guide — Update Note


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

## Platform 16 — P5/P6 Operational Rollout + Media Center Formal UAT Acceleration Candidate (2026-06-22)

- A consolidated candidate package now adds source-contract coverage, a local 14-directorate Hero asset scaffold, a PowerShell verifier, a safe overlay applicator, and a formal P6 UAT/evidence protocol.
- P5 coverage includes existing public/unit surfaces, control-plane routes, central/Unit Media Center families, official communications and protected operational domains.
- P6 covers central and unit-scoped Media Center routes, official communications drafts, breaking-news responsive verification, negative authorization and public RPC read-boundary proof.
- This is not a runtime-publication, storage-upload, database, RLS, grant, schema, profile or production batch.
- P1 Browser UAT remains deferred but unaccepted. Platform 15K remains blocked until its separate lifecycle evidence is authorized and completed.

```text
PLATFORM16_P5_P6_CANDIDATE_PREPARED
LOCAL_VERIFIER_PENDING
P6_BROWSER_UAT_PENDING
P1_BROWSER_UAT_DEFERRED_NOT_ACCEPTED
PLATFORM15K_RUNTIME_PUBLICATION_EVIDENCE_BLOCKED
NO_PUBLICATION
NO_PRODUCTION_APPROVAL
```
