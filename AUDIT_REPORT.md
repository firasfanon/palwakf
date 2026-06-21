# PalWaqf — Code Quality, UI Consistency, DRY & OOP Audit Report

**Date:** 2026-06-21
**Scope:** 745 files, ~205,000 lines — Flutter Web codebase
**Phase:** 1 — Audit & Plan (no code modified)

---

## 1. Executive Summary

| Category | Findings |
|----------|----------|
| UI/UX Clutter & Consistency | 30 |
| DRY Violations | 30 |
| OOP / Architecture | 30 |
| Known Issues (Part D) | 7 |
| **Total** | **97** |

The codebase has a proper design system (`PalWakfSisColors`) that is **never referenced** by any presentation file — all 242+ color references use legacy `AppConstants` or raw hex literals. The `tasks_system` feature contains **24 fully or partially duplicated data files** that have already started drifting. Two pub dependencies (`flutter_bloc`, `provider`) are declared but have **zero imports** anywhere. **162 files exceed 400 lines**, with the worst (`users_management_screen.dart`) at 5,394 lines mixing UI policy, audit logging, and multiple widget classes. A `.env` file with **live Supabase credentials** is tracked in git with no `.gitignore` entry.

---

## 2. Priority Matrix

### CRITICAL (fix immediately)

| ID | Cat | File(s) | Issue | Fix | Effort | Impact |
|----|-----|---------|-------|-----|--------|--------|
| D-5 | Security | `.env` | Live Supabase URL + anon key tracked in git, no `.gitignore` entry | Add to `.gitignore`, `git rm --cached`, rotate key | S | **CRITICAL** |
| D-1 | Bug | `task_form_screen.dart:220` | Hardcoded `'current_user_id'` string instead of real user ID | Replace with `Supabase.instance.client.auth.currentUser?.id` | S | High |

### HIGH (significant quality/maintenance impact)

| ID | Cat | File(s) | Issue | Fix | Effort | Impact |
|----|-----|---------|-------|-----|--------|--------|
| B-1 | DRY | 8 file pairs in `tasks_system/data/models/` | 100% identical copies of `lib/data/models/` | Delete duplicates, import shared | S | High |
| B-2 | DRY | 5 file pairs in `tasks_system/data/repositories/` | 100% identical copies of `lib/data/repositories/` | Delete duplicates, import shared | S | High |
| B-3 | DRY | 6 diverged model pairs + 10 diverged repo pairs | Forked copies with drift (up to 1886 diff lines) | Consolidate into shared versions | L | High |
| C-1 | OOP | `pubspec.yaml` | `flutter_bloc` + `provider` declared but 0 files use them | Remove dead dependencies | S | High |
| C-2 | OOP | `homepage_repository.dart` (2352 lines) | `SiteSettings` + `HeroSlide` model classes inside repo file | Move to `lib/data/models/` | S | High |
| C-3 | OOP | 7 files in `presentation/` | Direct `Supabase.instance.client` in presentation layer | Move to Riverpod providers | M | High |
| C-4 | OOP | `pwf_unit_pages_repository.dart` | Repository file placed inside `presentation/screens/` | Move to `data/repositories/` | S | High |
| D-2 | Bug | `mobile_cases_screen.dart:148` | `_getSampleCases()` returns hardcoded mock data in production | Wire up live `CaseRepository` | M | High |
| D-3 | Bug | `mobile_documents_screen.dart:239-298` | 5 TODO-stubbed actions (view/download/share/delete/file-picker) | Implement or remove the buttons entirely | M | High |
| D-4 | Noise | 25 files | `print()` statements in production code | Replace with logger or remove | S | High |
| D-7 | Dead | Root `presentation/` directory | 64 tracked files duplicating `lib/` content, zero imports | `git rm -r presentation/` | S | High |

### MEDIUM (consistency & maintainability)

