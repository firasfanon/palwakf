# UAT Checklist — Platform 12 Home Search + Sections Source Consolidation

## Flutter checks

```powershell
flutter analyze
flutter test
flutter run -d chrome
```

## Search route checks

| Route | Expected result |
| --- | --- |
| `/home/search?q=مسجد` | Result card for المساجد appears |
| `/home/search?q=الخدمات` | Services-related result appears |
| `/home/search?q=الأخبار` | News-related result appears |
| `/home/search?q=إعلان` | Announcements-related result appears |
| `/home/search` | Search page opens without crash |

## Responsive checks

| Viewport | Expected result |
| --- | --- |
| Normal desktop | No app bar overflow |
| Chrome DevTools docked | No repeated `RenderFlex overflowed` from `WebAppBar` |
| Width below 900px | Results and sidebar stack vertically |

## Homepage sections checks

| Check | Expected result |
| --- | --- |
| Homepage loads | Sections read through compatibility surface |
| Duplicate legacy/canonical keys | Render once per canonical section key |
| Footer | No duplicate footer render |
| Semantic families | Await UX/content decision before deletion |

## SQL boundary

No SQL should be executed for this UAT unless separately authorized.
