# Decision Record

```json
{
  "batch": "CMS Media Center ListTile Material Runtime Hotfix",
  "date": "2026_06_11",
  "base": "cms_shared_content_save_helper_removedlist_analyzer_clean_hotfix_2026_06_11.zip",
  "runtime_evidence": {
    "flutter_run": "application launched on Chrome",
    "remaining_runtime_exception": "ListTile background color or ink splashes may be invisible",
    "cause": "ListTile was inside SharedAdminSurfaceCard rendered as Container/DecoratedBox with background color",
    "media_center_read_markers": [
      "PWF_MEDIA_CENTER_ROOT_CUTOVER family=announcements owner_read=true",
      "PWF_MEDIA_CENTER_ROOT_CUTOVER family=news owner_read=true",
      "PWF_MEDIA_CENTER_ROOT_CUTOVER family=activities owner_read=true"
    ]
  },
  "fix": [
    "Replace SharedAdminSurfaceCard Container/BoxDecoration with Material using RoundedRectangleBorder",
    "Keep white card surface, border, rounded corners, elevation/shadow",
    "Make ListTile/SwitchListTile ink/background paint on a proper Material ancestor"
  ],
  "changed_files": [
    "lib/presentation/screens/admin/main/management/home_management/widgets/shared/shared_content_admin_ui.dart"
  ],
  "sql_changed": false,
  "rls_changed": false,
  "cms_access_type": "direct_table_access_preserved",
  "service_role_used": false,
  "production_approved": false,
  "status": "staging-code-ready / media-center-listtile-material-runtime-hotfix-prepared / shared-admin-surface-materialized / cms-direct-table-access-preserved / no-sql / no-rls-change / production-not-approved"
}
```
