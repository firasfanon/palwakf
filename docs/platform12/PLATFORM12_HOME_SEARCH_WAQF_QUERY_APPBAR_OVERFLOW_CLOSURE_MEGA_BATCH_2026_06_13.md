# Platform 12 — Home Search Waqf Query + WebAppBar Overflow Closure Mega Batch

**Session:** تطوير المنصة 12  
**Date:** 2026-06-13  
**Mode:** Mega Batch / دفعة تطوير كبيرة  
**SQL:** لم يتم تنفيذ SQL  
**Production:** غير معتمد إنتاجيًا

## 1. Evidence intake

The received browser evidence showed two distinct outcomes:

1. `/home/search?q=مسجد` renders correctly and returns `نتائج البحث (1)` for `المساجد` under a normal browser width.
2. `/home/search?q=وقف` with the `الوثائق` category selected returned `لا توجد نتائج`, although `وقف` is a core platform term and should resolve to public/governed waqf-related navigation entries.
3. The public web app bar still emitted `RenderFlex overflowed` under a constrained viewport when Chrome DevTools was docked. The overflow appeared both around the normal navigation band and under the compact menu state.

Evidence files preserved:

```text
docs/platform12/evidence/search_waqf_no_results_narrow_devtools_2026_06_13.png
docs/platform12/evidence/search_masjid_result_normal_width_2026_06_13.png
```

## 2. Scope of this Mega Batch

This batch does not change the database and does not change homepage section records. It targets only the frontend runtime issues proven by the evidence:

- Search index Arabic normalization and waqf query coverage.
- Web/mobile search parity for the governed public-route index.
- WebAppBar overflow hardening for DevTools / constrained viewport widths.
- Preservation of the earlier homepage sections source decision.

## 3. Search remediation

### Files changed

```text
lib/presentation/screens/public/search/web_search_screen.dart
lib/presentation/screens/public/search/mobile_search_screen.dart
```

### Changes

- Added governed waqf-related result entry:

```text
مستكشف الوقف → /mustakshif
category = documents
```

- Added `وقف`, `وقفي`, `أوقاف/اوقاف`, `أصول وقفية`, `أراضي وقفية`, `مستكشف`, and map-related keywords.
- Extended the homepage and legal references entries with waqf-related keywords.
- Added Arabic normalization for:
  - diacritics
  - tatweel
  - hamza forms
  - ta marbuta
  - alif maqsura
  - waw/yaa hamza forms
- Added query-term expansion so a short query such as `وقف` can match `أوقاف`, `وقفي`, and related indexed public terms.

### Expected result

```text
/home/search?q=وقف
```

Should no longer return an empty result set when `الكل` or `الوثائق` is selected.

## 4. WebAppBar overflow remediation

### File changed

```text
lib/presentation/widgets/web/web_app_bar.dart
```

### Changes

- Raised the compact navigation threshold to avoid rendering the full Arabic navigation row around widths where it was proven to overflow.
- Added a constrained logo max width.
- Added a single action strip for compact menu, language selector, search, and login/user controls.
- Wrapped the action strip in `FittedBox(scaleDown)` to prevent right-side `RenderFlex` overflow under constrained widths.
- Wrapped full navigation in `FittedBox(scaleDown)` for the non-compact branch.
- Standardized compact action buttons to fixed 44px square controls.
- Forced header row directionality to RTL to keep layout order deterministic.

## 5. Preserved decisions

Homepage section runtime source remains:

```text
PwfHomeWebScreen
→ homepageSectionsForUnitProvider
→ HomepageRepository.fetchAllSectionsForUnit
→ public.v_platform_homepage_sections_compat_v1
→ PwfHomeSectionsRenderer
```

The semantic section-family policy remains pending. No SQL cleanup was executed for `pwf_footer/footer` or any other duplicate.

## 6. Current decision

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

## 7. Required local validation

```powershell
flutter analyze
flutter test
flutter run -d chrome
```

Manual UAT:

```text
/home/search?q=وقف        category=الكل
/home/search?q=وقف        category=الوثائق
/home/search?q=مسجد       category=الكل
/home/search?q=مسجد       category=المساجد
/home/search?q=الخدمات    category=الخدمات
/home/search?q=الأخبار    category=الأخبار
```

Responsive UAT:

```text
1. Open Chrome DevTools docked right.
2. Test viewport widths close to the submitted evidence.
3. Confirm that the console no longer reports RenderFlex overflow from WebAppBar.
4. Confirm the compact menu appears instead of a clipped full navigation row under constrained widths.
```