| ID | Cat | File(s) | Issue | Fix | Effort | Impact |
|----|-----|---------|-------|-----|--------|--------|
| A-1 | UI | 0 files use `PalWakfSisColors` | Design system exists but is dead code; 242+ refs to legacy `AppConstants` + raw hex | Migrate to `PalWakfSisColors` | L | Med |
| A-2 | UI | 3 competing color systems | `AppConstants` (13 colors) vs `PalWakfSisColors` (12) vs `PwfGlobalLayoutContract` (5) | Consolidate into `PalWakfSisColors` | M | Med |
| A-3 | UI | `web_admin_dashboard.dart` | 20+ raw `Color(0xFF...)` literals | Replace with theme tokens | M | Med |
| A-4 | UI | 8+ screens | Each reimplements empty state differently (or not at all) | Create shared `AppEmptyState` widget | M | Med |
| A-5 | UI | 10+ screens | Copy-pasted confirmation dialog pattern | Use existing `dialog_builder.dart` | M | Med |
| A-6 | UI | Multiple management screens | Section header typography: `fontSize: 20` vs `18`, `FontWeight.bold` vs `.w800` | Extract `AppTextStyles.sectionHeader` | S | Med |
| A-7 | UI | Multiple management screens | Card content padding: `EdgeInsets.all(20)` vs `all(16)` | Standardize to one value | S | Med |
| A-8 | UI | `admin_app_bar.dart:80,150,156` | Notification, Settings, Help buttons show SnackBar stubs | Implement or remove | S | Med |
| B-4 | DRY | 3 screens | Identical `_buildStatCard` widget reimplemented | Extract shared `AdminStatCard` | S | Med |
| B-5 | DRY | 154 instances | Bare `CircularProgressIndicator()` repeated | Create `AppLoadingIndicator` | S | Med |
| B-6 | DRY | 150+ try/catch blocks across repos | Identical Supabase error-handling pattern | Extract `SupabaseRepository<T>` base class | M | Med |
| B-7 | DRY | `web_search_screen.dart:769`, `mobile_search_screen.dart:508` | Identical Arabic diacritics stripping regex | Extract to `arabic_text_utils.dart` | S | Med |
| C-5 | OOP | 47 screens | Each reimplements `_searchQuery` + `_applyFilters` | Create `SearchableAdminMixin` | M | Med |
| C-6 | OOP | 19/24 repositories | Concrete-only, no abstract interface (79% non-testable) | Add abstract classes for high-use repos | L | Med |
| C-7 | OOP | 100 `_screen.dart` vs 50 `_page.dart` | Naming split correlates with old vs new architecture, not semantics | Standardize on one convention | L | Med |
| D-6 | Noise | 30+ files (395 instances) | `log()` statements concentrated in repositories | Replace with configurable logger | M | Med |

### LOW (cleanup, nice-to-have)

| ID | Cat | File(s) | Issue | Fix | Effort | Impact |
|----|-----|---------|-------|-----|--------|--------|
| A-9 | UI | `hero_slider_management_screen.dart:831` | Subtitle "ابدأ بإضافة شريحة جديدة" restates what the Add button already says | Remove redundant text | S | Low |
| A-10 | UI | `mobile_admin_dashboard.dart:115` | `Colors.purple` — no purple in design system | Use `PalWakfSisColors.restrictedPurple` | S | Low |
| C-8 | OOP | 162 files over 400 lines | God classes (largest: 5,394 lines) | Split into focused files | L | Med |
| C-9 | OOP | `pwf_platform_frontend_pages.dart` (2709 lines) | 6+ unrelated screen classes in one file | One file per screen | M | Low |
| C-10 | OOP | `settings_screen.dart:18` | Data classes (`_VisualIdentityDraftEntry`, etc.) defined in screen file | Move to models | S | Low |

---

## 3. Detailed Findings

### Part A — UI/UX Consistency & Clutter

