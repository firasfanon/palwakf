# PalWakf Governing Contract Appendix — N2.29

## Schema Inventory Contract Rule

`platform.schema_inventory_decisions` is governed by its discovered contract:

- `source_schema`
- `object_name`
- `object_type`
- `current_owner_system`
- `recommended_owner_system`
- `classification`
- `decision`
- `action_status`
- `risk_level`
- `dependency_status`
- `rls_status`
- `rpc_usage_status`
- `flutter_usage_status`
- `no_auto_drop`
- `notes_ar`

Scripts must not assume alias columns unless a compatibility view is explicitly created.

## Domain-owned schemas rule

The platform shall organize operational data by domain-owned schemas:

- `site_content` for website/page management.
- `media_center` for media center editorial/runtime data.
- `platform_services` for service center workflows.
- `core` for sovereign organizational units and master organizational data.
- `platform` for system registry, dynamic systems, and platform governance.
- `public` for views/RPC wrappers and compatibility surfaces only.

## Movement gate

No table may be moved, dropped, or repointed without:

1. dependency audit,
2. RLS review,
3. RPC/function usage review,
4. Flutter usage review,
5. browser UAT,
6. rollback plan.

## No auto-drop

Every inventory decision defaults to `no_auto_drop = true`.
