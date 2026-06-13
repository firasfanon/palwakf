
# PALWAKF_FILE_CENTER_HOME_NEWS_PUBLIC_API_EDGE_MEGA_BATCH — Evidence Closure

## Accepted SQL Evidence

### Public base table inventory warning

The diagnostics returned the following legacy public base tables:

```text
assistant_conversations
assistant_messages
chatbot_conversations
chatbot_intents
chatbot_messages
chatbot_retention_policies
org_units_cache
pwf_org_units_cache
```

Each row preserved:

```text
create_public_base_table_authorized = false
production_approved = false
```

Interpretation:

```text
This batch did not create public base tables.
The listed tables remain legacy inventory warnings requiring separate remediation/governance.
```

### File Center explicit assignment workflow apply result

```text
mapping_events_table_present = true
assign_unit_rpc_present = true
mark_owner_mapping_rpc_present = true
public_base_table_created = false
production_approved = false
```

Accepted objects:

```text
platform_documents.file_object_mapping_events
public.rpc_file_object_assign_unit_scope_v1
public.rpc_file_object_mark_owner_mapping_v1
```

### Home/news API-edge facade verification

```text
news_facade_present = true
announcements_facade_present = true
activities_facade_present = true
storage_objects_facade_present = true
```

Accepted API-edge surfaces:

```text
public.v_media_news_compat_v1
public.v_media_announcements_compat_v1
public.v_media_activities_compat_v1
public.v_document_center_storage_objects_v1
```

## Accepted Flutter Evidence

```text
flutter analyze = No issues found
flutter test test/core/contracts/cms_payload_contracts_test.dart = All tests passed
dart run tools/smoke/palwakf_smoke_suite.dart = passed=3 skipped=1 failed=0
flutter run -d chrome = launched
Supabase initialized successfully
media rows:
  announcements = 4
  news = 5
  activities = 4
```

`SMK-08` remains skipped because it requires an authenticated admin token. This is acceptable for unauthenticated smoke evidence and does not represent a failure.

## Accepted Decision

```text
PALWAKF_FILE_CENTER_HOME_NEWS_PUBLIC_API_EDGE_SQL_FLUTTER_EVIDENCE_PASSED
```

## Status

```text
file-center-explicit-unit-assignment-workflow-applied
mapping-events-table-present
assign-unit-rpc-present
mark-owner-mapping-rpc-present
home-news-api-edge-facades-present
storage-objects-api-edge-present
flutter-analyze-clean
cms-contract-tests-passed
smoke-passed-3-skipped-1-failed-0
chrome-runtime-launched
public-base-table-inventory-warning-preserved
no-public-base-table-created
public-schema-api-edge-only-not-source-of-truth
no-service-role
production-not-approved
```

## Not Claimed

The following are not claimed:

```text
legacy public base tables remediated
SMK-08 authenticated technical services RPC passed
production approval
visual browser route screenshots for all paths
public media auto-publication
```
