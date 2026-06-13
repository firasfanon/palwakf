
# إغلاق أدلة PALWAKF_FILE_CENTER_HOME_NEWS_PUBLIC_API_EDGE_MEGA_BATCH

## القرار

```text
PALWAKF_FILE_CENTER_HOME_NEWS_PUBLIC_API_EDGE_SQL_FLUTTER_EVIDENCE_PASSED
```

## SQL

```text
mapping_events_table_present = true
assign_unit_rpc_present = true
mark_owner_mapping_rpc_present = true
public_base_table_created = false
production_approved = false
```

## API edge

```text
news_facade_present = true
announcements_facade_present = true
activities_facade_present = true
storage_objects_facade_present = true
```

## Flutter

```text
flutter analyze = No issues found
cms contract tests = All tests passed
smoke = passed=3 skipped=1 failed=0
flutter run -d chrome = launched
```

## public schema

جداول public الظاهرة هي legacy inventory warning، وليست جداول أنشأها هذا الباتش.

```text
public = API edge فقط
owner schemas = source of truth
```

## غير معتمد بعد

```text
production approval
SMK-08 authenticated pass
legacy public base table remediation
visual screenshot closure لكل المسارات
```
