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

---

## 2026-06-13 — Platform 12 Footer Overflow + Flutter Test Harness Closure Mega Batch

This Mega Batch continues `تطوير المنصة 12` after the home-search and WebAppBar consolidation work.

### Evidence accepted

```text
flutter analyze → No issues found
flutter test → failed due stale default widget_test.dart importing package:palwakf/main.dart
flutter run -d chrome → launched successfully and initialized Supabase
runtime console → WebFooter RenderFlex overflow by 29px under constrained width
```

### Decision

The remaining responsive defect is not in `WebAppBar`; it is in `WebFooter`. The footer must be treated as part of the platform shell and must support constrained widths caused by Chrome DevTools, split-screen operation, and smaller web viewports.

### Footer layout rule

`WebFooter` must not use a single fixed horizontal row for legal/copyright content. The required rule is:

```text
compact width → stacked Column + Wrap actions
wide width → Expanded copyright + Flexible Wrap actions
footer sections → Wrap/stack under constrained width
```

### Test harness rule

Default Flutter template tests must not remain in the project when they import a wrong package name or assume a demo counter app. `test/widget_test.dart` is now a neutral test-harness guard. Contract tests remain the stronger evidence for platform behavior.

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

No SQL was executed. No public base table mutation, no service-role usage, and no `waqf_assets` mutation occurred in this Mega Batch.

---

## Platform 12 — Home Page Section Polish + Semantic Runtime Policy Mega Batch — 2026-06-13

### Purpose

This Mega Batch continued public homepage polishing after search-route binding and layout overflow closure. It addressed visible semantic repetition among homepage sections without executing SQL or mutating `homepage_sections` rows.

### Canonical runtime chain

```text
PwfHomeWebScreen
→ homepageSectionsForUnitProvider
→ HomepageRepository.fetchAllSectionsForUnit
→ public.v_platform_homepage_sections_compat_v1
→ PwfHomeSectionsRenderer
→ semantic family runtime policy
→ section widget
```

### Section family policy

The homepage catalog now contains semantic metadata for official section keys:

- `familyKey`
- `familyPriority`
- family mode through `kPwfHomeSectionFamilyModes`

Active DB rows remain the source of truth, but public rendering now avoids close-substitute repetition:

| Family | Runtime policy |
| --- | --- |
| `news_family` | `pwf_news_tabs` supersedes `pwf_news` |
| `services_family` | `pwf_eservices_portal` supersedes `pwf_quick_services` |
| `links_family` | `pwf_important_links` supersedes `pwf_quick_links_grid` |
| `media_gallery_family` | `pwf_media_gallery` supersedes image/video split only when unified gallery is active |

### Admin behavior

Homepage management now shows semantic-family labels and warnings. Rows hidden by runtime policy remain visible in admin and are marked as active in DB but hidden at runtime because a higher-priority representative exists.

### Governance

- No SQL executed.
- No direct table mutation.
- No service-role use.
- No production approval.
- SQL cleanup, if required later, must be authorized separately.

---

## Platform 12 — Gallery + Activities Duplicate Closure Mega Batch — 2026-06-13

### Purpose

This Mega Batch closes the remaining homepage semantic repetition reported during `تطوير المنصة 12`: media/image gallery repetition and activities/events repetition.

### Runtime rule

The homepage remains DB-controlled through `public.v_platform_homepage_sections_compat_v1`, but runtime rendering applies one-representative policy for close substitutes.

| Family | Runtime policy |
| --- | --- |
| `media_gallery_family` | Render only one representative: `pwf_media_gallery` first, then `pwf_media_gallery_images`, then `pwf_media_gallery_videos`. |
| `activities_events_family` | Render only one representative: `pwf_activities` first, then `pwf_events_section`. |

### Media gallery content boundary

`PwfMediaGallerySection` is now visual-media only:

```text
photos / videos
```

Events are handled through the canonical activities/events section and route, not through the media gallery tabs. This prevents event content from appearing twice on the public homepage.

### Governance

- No SQL executed.
- No direct DB mutation.
- No service-role use.
- No production approval.
- DB cleanup, if later desired, requires a separately authorized SQL Mega Batch.

---

## Platform 12 — Media Gallery Compile Boundary Closure Mega Batch — 2026-06-13

### Purpose

This Mega Batch closes a Flutter web compiler blocker caused by stale activity references left inside `PwfMediaGallerySection` after removing the gallery events tab.