#### A-1: Dead Design System
- **`lib/core/theme/palwakf_sis_colors.dart`** — Full `ThemeExtension<PalWakfSisColors>` with light/dark mode support and 12 semantic color properties.
- **Usage:** 0 references in any presentation file.
- **Instead:** `AppConstants` (242 occurrences in presentation/) and 20+ raw `Color(0xFF...)` hex literals per screen.
- **Fix:** Phase migration — update one admin screen group at a time to pull colors from `Theme.of(context).extension<PalWakfSisColors>()`.

#### A-2: Three Competing Color Systems
| System | File | Colors | Usage |
|--------|------|--------|-------|
| `AppConstants`/`AppColors` | `lib/core/constants/app_constants.dart:37-49` | 13 | 242 refs |
| `PalWakfSisColors` | `lib/core/theme/palwakf_sis_colors.dart:33-46` | 12 | 0 refs |
| `PwfGlobalLayoutContract` | `lib/core/layout/pwf_global_layout_contract.dart:27-31` | 5 | limited refs |

Primary blue differs: `0xFF0F4C81` (AppConstants) vs `0xFF1E4E89` (PalWakfSisColors).

#### A-3: Hardcoded Colors in Dashboard
- `web_admin_dashboard.dart:109` — `Color(0xFFF8FAFC)` background
- `web_admin_dashboard.dart:149` — `Color(0xFFE5E7EB)` border
- `web_admin_dashboard.dart:166` — `Color(0xFF0F4C81)` primary
- `web_admin_dashboard.dart:269-279` — `Color(0xFFFFFBEB)`, `Color(0xFFFDE68A)`, `Color(0xFF92400E)` warning banner
- `users_management_screen.dart:1123` — Same warning banner colors duplicated

#### A-4: Inconsistent Empty States
| Screen | Implementation |
|--------|---------------|
| `hero_slider_management_screen.dart:819` | Icon(size:100) + fontSize:24 title + subtitle + button |
| `users_management_screen.dart:2237` | Plain centered Text, no icon |
| `breaking_news_management_screen.dart:564` | `_buildEmptyState()` private method |
| `activities_management_screen.dart:377` | `_buildEmptyState(status)` with parameter |
| `web_services_screen.dart:878` | Yet another `_buildEmptyState()` |

A `SharedAdminEmptyState` widget exists at `lib/presentation/screens/admin/main/management/home_management/widgets/shared/shared_content_admin_ui.dart:218` but none of the above use it.

#### A-5: Copy-Pasted Confirmation Dialogs
10+ screens implement their own "تأكيد الحذف" (Confirm Delete) AlertDialog:
- `task_detail_screen.dart:54`
- `mobile_documents_screen.dart:263`
- `web_documents_screen.dart:531`
- `breaking_news_management_screen.dart:740`
- `hero_slider_section.dart:579`
- `media_gallery_management_section.dart:1134`

A `dialog_builder.dart` exists at `lib/core/utils/dialog_builder.dart` but these screens don't use it.

#### A-6: Typography Inconsistency
- Section headers: `fontSize: 20` (dashboard:623) vs `fontSize: 18` (dashboard:1033+) vs `fontSize: 16` + `w800` (users:1297)
- Stat values: `fontSize: 22` (users:1446) vs `fontSize: 18` (users:1918)
- Muted text: `fontSize: 12` (activities:193) vs `fontSize: 14` (hero:723)
- Weight convention: `.bold` vs `.w800` used interchangeably

#### A-7: Padding Inconsistency
- Card content: `EdgeInsets.all(20)` (activities:166) vs `all(16)` (hero:652, users:707)
- Page horizontal: `horizontal: 24` (activities:76) vs `horizontal: 24, vertical: 8` (hero:154)
- Empty state: `SizedBox(height: 32)` (hero:834) vs `vertical: 48` (users:2239)

