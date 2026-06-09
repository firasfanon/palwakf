# Governing Contract Appendix — PWF-SIS Wave 2 / N2.57

## Restricted-role decision rule
Wave 2 cannot expand unless restricted-role evidence confirms that a non-authorized user:
1. cannot see write controls,
2. cannot trigger workflow mutations,
3. cannot access unauthorized routes,
4. gets a safe fail-closed/forbidden state,
5. sees no data mutation affordances.

## Media Library rule
The Media Library pilot remains read-only until explicit evidence approves otherwise.

## Forbidden during N2.57
- publish,
- archive,
- delete,
- create,
- edit,
- SQL mutation,
- Database Wave B,
- public visibility changes,
- `waqf_assets` mutation.