### Accepted evidence

The local Chrome run failed with missing `Activity` and `ActivityType` types in:

```text
lib/features/platform/home/presentation/widgets/sections/pwf_media_gallery_section.dart
```

### Architectural decision

The media gallery is a visual-media component only:

```text
photos / videos
```

Activities and events belong to the homepage activities/events section. The gallery must not depend on `Activity` or `ActivityType` for rendering.

### Runtime boundary

```text
PwfMediaGallerySection
→ MediaGalleryItem
→ photos/videos tabs only
```

The following are intentionally absent from the gallery section:

```text
fromActivity(Activity)
ActivityType mapper
_GalleryTab.events
```

### Governance

- No SQL executed.
- No direct DB mutation.
- No service-role use.
- No production approval.
- Android runtime UAT remains deferred.


---

## Platform 12 — Home Management Runtime Alignment Rule

The public homepage must mirror `/admin/home-management` for section visibility and ordering.

Runtime section merge precedence is:

```text
current unit row > home unit row > global sentinel row > unscoped legacy row
```

The runtime merge must not prefer active fallback rows over more specific inactive admin-scoped rows. Active/inactive and display order are administrative decisions owned by the effective scoped row.

Semantic duplicate families use a single-active representative policy in admin and runtime. For families marked `preferOne`, activating one representative in `/admin/home-management` must deactivate active siblings immediately. This avoids saving an admin state that the public renderer later suppresses.

New catalog sections added from the admin surface default to inactive until explicitly enabled.

---

## Platform 12 — Home Management Unique Scope Write Rule — 2026-06-13

`/admin/home-management` is the administrative authority for homepage section visibility and ordering, while `/home` is the runtime consumer. Runtime reads continue through `public.v_platform_homepage_sections_compat_v1`, but admin write conflict detection must not rely on that compatibility view.

### Rule

Before inserting/updating section metadata, admin write paths must check the preserved write table scope directly:

```text
public.homepage_sections / section_name / unit_id
```

If an insert hits PostgreSQL code `23505` on `ux_homepage_sections_scope`, the operation must retry as an update by the existing scoped row. This protects `/admin/home-management` from duplicate-key failures when the compatibility view does not expose inactive or scoped rows that still exist in the write table.

### Current write path

```text
/admin/home-management
→ PwfHomepageSectionsManager.save
→ HomepageRepository.saveSectionsMeta
→ write-surface lookup
→ update existing row or insert missing row
→ retry update on 23505
```

### Unit-page section write path

`PwfUnitPagesRepository` follows the same rule when materializing allowed sections for unit pages.

### Governance

- Runtime read surface remains `public.v_platform_homepage_sections_compat_v1`.
- Admin write surface remains the preserved `homepage_sections` table until owner-write RPCs are explicitly approved.
- This rule does not authorize SQL execution or direct production DB mutation outside the app's existing admin write path.


---

## Platform 12 — Home Management Toggle Persistence Closure

### قرار تشغيلي

في `/admin/home-management` يجب أن يكون مصدر القراءة بعد الحفظ هو سطح الكتابة الإداري المحفوظ `public.homepage_sections`، وليس سطح القراءة العام `public.v_platform_homepage_sections_compat_v1`، لأن شاشة الإدارة مسؤولة عن إظهار الصفوف النشطة وغير النشطة والنطاقات scoped كما هي فعليًا.

### القاعدة المعتمدة

- Runtime العام للصفحة الرئيسية يقرأ عبر compatibility view.
- Admin management يقرأ بعد الحفظ من write-surface preserved table حتى لا يعود الزر إلى وضع غير مفعل بسبب row مخفي أو scoped.
- الكتابة تفضّل الصف canonical أولًا، ثم legacy alias عند عدم وجود canonical row.
- لا يجوز أن يؤدي تفعيل قسم في الإدارة إلى تحديث alias قديم وترك الصف canonical غير مفعل.
- لا SQL إنتاجي ضمن هذه الدفعة.

### حالة الاعتماد

`ADMIN_HOME_MANAGEMENT_TOGGLE_READBACK_WRITE_SURFACE_ALIGNED_SQL_NOT_EXECUTED_PRODUCTION_NOT_APPROVED`

## Platform 12 Runtime Rule — Home Management Save Feedback and Runtime Visibility