#### A-8: Stub UI Actions in AppBar
- `admin_app_bar.dart:80` — Notification button: `// TODO: Navigate to notifications`
- `admin_app_bar.dart:150` — Settings menu: `// TODO: Navigate to settings`
- `admin_app_bar.dart:156` — Help menu: shows SnackBar instead of navigating

#### A-9: Redundant Explanatory Text
- `hero_slider_management_screen.dart:831` — "ابدأ بإضافة شريحة جديدة" subtitle below an "Add Slide" button
- `users_management_screen.dart:1148` — Count text inside a governance banner that already has a title

---

### Part B — DRY Violations

#### B-1/B-2: Identical File Duplicates (tasks_system)

**8 identical model pairs (0 diff lines):**
1. `lib/data/models/task.dart` ↔ `lib/features/tasks_system/data/models/task.dart`
2. `lib/data/models/user.dart` ↔ `lib/features/tasks_system/data/models/user.dart`
3. `lib/data/models/case.dart` ↔ `lib/features/tasks_system/data/models/case.dart`
4. `lib/data/models/mosque.dart` ↔ `lib/features/tasks_system/data/models/mosque.dart`
5. `lib/data/models/friday_sermon.dart` ↔ `lib/features/tasks_system/data/models/friday_sermon.dart`
6. `lib/data/models/waqf_land.dart` ↔ `lib/features/tasks_system/data/models/waqf_land.dart`
7. `lib/data/models/header_settings.dart` ↔ `lib/features/tasks_system/data/models/header_settings.dart`
8. `lib/data/models/task_service.dart` ↔ `lib/features/tasks_system/data/models/task_service.dart`

**5 identical repository pairs (0 diff lines):**
1. `case_repository.dart`
2. `friday_sermons_repository.dart`
3. `news_repository.dart`
4. `user_repository.dart`
5. `waqf_land_repository.dart`

#### B-3: Diverged File Duplicates

**6 diverged model pairs:**
- `announcement.dart` — shared version adds 7 fields
- `activity.dart`, `admin_user.dart`, `news_article.dart`, `footer_settings.dart`, `homepage_section.dart` — various drift

**10 diverged repository pairs (by diff size):**
- `homepage_repository.dart` — 1886 diff lines (most diverged)
- `activity_repository.dart` — 594 diff lines
- `announcement_repository.dart` — 495 diff lines
- `media_gallery_repository.dart` — 462 diff lines
- `footer_repository.dart` — 446 diff lines
- `admin_users_repository.dart` — 295 diff lines
- `org_units_repository.dart` — 257 diff lines
- `header_repository.dart` — 199 diff lines
- `auth_repository.dart` — 137 diff lines
- `rbac_admin_repository.dart` — 26 diff lines

#### B-4: Copy-Pasted Stat Card Widgets
- `web_cases_screen.dart:157` — `_buildStatCard(label, value, color, icon)`
- `web_waqf_lands_screen.dart:148` — near-identical `_buildStatCard`
- `tasks_management_screen.dart:180` — `_buildStatItem(label, count, color)`

#### B-5: Bare CircularProgressIndicator
154 instances of `const Center(child: CircularProgressIndicator())` across the codebase.

#### B-6: Repository Try/Catch Pattern
Every repository method follows:
```dart
try {
  final response = await _supabase.from('table').select()...;
  return response.map((json) => Model.fromJson(json)).toList();
} catch (e) {
  throw Exception('Failed to load X: $e');
}
```
Top offenders: `homepage_repository.dart` (33), `waqf_land_repository.dart` (19), `case_repository.dart` (17).

#### B-7: Duplicated Arabic Text Utils
- `web_search_screen.dart:769` and `mobile_search_screen.dart:508` — identical diacritics stripping:
  `.replaceAll(RegExp(r'[ً-ٰٟ]'), '')`

---

### Part C — OOP & Architecture

#### C-1: Dead Dependencies
- `flutter_bloc: ^9.1.1` — 0 imports across entire codebase
- `provider: ^6.1.1` — 0 imports across entire codebase
- Riverpod is the sole state management framework (241 files)

