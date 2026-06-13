# Decision Record

```json
{
  "batch": "PALWAKF_DOCUMENT_CENTER_SQL_SCHEMA_SAFE_AND_NEWS_HERO_RUNTIME_HOTFIX",
  "date": "2026_06_12",
  "base": "palwakf_document_center_unification_and_lifecycle_governance_mega_batch_2026_06_11.zip",
  "evidence": {
    "sql_error": "column ca.status does not exist",
    "storage_counts": {
      "document-intelligence": 5,
      "media-gallery": 6
    },
    "flutter_analyze": "No issues found",
    "cms_contract_tests": "All tests passed",
    "smoke": "passed=3 skipped=1 failed=0; SMK-08 protected RPC skipped without admin token",
    "runtime_error": "RenderFlex children have non-zero flex but incoming height constraints are unbounded at pwf_news_pages.dart:540"
  },
  "fixes": [
    "Schema-safe unified document center view draft: no ca.status reference",
    "NewsHeroCard responsive layout: no Expanded in vertical/unbounded constraints"
  ],
  "not_performed": [
    "no SQL apply",
    "no RLS apply",
    "no production approval",
    "no service_role"
  ],
  "status": "document-center-sql-draft-schema-safe / news-hero-runtime-flex-hotfixed / analyzer-evidence-accepted / cms-contract-tests-accepted / smoke-public-media-pass-protected-rpc-skip-accepted / no-sql-apply / no-rls-apply / no-service-role / production-not-approved"
}
```