For `/admin/home-management`, the operator must receive explicit confirmation after successful Save. Silent saves are not acceptable because the screen controls public homepage visibility.

The public homepage runtime keeps `public.v_platform_homepage_sections_compat_v1` as the base read surface. Until owner-schema read/write RPC closure is approved, runtime may overlay rows from the preserved admin write table `public.homepage_sections` in a fail-open manner to keep `/home` aligned with admin decisions. If the overlay is denied by RLS/grants, runtime falls back to the compatibility view and logs the condition.

A section enabled in DB must not disappear silently merely because its downstream content source is empty. Data-backed sections that may have empty sources should show a governed empty-state block when rendered from the homepage section runtime, unless explicitly designed as decorative optional content.

Current Platform 12 baseline after this rule:

```text
platform12_home_management_save_runtime_visibility_closure_mega_batch_2026_06_13.zip
```

---

## Platform 12 — Homepage Management Sovereign Runtime Contract — 2026-06-13

### القرار السيادي

من هذه الدفعة فصاعدًا لا يُدار مسار الصفحة الرئيسية كتعاملات متفرقة بين `/admin/home-management` و`/home`. المسار محكوم بعقد واحد:

```text
Homepage Section Registry
→ Admin State RPC
→ Save State RPC
→ Runtime State RPC
→ PwfHomeSectionsRenderer
```

### RPC المعتمدة

```text
public.rpc_homepage_sections_registry_v1()
public.rpc_homepage_sections_admin_state_v1(p_unit_id, p_home_unit_id)
public.rpc_homepage_sections_save_state_v1(p_unit_id, p_sections, p_prune_duplicates)
public.rpc_homepage_sections_runtime_v1(p_unit_id, p_home_unit_id)
```

Flutter repository must call these RPCs first. Direct compatibility/table fallback is allowed only as an interim fail-open path when the SQL has not yet been applied in the target environment.

### Registry rule

كل قسم في الصفحة الرئيسية يجب أن يملك تعريفًا رسميًا يشمل:

```text
canonical_key
family_key
family_mode
family_priority
source_kind
renderer_key
can_render_empty_state
admin_visible
runtime_visible
owner_ar
contract_note_ar
```

أي قسم لا يملك تعريفًا واضحًا لا يجوز اعتباره قسمًا منشورًا عاديًا.

### منع التكرار

العائلات ذات السياسة `preferOne` لا تسمح بأكثر من ممثل واحد في runtime. عند الحفظ عبر RPC، يتم تعطيل الممثلين المكررين داخل نفس العائلة والنطاق. هذا يعتبر حذفًا تشغيليًا من الصفحة وليس حذفًا فيزيائيًا من قاعدة البيانات، حفاظًا على التدقيق والأثر.

### عزل العائلات

- `pwf_breaking_news_marquee` مستقل داخل `sovereign_alerts` ولا يدخل ضمن `news_family`.
- `pwf_news_tabs` و`pwf_news` هما الأخبار العامة فقط، ولا يحتويان الأخبار العاجلة أو الفعاليات أو عناصر المعرض.
- `pwf_media_gallery` و`pwf_media_gallery_images` و`pwf_media_gallery_videos` تخص الصور والفيديو فقط.
- `pwf_activities` و`pwf_events_section` تخص الأنشطة والفعاليات فقط.
- الخدمات والروابط لها عائلاتها الخاصة ولا تكرر ممثلين متقاربين.

### الأخبار العاجلة

إذا كان قسم الأخبار العاجلة مفعّلًا ولم توجد عناصر منشورة، يجب أن يعرض حالة فارغة محكومة بدل الاختفاء الصامت. هذا يمنع الالتباس بين “القسم مخفي” و“القسم مفعل لكن مصدره فارغ”.

### حالة SQL

SQL موجود تحت:

```text
sql_apply/platform12_homepage_management_sovereign_runtime_contract_2026_06_13/
```

ولم يتم تنفيذه داخل هذه البيئة. التنفيذ يحتاج تفويضًا مستقلًا وفحص diagnostics قبل وبعد.

### الحالة الحالية

```text
platform12-homepage-management-sovereign-runtime-contract-mega-batch-prepared
sql-prepared-not-executed
no-service-role
production-not-approved
android-runtime-uat-deferred
```

---

## Platform 12 — Homepage Visual Contract Alignment — 2026-06-13