#### C-2: Models Inside Repository File
`homepage_repository.dart` contains:
- `SiteSettings` class at line 1423
- `HeroSlide` class at line 1590
- Both should be in `lib/data/models/`

#### C-3: Supabase in Presentation Layer (7 violations)
| File | Line | Instance |
|------|------|----------|
| `breaking_news_management_screen.dart` | 13 | `HomepageRepository(Supabase.instance.client)` top-level |
| `hero_slider_management_screen.dart` | 14 | `HomepageRepository(Supabase.instance.client)` top-level |
| `settings_screen.dart` | 65 | `PwfVisualIdentityPublishRepository(...)` in provider lambda |
| `pwf_homepage_sections_manager.dart` | 70 | `HomepageRepository(...)` |
| `pwf_homepage_sections_manager.dart` | 74 | `OrgUnitsRepository(...)` |
| `shared_content_media_upload_helper.dart` | 41 | Direct `storage.from(bucket)` |
| `pwf_unit_pages_repository.dart` | 335 | Repository file inside `presentation/screens/` |

#### C-4: Repository file in wrong layer
`lib/presentation/screens/admin/main/management/home_management/pwf_unit_pages_repository.dart` — a data access class placed inside the presentation directory.

#### C-5: Search/Filter Reimplemented 47 Times
26+ files in `lib/presentation/screens/` implement their own `_searchQuery` string + `_applyFilters` method, including cases, lands, documents, sermons, activities, users, mosques.

No shared `SearchableAdminMixin` or `CrudAdminController` exists.

#### C-6: Repository Pattern Split
- **5 repos** use abstract+impl (all in `features/`)
- **19 repos** are concrete-only (all in `data/repositories/`)
- Recommendation: Add abstract interfaces for the 6 most-used repos (`homepage`, `admin_users`, `auth`, `case`, `waqf_land`, `announcement`). Leave simple single-table repos concrete.

#### C-7: Naming Convention Split
- `_screen.dart` — 100 files (84 in `presentation/`, 16 in `features/`)
- `_page.dart` — 50 files (1 in `presentation/`, 49 in `features/`)
- Split correlates with old arch vs new arch, not semantics

#### C-8: God Classes (Top 20 by line count)
| Lines | File |
|-------|------|
| 5,394 | `users_management_screen.dart` |
| 2,955 | `settings_screen.dart` |
| 2,709 | `pwf_platform_frontend_pages.dart` |
| 2,700 | `pwf_surfaces_services_admin_hub_screen.dart` |
| 2,358 | `media_center_operational_pages.dart` |
| 2,352 | `homepage_repository.dart` |
| 2,298 | `media_center_dashboard_page.dart` |
| 2,244 | `pwf_technical_services_page.dart` |
| 1,931 | `web_homepage_management_screen.dart` |
| 1,923 | `pwf_database_domain_migration_page.dart` |
| 1,850 | `pwf_public_schema_controlled_migration_contract.dart` |
| 1,720 | `web_admin_dashboard.dart` |
| 1,619 | `pwf_news_pages.dart` |
| 1,517 | `admin_panel_registry.dart` |
| 1,492 | `pwf_content_pages_primary.part.dart` |
| 1,469 | `web_mosques_details_screen.dart` |
| 1,448 | `web_contact_screen.dart` |
| 1,396 | `media_gallery_management_section.dart` |
| 1,362 | `pwf_misc_pages.dart` |
| 1,359 | `mobile_mosques_screen.dart` |

**Total: 162 files exceed 400 lines.**

---

### Part D — Known Issues Verification

