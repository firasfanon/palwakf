# Technical Services Final Closure — Test Cases Table

| Test ID | Scenario | Preconditions | Steps | Expected Result | Actual Result | Status | Evidence |
|---|---|---|---|---|---|---|---|
| TC-TS-01 | Open Technical Services dashboard | Admin user logged in | Navigate to `/admin/platform/technical-services` | Dashboard opens | Backend strip and metrics render | Passed / evidence supplied earlier | Browser screenshot |
| TC-TS-02 | Dashboard RPC | DevTools Network open | Refresh dashboard | `rpc_platform_technical_services_dashboard_v1` returns 200 | Pending final Network screenshot | Pending | Network screenshot required |
| TC-TS-03 | Backup page route | Admin user logged in | Navigate to `/admin/platform/technical-services/backup` | Backup page opens | Route available | Passed / evidence supplied earlier | Browser screenshot |
| TC-TS-04 | Maintenance page route | Admin user logged in | Navigate to `/admin/platform/technical-services/maintenance` | Maintenance page opens | Route available | Passed / evidence supplied earlier | Browser screenshot |
| TC-TS-05 | Health page route | Admin user logged in | Navigate to `/admin/platform/technical-services/health` | Health page opens and checks render | Health checks were visible earlier | Passed / evidence supplied earlier | Browser screenshot |
| TC-TS-06 | Deployment page route | Admin user logged in | Navigate to `/admin/platform/technical-services/deployment` | Deployment page opens | Route available | Passed / evidence supplied earlier | Browser screenshot |
| TC-TS-07 | Audit page route | Admin user logged in | Navigate to `/admin/platform/technical-services/audit` | Audit page opens | Route available | Passed / evidence supplied earlier | Browser screenshot |
| TC-TS-08 | Create governed backup request | Backend SQL applied | Click safe action in Backup | Request recorded by RPC | Pending live run | Pending | Network/Response |
| TC-TS-09 | Schedule maintenance window | Backend SQL applied | Submit maintenance dialog | Window recorded as planned | Pending live run | Pending | Network/Response |
| TC-TS-10 | Refresh health snapshot | Backend SQL applied | Click Health refresh | Health RPC runs and dashboard refreshes | Pending live run | Pending | Network/Response |
| TC-TS-11 | Register release record | Backend SQL applied | Submit release dialog | Release record saved | Pending live run | Pending | Network/Response |
| TC-TS-12 | Operations Center render | Backend enriched RPC applied | Open overview/audit page | Evidence/notifications/decisions counts render | Added in this batch | Pending retest | Browser screenshot |
| TC-TS-13 | No service_role exposure | Source inspection | Inspect Flutter code/env | No service_role key in Flutter | Preserved by design | Passed by design | Code review |
| TC-TS-14 | Flutter static analysis | Latest hotfix applied | Run `flutter analyze` | No issues found | Pending final rerun after latest packages | Pending | Analyzer output |
| TC-TS-15 | Chrome runtime startup | Flutter environment ready | Run `flutter run -d chrome` | App opens and Supabase initializes | Passed earlier; retest after this batch required | Pending final retest | Console output |
