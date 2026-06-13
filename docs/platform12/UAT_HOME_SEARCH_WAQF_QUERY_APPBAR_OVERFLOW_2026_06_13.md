# UAT — Home Search Waqf Query + WebAppBar Overflow Closure

## Commands

```powershell
flutter analyze
flutter test
flutter run -d chrome
```

## Browser checks

| ID | Route / Action | Expected result |
|---|---|---|
| UAT-01 | `/home/search?q=مسجد` with `الكل` | Shows `المساجد` result |
| UAT-02 | `/home/search?q=مسجد` with `المساجد` | Shows `المساجد` result |
| UAT-03 | `/home/search?q=وقف` with `الكل` | Shows waqf-related results, including `مستكشف الوقف` |
| UAT-04 | `/home/search?q=وقف` with `الوثائق` | Does not show empty state; shows `مستكشف الوقف` and/or other waqf-document results |
| UAT-05 | `/home/search?q=الخدمات` with `الخدمات` | Shows service-related result |
| UAT-06 | `/home/search?q=الأخبار` with `الأخبار` | Shows news/media-related result |
| UAT-07 | DevTools docked right, constrained width | No `RenderFlex overflowed` from `WebAppBar` |
| UAT-08 | Normal full browser width | AppBar remains readable; compact menu may appear below conservative threshold |
| UAT-09 | Click compact menu | Menu opens and navigates correctly |
| UAT-10 | Click search result `مستكشف الوقف` | Navigates to `/mustakshif` |

## SQL

No SQL is part of this UAT.
