# Decision Record

```json
{
  "batch": "PALWAKF_FILE_CENTER_HOME_NEWS_PUBLIC_API_EDGE_EVIDENCE_CLOSURE",
  "date": "2026_06_13",
  "base": "palwakf_file_center_home_news_public_api_edge_mega_batch_2026_06_13.zip",
  "accepted_sql": {
    "public_base_table_inventory_warning": [
      "assistant_conversations",
      "assistant_messages",
      "chatbot_conversations",
      "chatbot_intents",
      "chatbot_messages",
      "chatbot_retention_policies",
      "org_units_cache",
      "pwf_org_units_cache"
    ],
    "public_base_table_created": false,
    "mapping_events_table_present": true,
    "assign_unit_rpc_present": true,
    "mark_owner_mapping_rpc_present": true,
    "news_facade_present": true,
    "announcements_facade_present": true,
    "activities_facade_present": true,
    "storage_objects_facade_present": true,
    "production_approved": false
  },
  "accepted_flutter": {
    "flutter_analyze": "No issues found",
    "cms_payload_contract_tests": "All tests passed",
    "smoke": "passed=3 skipped=1 failed=0",
    "flutter_run_chrome": "launched",
    "media_rows": {
      "announcements": 4,
      "news": 5,
      "activities": 4
    }
  },
  "accepted_decision": "PALWAKF_FILE_CENTER_HOME_NEWS_PUBLIC_API_EDGE_SQL_FLUTTER_EVIDENCE_PASSED",
  "not_claimed": [
    "legacy public base tables remediated",
    "SMK-08 authenticated technical services RPC passed",
    "production approval",
    "visual browser route screenshots for all paths",
    "public media auto-publication"
  ],
  "status": "file-center-explicit-unit-assignment-workflow-applied / mapping-events-table-present / assign-unit-rpc-present / mark-owner-mapping-rpc-present / home-news-api-edge-facades-present / storage-objects-api-edge-present / flutter-analyze-clean / cms-contract-tests-passed / smoke-passed-3-skipped-1-failed-0 / chrome-runtime-launched / public-base-table-inventory-warning-preserved / no-public-base-table-created / public-schema-api-edge-only-not-source-of-truth / no-service-role / production-not-approved"
}
```
