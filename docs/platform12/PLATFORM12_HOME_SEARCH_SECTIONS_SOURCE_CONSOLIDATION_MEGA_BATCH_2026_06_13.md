# Platform 12 — Home Search + Homepage Sections Source Consolidation Mega Batch

Date: 2026-06-13  
Session: تطوير المنصة 12  
Execution mode: Large governed Flutter/Supabase batch  
SQL status: Not executed  
Production approval: Not approved

## 1. Purpose

This Mega Batch consolidates the public home search flow and the homepage sections source chain. It addresses two operational findings from the current session:

1. The homepage/public search button was previously not producing useful search results.
2. Some homepage sections appeared duplicated because legacy section keys and canonical section keys coexisted in the read surface.

The batch also absorbs the browser evidence showing that `/home/search?q=مسجد` now returns results while DevTools-constrained width exposed a `WebAppBar` overflow requiring responsive hardening.

## 2. Search flow decision

The governed search route is:

```text
/home/search?q=<query>
/<unitSlug>/search?q=<query>
```

Runtime flow:

```text
Header search input / WebAppBar search button
→ GoRouter route with q query parameter
→ SearchScreen
→ WebSearchScreen or MobileSearchScreen
→ governed local public-route search index
→ result cards route to public pages
```

The current search index is intentionally local and route-based. It does not claim to be a full-text database search. A database-backed search RPC can be added later after public search scope, ranking, language normalization, and privacy rules are approved.

## 3. Search implementation updates

- Header search submits non-empty queries to `/home/search?q=...` or `/<unitSlug>/search?q=...`.
- The search screen reads the initial `q` parameter from `GoRouterState.uri.queryParameters`.
- Web and mobile search screens use a governed indexed public-route search method, not placeholder/mock terminology.
- Re-searching from inside the search page synchronizes the URL query by replacing the current route with the new `q` value.
- Empty queries clear the local result list and keep the search page stable.

## 4. Web constrained-width hardening

The evidence screenshot showed search results rendering, but Chrome DevTools reduced the viewport and produced `RenderFlex overflowed` messages in the top public web app bar.

The responsive hardening keeps the app bar operational under constrained width by:

- using width-aware layout decisions;
- compacting the full navigation into a menu when width is constrained;
- reducing app bar padding and gaps;
- hiding non-essential language text at narrower widths;
- stacking search results and sidebar below the narrow breakpoint;
- replacing fixed summary rows with wrap-safe layouts.

## 5. Homepage sections source chain

The runtime source of homepage sections is certified as:

```text
PwfHomeWebScreen
→ homepageSectionsForUnitProvider
→ HomepageRepository.fetchAllSectionsForUnit
→ public.v_platform_homepage_sections_compat_v1
→ PwfHomeSectionsRenderer
```

`public.homepage_sections` remains a preserved legacy write surface for existing admin operations only until owner-write RPCs are approved. Public/runtime reads must remain through compatibility views/wrappers.

## 6. Duplicate section handling

The received read-only SQL evidence confirmed canonical duplicate families. The key operational result:

```text
pwf_footer = ["pwf_footer", "footer"]
active_count = 2
```

Other canonical duplicate pairs had only one active row and therefore are mainly governance-cleanup candidates:

```text
news / pwf_news_tabs
services / pwf_quick_services
minister / pwf_minister_word
statistics / pwf_stats_grid
announcements / pwf_announcements
breaking_news / pwf_breaking_news_marquee
```

Runtime mitigation in this batch:

- legacy section keys are canonicalized in the repository and renderer;
- deterministic ordering is applied when fetching scoped rows;
- canonical rows are preferred over legacy aliases when duplicates exist;
- active rows are preferred over inactive rows when resolving a duplicate key;
- frontend rendering still renders each canonical section key once.

## 7. Semantic overlaps requiring policy decision

These are not automatically deleted because each pair may represent two valid UX sections:

```text
links_family: pwf_important_links + pwf_quick_links_grid
media_gallery_family: pwf_media_gallery_images + pwf_media_gallery_videos
news_family: pwf_news_tabs + pwf_news
services_family: pwf_eservices_portal + pwf_quick_services
```

Required decision: choose whether each semantic family should render both sections or one official section only.

## 8. SQL boundary

No SQL was executed by this Mega Batch.

Prepared SQL files remain guarded/read-only or operator-authorized only:

```text
sql_sandbox/platform12_home_search_sections_source_audit_read_only/
sql_sandbox/platform12_homepage_sections_duplicate_remediation_guarded/
```

The guarded DML must not be executed without explicit authorization.

## 9. Verification required on the user machine

```powershell
flutter analyze
flutter test
flutter run -d chrome
```

Browser UAT routes:

```text
/home/search?q=مسجد
/home/search?q=الخدمات
/home/search?q=الأخبار
/home/search?q=إعلان
```

Viewport evidence required:

```text
Chrome normal width: no search failure
Chrome with DevTools docked: no new WebAppBar RenderFlex overflow
```

## 10. Current decision

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
