# Governance Update — N2.29

## Database Ownership Gate

Any domain migration wave must include:

- classification matrix,
- dependency matrix,
- RLS matrix,
- RPC compatibility matrix,
- Flutter usage matrix,
- UAT evidence,
- rollback plan.

## Public Schema Rule

`public` must be reduced toward views/RPC wrappers and compatibility only. Operational tables currently in `public` are transitional until moved by approved domain migration waves.
