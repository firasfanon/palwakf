# Governing Contract Appendix — PWF-SIS Wave 2 / N2.59R

## Runtime vs Pilot Separation Rule
A production/operational page must not be converted to read-only merely to test a design-system pilot.

## Rule
- Operational route keeps its real behavior subject to RBAC.
- Pilot route is separate and read-only.
- Pilot route must not invoke write RPCs or workflow transitions.

## Forbidden
- disabling operational Media Center features for design testing,
- mutating publication workflow,
- SQL execution,
- Database Wave B,
- `waq_assets` mutation,
- production approval without full UAT.
