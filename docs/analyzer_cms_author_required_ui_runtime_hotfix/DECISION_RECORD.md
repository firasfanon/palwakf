# Decision Record

```json
{
  "batch": "Analyzer + CMS Author Required Hotfix",
  "date": "2026_06_11",
  "base": "cms_write_publish_direct_table_schema_cache_hotfix_2026_06_11.zip",
  "fixes": [
    "Fix malformed Dart model interpolation in pwf_technical_service_operations_models.dart",
    "Remove Riverpod protected state access from extension files",
    "Add news_articles.author fallback for CMS direct table writes",
    "Preserve direct table CMS write classification; no RPC conversion"
  ],
  "sql_changed": false,
  "rls_changed": false,
  "service_role_used": false,
  "production_approved": false,
  "status": "staging-code-ready / analyzer-model-syntax-fixed / riverpod-extension-state-warning-fixed / cms-news-author-not-null-fallback-added / cms-direct-table-access-preserved / no-sql / no-rls-change / production-not-approved"
}
```
