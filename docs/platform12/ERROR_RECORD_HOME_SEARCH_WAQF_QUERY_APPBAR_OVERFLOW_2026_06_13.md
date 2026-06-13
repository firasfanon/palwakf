# Error Record — Home Search Waqf Query + WebAppBar Overflow

**Session:** تطوير المنصة 12  
**Date:** 2026-06-13  
**Mode:** Mega Batch evidence intake + frontend closure  
**Latest stable baseline before this batch:** `platform12_home_search_sections_source_consolidation_mega_batch_2026_06_13.zip`

## Error 1 — Search query `وقف` returned no results

### Symptom

The evidence showed:

```text
/home/search?q=وقف
selected category = الوثائق
result = لا توجد نتائج
```

### Cause

The governed local public-route search index did not include explicit waqf-domain entries or Arabic query expansion for the short token `وقف`. The existing `الأوقاف` string was not sufficient for reliable substring matching after normalization.

### Files

```text
lib/presentation/screens/public/search/web_search_screen.dart
lib/presentation/screens/public/search/mobile_search_screen.dart
```

### Resolution

- Added `مستكشف الوقف` as a governed indexed public result.
- Added waqf-related keywords to the index.
- Added Arabic normalization for diacritics/tatweel/hamza forms.
- Added query expansion for `وقف`, `اوقاف`, and `الاوقاف`.

### Verification pending

Local browser UAT is required because Flutter SDK is unavailable in this execution environment.

---

## Error 2 — WebAppBar RenderFlex overflow under constrained viewport

### Symptom

The evidence showed DevTools console errors similar to:

```text
Another exception was thrown: A RenderFlex overflowed ... pixels on the right.
```

The overflow was associated with `WebAppBar` under constrained browser widths.

### Cause

The previous responsive threshold still allowed full navigation or fixed action rows to render in widths too small for the Arabic labels, logo, and action controls. Browser DevTools docking exposed the constraint sharply.

### File

```text
lib/presentation/widgets/web/web_app_bar.dart
```

### Resolution

- Increased compact-navigation threshold.
- Constrained logo width.
- Introduced a scale-down action strip.
- Used fixed 44px action controls.
- Added `FittedBox(scaleDown)` for both full navigation and action strip branches.

### Verification pending

Retest with Chrome DevTools docked right and normal viewport.

## Boundaries

```text
no SQL executed
no DDL/DML
no public base table mutation
no service_role
no waqf_assets mutation
no production approval
android runtime UAT remains deferred
```
