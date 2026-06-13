# Decision Record

```json
{
  "batch": "MEDIA_CENTER_OFFICIAL_FIRST_MOBILE_PUBLISHING_APP_BREAKING_NEWS_NULLSAFE_RUNTIME_HOTFIX",
  "date": "2026_06_13",
  "base": "media_center_official_first_mobile_publishing_app_analyzer_cleanup_hotfix_2026_06_13.zip",
  "runtime_error": {
    "widget": "BreakingNewsSlider",
    "file": "lib/presentation/widgets/home/breaking_news_slider.dart",
    "line_from_user_log": "89:48",
    "error": "Unexpected null value",
    "root_cause": "settingsState.settings forced with null-check before provider state is loaded"
  },
  "fix": {
    "changed_file": "lib/presentation/widgets/home/breaking_news_slider.dart",
    "strategy": "fallback to const BreakingNewsSectionSettings when settingsState.settings is null",
    "sql_changes": false
  },
  "accepted_prior_evidence": {
    "flutter_analyze": "No issues found before runtime crash evidence",
    "cms_payload_contract_tests": "All tests passed",
    "chrome_runtime": "launched",
    "runtime_exception": "BreakingNewsSlider null-check",
    "sql_workflow_applied": true,
    "public_api_edge_counts": {
      "news": 93,
      "announcements": 90,
      "activities": 93
    }
  },
  "boundaries": [
    "no SQL changes",
    "no public base tables",
    "no service_role",
    "no RLS mutation",
    "no storage mutation",
    "no production approval"
  ],
  "status": "breaking-news-slider-nullsafe-runtime-hotfix-prepared / settings-null-check-removed / default-breaking-news-settings-fallback-added / sql-workflow-prior-evidence-accepted / analyzer-prior-clean / cms-tests-prior-passed / chrome-runtime-retest-pending / no-sql-change / no-public-base-tables / no-service-role / production-not-approved"
}
```