### القرار البصري السيادي

كل أقسام الصفحة الرئيسية يجب أن تتبع عقدًا بصريًا واحدًا. لا يجوز أن يملك كل قسم نظام ألوان ومسافات وبطاقات مستقلًا عن بقية الصفحة. القسم يملك المحتوى ومصدر البيانات، أما الكروم البصري فيأتي من:

```text
PwfHomeVisualContract
PwfSectionContainer
PwfSectionTitle
PwfVisualCard / PwfVisualChip / PwfVisualEmptyState
```

### هوية المنصة

يجب الالتزام بهوية المنصة:

```text
Primary blue
Gold accent
Royal red #B22222
RTL-first layout
Responsive spacing
Unified card radii and shadows
Governed empty states
```

### قواعد الأقسام

- العنوان والوصف والفاصل البصري للقسم من `PwfSectionTitle`.
- المسافات والخلفيات العامة من `PwfSectionContainer`.
- البطاقات الجديدة يجب أن تستخدم `PwfVisualCard` أو تتبع نفس tokens.
- الأوسمة والفئات يجب أن تستخدم `PwfVisualChip` أو نفس tokens.
- القسم المفعّل بلا بيانات لا يختفي بصمت إذا كان يدعم empty state؛ يستخدم `PwfVisualEmptyState` أو نظيرًا مطابقًا.
- الأخبار العاجلة تبقى عائلة مستقلة بصريًا وتشغيليًا، ولا تُدمج مع الأخبار العامة.

### حالة الاعتماد

```text
platform12-homepage-visual-contract-alignment-mega-batch-prepared
sql-not-executed
no-service-role
production-not-approved
android-runtime-uat-deferred
```

---

## Platform 12 — Public Subpages Visual Contract + About/Vision Development Mega Batch — 2026-06-13

### Decision

Homepage child/subpages must not drift visually from the homepage contract. The same visual identity must govern public content pages, platform frontend hub pages, and static placeholder pages.

### Runtime visual chain

```text
PwfWebPageScaffold
→ PwfSectionContainer
→ PwfHomeVisualContract
→ PwfVisualCard / PwfVisualIconTile / PwfVisualChip / PwfVisualEmptyState / PwfVisualResponsiveGrid
```

### Pages developed

- `/about`: developed with ministry overview, institutional work areas, digital transformation, and directorates/units relationship.
- `/vision-mission`: developed with vision, mission, work pillars, and governing values.

### Subpage visual alignment

- `PwfContentPage` now renders a unified sovereign subpage hero, visual cards, responsive grid, and governed action panel.
- `PwfPlatformFrontendHubPage` now uses centralized visual primitives for hero, metrics, cards, titles, and info blocks.
- `PwfStaticPageWebScreen` now renders a governed empty state and no longer uses an ad-hoc card identity.

### Guardrails

- This batch is visual/content only.
- No SQL executed.
- No service-role usage.
- Homepage Management Sovereign Runtime Contract remains preserved.
- Production remains not approved.
- Android runtime UAT remains deferred.

---

## Platform 12 — Homepage First Fold Visual Refinement Mega Batch — 2026-06-13

### Decision

The homepage first fold and the main public sections must not only be functionally governed by the Homepage Management Sovereign Runtime Contract; they must also behave as one continuous visual page. Admin hiding/reordering must not expose empty bands, detached surfaces, or always-visible utility controls.

### Visual rules added

- Breaking news is a sovereign first-fold alert strip and follows the hero surface width.
- Hero images and fallbacks must cover the entire hero height using `BoxFit.cover` and full-box expansion.
- Homepage section flow uses one continuous page background; intentional section cards/gradients remain internal to the section content, not as orphan page bands.
- A disabled section must not leave visible space or a different-colored band between active sections.
- Latest-news can feature one secondary story from subordinate/complementary unit news below the main story, while keeping general news and unit news visually distinguishable.
- Side and complementary news cards should include thumbnails or governed fallbacks.
- E-services governance metadata must remain one horizontal governance row.
- Scroll-to-top is a contextual utility: hidden on first load, visible only after user scroll depth exceeds approximately half the first viewport.

### Guardrails

- This batch is frontend visual/runtime only.
- No SQL executed.
- No service-role usage.
- Homepage Management Sovereign Runtime Contract remains preserved.
- Production remains not approved.
- Android runtime UAT remains deferred.