| ID | Issue | Status | Location | Fix |
|----|-------|--------|----------|-----|
| D-1 | Hardcoded `'current_user_id'` | **STILL PRESENT** | `task_form_screen.dart:220` | Use real auth user ID |
| D-2 | Mock data in cases screen | **STILL PRESENT** | `mobile_cases_screen.dart:148` | Wire up `CaseRepository` |
| D-3 | Unimplemented document actions | **STILL PRESENT** | `mobile_documents_screen.dart:239-298` (5 stubs) | Implement or remove UI |
| D-4 | `print()` in production | **STILL PRESENT** | 25 occurrences across 10 files | Replace with logger |
| D-5 | `.env` with live credentials | **CRITICAL** | `.env` lines 8-9 (Supabase URL + anon key) | gitignore + rotate key |
| D-6 | Excessive `log()` calls | **STILL PRESENT** | 395 occurrences across 30+ files | Configurable logger |
| D-7 | Stale root `presentation/` | **STILL PRESENT** | 64 tracked files, 0 imports from `lib/` | `git rm -r presentation/` |

---

## 4. Proposed Shared Components to Create

| Name | Location | Responsibility | Replaces |
|------|----------|---------------|----------|
| `AppEmptyState` | `lib/presentation/widgets/common/` | Reusable empty state with icon, title, optional subtitle + action button | 8+ private `_buildEmptyState()` methods |
| `AppLoadingIndicator` | `lib/presentation/widgets/common/` | Branded loading spinner (optional message) | 154 bare `CircularProgressIndicator` instances |
| `AppConfirmDialog` | `lib/core/utils/` | Confirmation dialog (extends existing `dialog_builder.dart`) | 10+ copy-pasted AlertDialog patterns |
| `AdminStatCard` | `lib/presentation/widgets/admin/` | Stat card with icon + value + label | 3 private `_buildStatCard`/`_buildStatItem` methods |
| `AppTextStyles` | `lib/core/theme/` | Semantic text styles (`sectionHeader`, `cardTitle`, `mutedBody`, etc.) | Inconsistent fontSize/weight combinations |
| `AppSpacing` | `lib/core/theme/` | Spacing constants (`pagePadding`, `cardPadding`, `sectionGap`) | Inconsistent EdgeInsets values |
| `SearchableAdminMixin` | `lib/presentation/mixins/` | Shared `_searchQuery` + filter logic for admin CRUD screens | 47 reimplementations of search/filter |
| `SupabaseRepositoryHelper` | `lib/data/` | Generic `query<T>()` method with standard error handling | 150+ identical try/catch blocks |
| `ArabicTextUtils` | `lib/core/utils/` | Diacritics stripping, whitespace normalization | 2 duplicate implementations |

---

## 5. Recommended Implementation Order

### Batch 0 — Security & Dead Code (no visual impact)
- [ ] Add `.env` to `.gitignore`, `git rm --cached .env`, rotate Supabase key
- [ ] Remove dead `presentation/` root directory (`git rm -r presentation/`)
- [ ] Remove dead dependencies (`flutter_bloc`, `provider`) from `pubspec.yaml`
- [ ] Remove all `print()` statements from production code
- **Risk:** None — no UI changes, no behavioral changes
- **Verify:** `flutter build web` succeeds

### Batch 1 — Delete Identical Duplicates (no visual impact)
- [ ] Delete 8 identical model files in `tasks_system/data/models/`
- [ ] Delete 5 identical repository files in `tasks_system/data/repositories/`
- [ ] Update imports in `tasks_system` to point to `lib/data/`
- **Risk:** Low — import path changes only, identical code
- **Verify:** `flutter build web` + `flutter analyze`

### Batch 2 — Fix Bugs & Stubs (minimal visual impact)
- [ ] Fix `task_form_screen.dart:220` — real user ID
- [ ] Fix `mobile_cases_screen.dart` — wire up live data (or hide the screen if not ready)
- [ ] Fix `mobile_documents_screen.dart` — implement actions or remove non-functional buttons
- [ ] Fix `admin_app_bar.dart` — implement or remove stub buttons
- **Risk:** Low-Medium — behavioral fixes, some UI elements removed
- **Verify:** Manual testing of each screen

