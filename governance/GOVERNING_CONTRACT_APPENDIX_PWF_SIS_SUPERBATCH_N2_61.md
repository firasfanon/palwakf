# Governing Contract Appendix — PWF-SIS SuperBatch / N2.61

## Runtime/Pilot separation
Design-system pilots must not replace operational runtime pages.

## Rule
- Runtime pages keep their domain behavior and RBAC.
- Pilot pages are separate, read-only, and non-mutating.
- Wave expansion requires local browser evidence.

## Forbidden
- converting runtime to read-only for visual testing,
- SQL mutation,
- Database Wave B,
- publish/archive/delete workflow mutation,
- public visibility mutation,
- waqf_assets mutation,
- production approval without formal gates.
