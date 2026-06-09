# PALWAKF Platform Comprehensive Guide — Service Center Closure Update

Date: 2026-05-31

## Service Center final scoped runtime closure

Service Center is closed within scoped runtime UAT. The owner schema remains `platform_services`; Flutter runtime is through public RPC wrappers only.

Accepted runtime surfaces:

- public.rpc_services_forms_public_v1
- public.rpc_services_submit_request_v1
- public.rpc_services_track_request_public_v1
- public.rpc_services_admin_request_queue_v1
- public.rpc_services_admin_transition_request_v1

Final state:

```text
staging-stable /
service-center-scoped-runtime-closure-complete /
service-center-runtime-source-certified-for-forms-admin-queue-submit-track-transition /
service-center-public-submit-route-accepted /
service-center-same-tracking-number-trace-accepted /
service-center-admin-transition-evidence-accepted /
analyzer-post-hotfix-clean /
chrome-startup-passed /
production-candidate-not-platform-production-approved /
no-sql-production-change /
no-direct-flutter-platform-services-writes /
no-service-role /
no-waqf-awqaf-system-gis-mutation
```

## Production note

This closure is a production candidate for Service Center only. It is not a platform-wide production approval.

## Boundaries

No SQL production, no DDL/DML/GRANT/DROP, no direct Flutter writes to `platform_services`, no `service_role`, no deletion/archive, and no mutation to `waqf`, `waqf_assets`, `awqaf_system`, or GIS schemas.


---

## 2026-06-03 — Platform Access Gateway UAT Retest RPC400 Closure

Latest evidence accepted: Platform Access Gateway `/admin/dashboard` renders for tested superuser/viewer/employee actors after disabling the failing user-scope assignments list RPC path. Network evidence shows `user_scope_assignments?select...` returning `200`, with no visible `rpc_user_scope_assignments_list_v1` `400` in the submitted retest. The unified `/forbidden` route renders a safe Arabic denied page for `admin_access_denied` without protected payload/token exposure.

Production remains not approved; this closes only the tested platform-access RPC400 retest branch.
