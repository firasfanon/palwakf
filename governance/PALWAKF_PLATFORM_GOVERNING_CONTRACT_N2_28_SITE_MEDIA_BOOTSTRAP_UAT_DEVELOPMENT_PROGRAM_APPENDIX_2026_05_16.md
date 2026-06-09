# PalWakf Governing Contract Appendix — N2.28

## Subject
Site Content + Media Center Bootstrap SQL UAT Intake + Migration Wave 1 Dependency Matrix + Development Program Reset.

## Evidence intake
The N2.28 evidence confirms:

- `site_content` schema exists after draft bootstrap application.
- `media_center` schema exists after draft bootstrap application.
- `site_content` planning/shadow registry exists.
- `media_center` planning/shadow registry exists.
- Services mapping evidence remains unresolved for some service catalog tables.
- `platform.schema_inventory_decisions` exists, but the Wave 4 draft failed because the script assumed a `schema_name` column that is not present in the actual table contract.
- No `waqf`, `waqf_assets`, or `awqaf_system` mutation was performed.

## Corrected governing rule
The database ownership effort must stop being handled as isolated patching. It is now a formal development program:

1. Census first.
2. Ownership decision second.
3. Dependency/RLS/RPC/Flutter usage matrix third.
4. Compatibility wrapper fourth.
5. Shadow schema/bootstrap fifth.
6. Read-only UAT sixth.
7. Controlled migration only after explicit approval.
8. Public compatibility contracts must be preserved.
9. Existing view column order and data types must not be changed by `CREATE OR REPLACE VIEW`.
10. Governance-table shape must be introspected before insert/update scripts are written.

## Public Schema Rule
`public` is not a permanent operational owner. It is allowed for:

- public views,
- RPC wrappers,
- compatibility contracts,
- transitional tables only when explicitly documented.

## Domain ownership direction

| Domain | Target owner |
|---|---|
| Site/public page management | `site_content` |
| Media center | `media_center` |
| Services center | `platform_services`, with `facilities_module` review for service points/providers/types |
| Organizational units | `core` |
| Dynamic systems | `platform` |
| Waqf assets | `waqf` / `waqf_assets` contracts |
| GIS/location geometry | `gis`, subject to public.locations audit |

## Production gate
Production remains blocked until at least:

- schema inventory contract is stabilized,
- public org-unit cache dependency is retired after Flutter check,
- site/media migration Wave 1 dependency matrix is closed,
- services mapping owner is decided,
- locations ownership is resolved,
- analyzer/browser/role UAT passes after any source migration.
