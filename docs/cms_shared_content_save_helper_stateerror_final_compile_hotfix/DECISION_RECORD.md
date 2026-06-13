# Decision Record

```json
{
  "batch": "CMS SharedContentSaveHelper StateError Final Compile Hotfix",
  "date": "2026_06_11",
  "base": "analyzer_cms_author_required_ui_runtime_hotfix_2026_06_11.zip",
  "error": "Too many positional arguments: 1 expected, but 2 found at StateError(...)",
  "root_cause": "Dart string interpolation/quoting around removedColumns.join(', ') made StateError parse more than one positional argument.",
  "fix": [
    "Introduced removedList variable before StateError",
    "Changed StateError message to one valid adjacent string expression",
    "Preserved author fallback for news_articles",
    "Preserved optional-column stripping and retry behavior"
  ],
  "sql_changed": false,
  "rls_changed": false,
  "cms_access_type": "direct_table_access_preserved",
  "service_role_used": false,
  "production_approved": false,
  "status": "staging-code-ready / final-stateerror-compile-hotfix-prepared / cms-author-fallback-preserved / cms-direct-table-access-preserved / no-sql / no-rls-change / production-not-approved"
}
```
