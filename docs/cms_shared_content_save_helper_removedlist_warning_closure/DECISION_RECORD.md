# Decision Record

```json
{
  "batch": "CMS SharedContentSaveHelper removedList Warning Closure",
  "date": "2026_06_11",
  "base": "cms_media_center_listtile_material_runtime_hotfix_2026_06_11.zip",
  "warning": "unused_local_variable removedList",
  "root_cause": "The previous StateError message did not reference removedList as a real Dart variable after escaping/interpolation mismatch.",
  "fix": [
    "Replace removedList with removedColumnsText",
    "Use normal Dart interpolation: $table, $removedColumnsText, $message",
    "Preserve news_articles.author fallback",
    "Preserve optional-column stripping and retry behavior"
  ],
  "sql_changed": false,
  "rls_changed": false,
  "cms_access_type": "direct_table_access_preserved",
  "service_role_used": false,
  "production_approved": false,
  "status": "staging-code-ready / removedlist-unused-warning-closed / cms-author-fallback-preserved / cms-direct-table-access-preserved / no-sql / no-rls-change / production-not-approved"
}
```
