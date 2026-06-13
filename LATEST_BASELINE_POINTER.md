# Latest Baseline Pointer

Current updated baseline:

```text
platform12_home_search_waqf_query_appbar_overflow_closure_mega_batch_2026_06_13.zip
```

Based on:

```text
platform12_home_search_sections_source_consolidation_mega_batch_2026_06_13.zip
```

Session:

```text
تطوير المنصة 12
```

Status:

```text
platform12-home-search-waqf-query-appbar-overflow-closure-mega-batch-prepared / search-masjid-normal-width-confirmed-by-user-evidence / search-waqf-documents-gap-accepted-and-index-expanded / web-appbar-constrained-width-overflow-hardened / homepage-sections-source-decision-preserved / semantic-family-policy-decision-required / android-runtime-uat-deferred / no-sql-executed / no-service-role / production-not-approved
```

Primary Mega Batch record:

```text
docs/platform12/PLATFORM12_HOME_SEARCH_WAQF_QUERY_APPBAR_OVERFLOW_CLOSURE_MEGA_BATCH_2026_06_13.md
```

Error record:

```text
docs/platform12/ERROR_RECORD_HOME_SEARCH_WAQF_QUERY_APPBAR_OVERFLOW_2026_06_13.md
```

UAT checklist:

```text
docs/platform12/UAT_HOME_SEARCH_WAQF_QUERY_APPBAR_OVERFLOW_2026_06_13.md
```

Evidence:

```text
docs/platform12/evidence/search_waqf_no_results_narrow_devtools_2026_06_13.png
docs/platform12/evidence/search_masjid_result_normal_width_2026_06_13.png
```

Next gates:

```text
1. Local flutter analyze.
2. Local flutter test.
3. Browser UAT for /home/search?q=وقف with category=الوثائق.
4. Browser UAT for /home/search?q=مسجد with category=المساجد.
5. Browser constrained-width UAT with DevTools docked right; confirm no WebAppBar RenderFlex overflow.
6. Decide semantic homepage section family policy.
7. Resume Android runtime device/emulator UAT when desired.
```
