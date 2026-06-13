# Decision Record

```json
{
  "batch": "PALWAKF_DOCUMENT_CENTER_PUBLIC_WRAPPERS_RUNTIME_CLOSURE_HOTFIX",
  "date": "2026_06_12",
  "base": "palwakf_document_center_sql_schema_safe_and_news_hero_runtime_hotfix_2026_06_12.zip",
  "evidence": {
    "admin_documents": "PGRST106 from direct owner schema REST reads",
    "home_news": "RenderFlex/Row unbounded height runtime assertion",
    "analyzer": "No issues found",
    "cms_contract_tests": "All tests passed",
    "smoke": "passed=3 skipped=1 failed=0 with protected RPC skip"
  },
  "fixes": [
    "DocumentCenterRepository uses optional public wrappers only for services/media surfaces",
    "Owner-schema direct REST reads removed from Flutter",
    "Public wrapper SQL drafts prepared",
    "NewsHeroCard wide Row is constrained by finite height",
    "Author row avoids Flexible inside min Row"
  ],
  "not_performed": [
    "no SQL apply",
    "no RLS apply",
    "no service_role",
    "no production approval"
  ],
  "status": "document-center-runtime-owner-schema-direct-read-removed / public-wrapper-read-contract-prepared / admin-documents-pgrst106-degraded-gracefully / news-hero-finite-height-runtime-hotfix / no-sql-apply / no-rls-apply / no-service-role / production-not-approved"
}
```
