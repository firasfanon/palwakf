# Platform 12 — Home Search + Homepage Sections Source Audit

Date: 2026-06-13
Batch: `PLATFORM12_HOME_SEARCH_AND_SECTIONS_SOURCE_REMEDIATION`

## Scope

This batch temporarily defers the Android runtime UAT gate and focuses on two public-home runtime issues:

1. Homepage header search box does not return results.
2. Homepage sections appear duplicated or unclear in source ownership.

## Finding 1 — Homepage search box

The active web home route uses:

```text
lib/presentation/screens/public/home/home_screen.dart
→ PwfHomeWebScreen
→ PwfHeader
→ PwfMainHeader
→ _SearchBox
```

The active header search box was not connected to the search page. The search icon click only displayed:

```text
البحث قيد الربط
```

Therefore the issue was not a backend/RPC failure. It was an incomplete frontend action binding.

## Remediation 1

Changed the active header and the legacy mirror header so that:

```text
lib/features/platform/home/presentation/widgets/header/pwf_main_header.dart
lib/presentation/widgets/header/pwf_main_header.dart
```

The search behavior now ensures:

- pressing Enter submits search;
- clicking the search icon submits search;
- an empty query opens the scoped search page;
- a non-empty query opens the scoped search page with `q=<query>`;
- ministry home scope routes to `/home/search?q=...`;
- unit scopes route to `/<unitSlug>/search?q=...`.

Search routes now pass the `q` query parameter to the search screen.

## Finding 2 — Search page initial query

`SearchScreen`, `WebSearchScreen`, and `MobileSearchScreen` previously did not accept an initial query from the URL. Even if the header navigated with a query, the search page would not auto-run the search.

## Remediation 2

Updated search screens to accept:

```dart
initialQuery
unitSlug
```

The web and mobile search screens now initialize the search field from `q`, run the search after first frame, and expose clickable route results.

The current search surface remains a frontend site-map index, not a sovereign backend search engine. This is intentional for this patch because no SQL/RPC production search surface was authorized in this batch.

## Finding 3 — Homepage sections source

The active homepage sections path is:

```text
PwfHomeWebScreen
→ homepageSectionsForUnitProvider(unitSlug)
→ HomepageRepository.fetchAllSectionsForUnit
→ PwfHomeSectionsRenderer
```

The actual runtime source should be:

```text
public.v_platform_homepage_sections_compat_v1
```

However, the unit-aware read path in `fetchAllSectionsForUnit` was reading directly from:

```text
public.homepage_sections
```

This contradicted the wrapper-read governance pattern and made section source diagnosis less reliable.

## Remediation 3

Updated `HomepageRepository.fetchAllSectionsForUnit` to read through:

```text
v_platform_homepage_sections_compat_v1
```

The method still preserves the scoped precedence chain:

```text
NULL global rows → synthetic global unit → home unit → current unit
```

But the merge key is now canonicalized using known legacy aliases, so rows like:

```text
news → pwf_news_tabs
services → pwf_quick_services
footer → pwf_footer
```

are treated as the same logical section during merge.

## Finding 4 — Admin manager could activate new catalog rows unintentionally

The home sections admin manager normalizes rows to the official catalog. Missing catalog keys were being added to the draft as `isActive: true`.

This means that if the catalog gained new sections, saving from the manager could activate many sections at once, including semantically overlapping blocks such as:

```text
pwf_news_tabs + pwf_news
pwf_media_gallery + pwf_media_gallery_images + pwf_media_gallery_videos
pwf_quick_services + pwf_public_services_catalog + pwf_eservices_portal
```

## Remediation 4

Missing catalog rows are now shown in the admin manager for discoverability, but they default to inactive unless they are pinned shell sections:

```text
pwf_top_bar
pwf_main_nav
pwf_footer
```

This prevents accidental public duplication when the admin saves the sections manager.

## Read-only diagnostic SQL

Added read-only diagnostic scripts under:

```text
sql_sandbox/platform12_home_search_sections_source_audit_read_only/
```

These scripts identify:

- the actual source/view/table presence;
- duplicate canonical section keys by unit scope;
- semantically overlapping active section families.

## Validation performed in this environment

Static file inspection and targeted grep validation were performed.

Not executed in this sandbox:

```text
flutter analyze
flutter test
browser UAT
```

Reason: Flutter/Dart SDK is not available inside the current sandbox. The patch is source-level and requires local project validation on the user's Windows/Flutter environment.

## Required local validation

Run:

```powershell
flutter analyze
flutter test
flutter run -d chrome
```

Manual UAT:

1. Open `/home`.
2. Type `الخدمات` in the header search box and press Enter.
3. Confirm navigation to `/home/search?q=...`.
4. Confirm search results render.
5. Click a result and confirm it navigates to the correct scoped route.
6. Open homepage sections manager and confirm newly missing catalog entries do not become active by default.
7. Run the read-only SQL diagnostics and check duplicate canonical keys.

## Decision

```text
HOME_SEARCH_FRONTEND_BINDING_PATCHED
HOMEPAGE_SECTIONS_RUNTIME_SOURCE_REPOINTED_TO_COMPAT_VIEW
ADMIN_CATALOG_MISSING_KEYS_DEFAULT_INACTIVE
READ_ONLY_DIAGNOSTIC_SQL_PREPARED
ANDROID_RUNTIME_UAT_DEFERRED
NO_SQL_EXECUTED
NO_PRODUCTION_APPROVAL
```