---

## Platform 12 — Homepage Surface Continuity + Hero Height Closure Mega Batch — 2026-06-15

### Decision

The homepage must behave as one continuous sovereign white canvas while the hero becomes the first-fold visual anchor. User evidence confirmed that the hero felt visually pulled upward and that grey bands remained below some active sections.

### Rules added

- Hero height receives the approved first-fold allowance from user evidence: `54px` on desktop and a controlled smaller allowance on narrow layouts.
- Hero image rendering remains full-bleed with `BoxFit.cover`, but the focal point is slightly lowered so imagery does not feel pulled upward.
- Public homepage light mode uses `PwfHomePalette.surface` as its outer canvas.
- `PwfHomeVisualContract.sectionBackground` returns the same surface to avoid orphan grey bands.
- Section widgets must not add outer tinted backgrounds unless the tint is part of intentional internal card content.
- `PwfStatsSection` now relies on `PwfSectionContainer` for the surface and vertical rhythm.
- Disabled sections must collapse without leaving visual residue or color bands.

### Guardrails

- Frontend visual/runtime only.
- No SQL executed.
- No service-role usage.
- Homepage Management Sovereign Runtime Contract remains preserved.
- Production remains not approved.
- Android runtime UAT remains deferred.


---

## Platform 12 — Homepage Adaptive Hero + Surface Band Closure Mega Batch — 2026-06-15

### Decision

Retest evidence showed that the previous surface-continuity work did not fully close the homepage visual contract. The hero still appeared visually pulled upward, and disabling the breaking-news strip exposed a need for the hero to flex as the actual first-fold block. The media gallery also still exposed grey/foreign bands above and below because it retained an external gradient/margin wrapper outside the common section container.

### Rules added

- The hero is adaptive to the first fold, not a fixed-height banner.
- On desktop/web, the hero target now uses `viewportHeight * 0.80` with stronger min/max bounds so lower sections do not appear too early when first-fold sections are disabled.
- Hero images remain full-bleed and use `BoxFit.cover`, but the focal point is lowered to `Alignment(0, 0.36)` to reveal more of the lower image field.
- Sections must not wrap `PwfSectionContainer` in external decorative backgrounds/margins. Any decorative treatment must be inside cards/content, not around the section slot.
- `PwfMediaGallerySection` is part of the continuous homepage canvas and no longer owns an external gradient or bottom margin.
- `PwfHomeSectionsRenderer` wraps rendered sections in a white sovereign slot to prevent transparent/legacy outer widgets from exposing non-contract page backgrounds.
- Disabled or suppressed sections must collapse without leaving background bands or spacing residue.

### Guardrails

- Frontend visual/runtime only.
- No SQL executed.
- No service-role usage.
- Homepage Management Sovereign Runtime Contract remains preserved.
- Production remains not approved.
- Android runtime UAT remains deferred.

---

## Platform 12 — Public Subpages Unified Visual Polish — 2026-06-15

### Decision

Homepage-derived public subpages must not appear as a visual mixture of independent layouts. The Platform shell remains shared, but all public subpage bodies must follow the same sovereign visual rhythm while preserving each page's functional specificity.

### Rules added

- Public subpage intro blocks must use a full-width sovereign hero surface.
- Public stats and summary cards must use the centralized visual primitives and responsive grid rhythm.
- Static/fallback pages must show governed empty states instead of ad-hoc cards.
- Platform frontend hub pages must use one hero/card/info rhythm across services, media-center, social posts, references, events, and similar routes.
- Scroll-to-top is contextual on public subpages: hidden on first load and shown only after meaningful scroll.
- Subpage-specific logic remains intact: news filters, activity filters, service request actions, public chatbot governance, and media-family panels are not merged into one generic page.

### Guardrails

- Frontend visual/runtime only.
- No SQL executed.
- No service-role usage.
- Homepage Management Sovereign Runtime Contract remains preserved.
- Homepage adaptive hero/surface-band closure remains preserved.
- Production remains not approved.
- Android runtime UAT remains deferred.

---

## Platform 12 — Public Subpages Visual System Rework Mega Batch — 2026-06-15

### القرار

تم اعتماد إعادة صقل شاملة للصفحات الفرعية العامة المنبثقة عن الصفحة الرئيسية بدل متابعة المعالجات الجزئية صفحة بصفحة. الهدف هو أن تمتلك الصفحات العامة نظامًا بصريًا واحدًا مع خصوصية وظيفية لكل صفحة.