### Batch 3 — Extract Shared Widgets (visual standardization)
- [ ] Create `AppEmptyState`, `AppLoadingIndicator`, `AppConfirmDialog`, `AdminStatCard`
- [ ] Migrate 8+ empty state screens to `AppEmptyState`
- [ ] Migrate 10+ confirmation dialogs to `AppConfirmDialog`
- [ ] Migrate 3 stat card screens to `AdminStatCard`
- **Risk:** Medium — visual changes across multiple screens
- **Verify:** Side-by-side comparison of each migrated screen

### Batch 4 — Architecture Cleanup (no visual impact)
- [ ] Move `SiteSettings` + `HeroSlide` models out of `homepage_repository.dart`
- [ ] Move `pwf_unit_pages_repository.dart` from presentation to data layer
- [ ] Move 7 Supabase instantiations from screens to Riverpod providers
- [ ] Create `SupabaseRepositoryHelper` base class
- **Risk:** Low — internal refactoring only
- **Verify:** `flutter build web` + `flutter analyze`

### Batch 5 — Design System Migration (visual changes)
- [ ] Consolidate three color systems into `PalWakfSisColors`
- [ ] Create `AppTextStyles` and `AppSpacing` constants
- [ ] Migrate dashboard + management screens to theme tokens
- **Risk:** Medium-High — colors may shift slightly due to value differences between `AppConstants` and `PalWakfSisColors`
- **Verify:** Visual comparison of every migrated screen

### Batch 6 — Search/Filter Unification (no visual impact)
- [ ] Create `SearchableAdminMixin`
- [ ] Migrate top 10 admin CRUD screens to use the mixin
- **Risk:** Medium — behavioral logic moves to shared code
- **Verify:** Test search/filter on each migrated screen

### Batch 7 — God Class Splitting (no visual impact)
- [ ] Split `users_management_screen.dart` (5394 → multiple files)
- [ ] Split `settings_screen.dart` (2955 → multiple files)
- [ ] Split `pwf_platform_frontend_pages.dart` (2709 → one per screen)
- [ ] Split `media_center_operational_pages.dart` (2358 → individual pages)
- [ ] Extract data classes from screen files to models
- **Risk:** Medium — large structural changes, must preserve all behavior
- **Verify:** `flutter build web` + manual testing of affected screens

### Batch 8 — Consolidate Diverged Duplicates (no visual impact)
- [ ] Merge 6 diverged model pairs back into shared versions
- [ ] Merge 10 diverged repository pairs (most complex batch)
- **Risk:** High — requires careful diff analysis to avoid losing features added in forks
- **Verify:** Full regression testing

---

## 6. Visual Impact List

The following findings will **visibly change** screen appearance when implemented. Review these specifically before approving.

| Batch | Finding | Screen(s) Affected | Visual Change |
|-------|---------|--------------------|---------------|
| 2 | Remove stub buttons in AppBar | All admin screens | Notification bell / Settings / Help menu items removed if not implemented |
| 2 | Remove non-functional document buttons | `mobile_documents_screen` | View/Download/Share/Delete buttons removed |
| 3 | Standardize empty states | 8+ admin screens | Empty states will have consistent icon, title, and action button layout |
| 3 | Standardize stat cards | Cases, Lands, Tasks screens | Stat cards will have uniform styling |
| 5 | Migrate to `PalWakfSisColors` | All migrated screens | Primary blue shifts from `0xFF0F4C81` → `0xFF1E4E89` (slightly lighter); warning colors standardized |
| 5 | Standardize typography | Management screens | Section headers, stat values, and muted text will have uniform sizes/weights |
| 5 | Standardize spacing | Management screens | Card padding and page margins will be uniform |
| A-9 | Remove redundant subtitle text | `hero_slider_management_screen` | "ابدأ بإضافة شريحة جديدة" subtitle removed from empty state |

---

*End of audit report. Awaiting approval of batch(es) to implement.*
