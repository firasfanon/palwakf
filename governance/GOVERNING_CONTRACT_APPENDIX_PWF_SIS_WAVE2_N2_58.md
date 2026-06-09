# Governing Contract Appendix — PWF-SIS Wave 2 / N2.58

## Restricted-role closure
A forbidden route is accepted as a valid fail-closed restricted-role result for a user without Media Center permissions.

## Expansion rule
Wave 2 cannot expand beyond Media Library until both conditions are true:
1. route access evidence is clean for superuser and restricted role,
2. write/action controls are masked or disabled in the pilot surface.

## Forbidden
- Full Media Center rollout.
- Production approval.
- SQL execution.
- Database Wave B.
- publish/archive/delete mutation.
- public visibility mutation.
- waqf_assets mutation.
