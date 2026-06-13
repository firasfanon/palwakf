# PALWAKF Platform Comprehensive Guide — Service Center Closure Update

Date: 2026-05-31

## Service Center final scoped runtime closure

Service Center is closed within scoped runtime UAT. The owner schema remains `platform_services`; Flutter runtime is through public RPC wrappers only.

Accepted runtime surfaces:

- public.rpc_services_forms_public_v1
- public.rpc_services_submit_request_v1
- public.rpc_services_track_request_public_v1
- public.rpc_services_admin_request_queue_v1
- public.rpc_services_admin_transition_request_v1

Final state:

```text
staging-stable /
service-center-scoped-runtime-closure-complete /
service-center-runtime-source-certified-for-forms-admin-queue-submit-track-transition /
service-center-public-submit-route-accepted /
service-center-same-tracking-number-trace-accepted /
service-center-admin-transition-evidence-accepted /
analyzer-post-hotfix-clean /
chrome-startup-passed /
production-candidate-not-platform-production-approved /
no-sql-production-change /
no-direct-flutter-platform-services-writes /
no-service-role /
no-waqf-awqaf-system-gis-mutation
```

## Production note

This closure is a production candidate for Service Center only. It is not a platform-wide production approval.

## Boundaries

No SQL production, no DDL/DML/GRANT/DROP, no direct Flutter writes to `platform_services`, no `service_role`, no deletion/archive, and no mutation to `waqf`, `waqf_assets`, `awqaf_system`, or GIS schemas.


---

## 2026-06-13 — Platform 12 Home Search + Homepage Sections Source Consolidation Mega Batch

This is the active Platform 12 governed batch for the home search and homepage sections source issue. It supersedes the earlier narrow evidence-intake wording inside this session and should be treated as the current baseline reference.

### Search source and route

```text
/home/search?q=<query>
/<unitSlug>/search?q=<query>
```

The search route renders from `SearchScreen`, then delegates to the web/mobile implementation. The current result source is a governed local public-route index. A future database-backed RPC search is allowed only after approving search scope, ranking, Arabic normalization, and privacy rules.

### Homepage sections source

```text
PwfHomeWebScreen
→ homepageSectionsForUnitProvider
→ HomepageRepository.fetchAllSectionsForUnit
→ public.v_platform_homepage_sections_compat_v1
→ PwfHomeSectionsRenderer
```

Public/runtime reads remain through compatibility views/wrappers. Existing admin writes to the preserved legacy surface remain unchanged until owner-write RPCs are approved.

### Duplicate handling

Legacy section aliases are canonicalized at runtime. The repository sorts scoped rows deterministically and prefers canonical/active rows when duplicate keys are encountered. Rendering is still one section per canonical key.

The SQL evidence confirmed `pwf_footer/footer` as the active duplicate requiring controlled cleanup if authorized. Semantic overlaps remain a UX/content decision.

### Current status

```text
platform12-home-search-sections-source-consolidation-mega-batch-prepared
search-route-rendering-confirmed-by-user-evidence
search-url-query-sync-added
homepage-sections-runtime-source-certified-to-compat-view
canonical-section-deduplication-hardened
semantic-family-policy-decision-required
android-runtime-uat-deferred
no-sql-executed
no-service-role
production-not-approved
```


---

## 2026-06-03 — Platform Access Gateway UAT Retest RPC400 Closure

Latest evidence accepted: Platform Access Gateway `/admin/dashboard` renders for tested superuser/viewer/employee actors after disabling the failing user-scope assignments list RPC path. Network evidence shows `user_scope_assignments?select...` returning `200`, with no visible `rpc_user_scope_assignments_list_v1` `400` in the submitted retest. The unified `/forbidden` route renders a safe Arabic denied page for `admin_access_denied` without protected payload/token exposure.

Production remains not approved; this closes only the tested platform-access RPC400 retest branch.

---

## 2026-06-13 — Platform 12 Web Search Overflow + Homepage Section Duplicate Evidence Intake

The `/home/search?q=مسجد` browser evidence confirms that the public search route now returns results. A separate frontend layout issue was found: `WebAppBar` overflowed under a constrained viewport when Chrome DevTools was docked.

Runtime source decision for homepage sections remains:

```text
PwfHomeWebScreen
→ homepageSectionsForUnitProvider
→ HomepageRepository.fetchAllSectionsForUnit
→ public.v_platform_homepage_sections_compat_v1
→ PwfHomeSectionsRenderer
```

The received read-only diagnostics confirmed canonical duplicate keys for legacy/canonical section names. Only `pwf_footer/footer` returned with two active canonical duplicate rows. Other canonical duplicates have one active row and should be cleaned for governance clarity, but are mitigated at frontend merge level.

Semantic overlaps require content/UX policy, not automatic deletion:

```text
links_family: pwf_important_links + pwf_quick_links_grid
media_gallery_family: pwf_media_gallery_images + pwf_media_gallery_videos
news_family: pwf_news_tabs + pwf_news
services_family: pwf_eservices_portal + pwf_quick_services
```

Mega Batch status:

```text
search-route-rendering-confirmed
web-appbar-responsive-overflow-hardened
search-page-narrow-layout-hardened
duplicate-section-evidence-accepted
guarded-legacy-alias-duplicate-dml-prepared-not-executed
semantic-family-policy-decision-required
android-runtime-uat-deferred
no-sql-executed
no-service-role
production-not-approved
```

No SQL was executed by this Mega Batch. The guarded SQL pack under `sql_sandbox/platform12_homepage_sections_duplicate_remediation_guarded/` must not be run without explicit operator authorization.

---

## 2026-06-13 — Platform 12 Home Search Waqf Query + WebAppBar Overflow Closure Mega Batch

This Mega Batch continues `تطوير المنصة 12` and supersedes the previous narrower search/layout evidence state for the home search route.

### Evidence accepted

```text
/home/search?q=مسجد → result rendered at normal width
/home/search?q=وقف + category=الوثائق → empty state found
WebAppBar → RenderFlex overflow still present under DevTools constrained width
```

### Search decision

The current public search remains a governed local public-route index until a database-backed public search RPC is separately designed and approved. This batch expands the index to cover core waqf terminology so that `وقف` is not treated as an empty public query.

The index now includes:

```text
مستكشف الوقف → /mustakshif
وقف / وقفي / أوقاف / اوقاف / أصول وقفية / أراضي وقفية / مستكشف / خرائط
```

Arabic normalization now covers diacritics, tatweel, hamza forms, ta marbuta, alif maqsura, and short waqf-term expansion.

### WebAppBar decision

`WebAppBar` must prefer a compact menu earlier than the design mock when Arabic labels, ministry logo, action controls, and DevTools constrained widths make full navigation unsafe. Preventing runtime overflow is higher priority than keeping the full nav visible at borderline widths.

### Homepage sections decision preserved

```text
PwfHomeWebScreen
→ homepageSectionsForUnitProvider
→ HomepageRepository.fetchAllSectionsForUnit
→ public.v_platform_homepage_sections_compat_v1
→ PwfHomeSectionsRenderer
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

No SQL was executed. No public base table mutation, no service-role usage, and no `waqf_assets` mutation occurred in this Mega Batch.