### قواعد الواجهة العامة بعد هذه الدفعة

1. لا تُعرض معلومات تقنية أو حوكمية داخل واجهة المواطن العامة مثل RPC/RLS/source rows/owner schema/allowlist.
2. تبقى تفاصيل الحوكمة في لوحة الإدارة والوثائق التشغيلية لا في صفحات الجمهور.
3. تستخدم الصفحات الفرعية كثافة عرض compact عبر `PwfHomeVisualContract.publicSubpageVerticalPadding`.
4. يستخدم `PwfSectionContainer` منطقًا خاصًا للأقسام الفرعية العامة لتقليل الفراغ أسفل شريط الأدوات العام.
5. يستخدم `PwfPublicIntroCard` رأس صفحة عام compact بدل مربعات عنوان ضخمة.
6. يجب أن تكون النصوص المقروءة ذات تباين كافٍ مع الخلفيات الزرقاء أو البيضاء.
7. بطاقات الإحصائيات والحالات الفارغة تستخدم primitives موحدة من `PwfHomeVisualContract`.

### ملفات محورية

- `lib/features/platform/home/presentation/widgets/shared/pwf_home_visual_contract.dart`
- `lib/features/platform/home/presentation/widgets/pwf_section_container.dart`
- `lib/features/platform/home/presentation/screens/pages/pwf_public_content_shared.dart`
- `lib/features/platform/home/presentation/screens/pages/pwf_platform_frontend_pages.dart`
- `lib/features/platform/home/presentation/widgets/sections/pwf_platform_center_sections.dart`
- `test/features/platform/home/pwf_public_subpages_visual_system_rework_test.dart`

### حالة الحوكمة

لم يتم تنفيذ SQL.  
لم يتم استخدام `service_role`.  
لم يتم اعتماد الإنتاج.  
Android Runtime UAT مؤجل.

---

## Platform 12 Update — Public Subpages Analyze/Test Contract Closure — 2026-06-15

- Public subpage visual-system rework remains the active baseline for homepage-derived public pages.
- Analyzer closure requires valid Flutter font weights only; `FontWeight.w650` is not allowed.
- `PwfHomeVisualContract` must retain central visual identity tokens, including blue, gold, and royal red via `PwfHomePalette.royalRed`.
- Static placeholder pages should use shared public intro/empty-state primitives, not unused private card classes.
- Contract tests must assert durable visual-system contracts rather than stale literal implementation details from pre-rework layouts.
- No SQL was executed in this closure batch. Sovereign homepage RPC SQL remains a separate apply gate.

## Platform 12 Update — Public Governance Residue + Test Harness Closure — 2026-06-15

Public-facing pages must not expose technical governance diagnostics such as RPC/RLS/fallback/backend/source/allowlist/unitSlug/UAT wording. These details belong to admin screens, diagnostics, SQL/RPC runbooks, and governance documentation. Citizen pages must use public language: published content, available forms, request tracking, official records, and clear empty states.

The root Flutter widget test must remain a neutral harness and must not import stale template package names. Public visual-system tests now include a governance-residue guard.


## 2026-06-16 — Platform 12 public subpages full audit closure

Reference batch: `Platform 12 — Public Subpages Full Visual Audit + Governance Residue Closure Mega Batch`.

Rules reinforced:

1. Public pages must not display technical governance/source wording to visitors: RPC, RLS, SQL/UAT, fallback, backend, wrapper, allowlist, owner schema, source rows, `public.v_*`, `waqf_assets`, `mustakshif`, `cases`, `billing_system`, or `platform_services`.
2. Public interactive tools such as `/home/zakat` and `/home/chat` use a public masthead and public status language only. Their route/source/readiness contracts remain in internal docs, admin screens, diagnostics, and tests.
3. Public subpages use compact masthead density: `PwfPublicIntroCard` min-height `108/126`, frontend hub hero min-height `126/144`, and public subpage vertical padding `18/16/14`.
4. Complaints, Zakat, Chat, Structure, Announcements, News, Activities, Services, Contact, Static pages, and hub pages must remain visually aligned through shared primitives rather than page-specific hero blocks.
5. Any future public copy containing operator language must be blocked by `pwfIsTechnicalPublicNote` or rewritten into visitor-facing wording before release.
