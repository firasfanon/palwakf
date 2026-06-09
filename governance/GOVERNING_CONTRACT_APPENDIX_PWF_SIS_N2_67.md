# Governing Contract Appendix — PWF-SIS N2.67

## High-risk readiness-only rule
High-risk systems are not migrated by PWF-SIS automatically. They require system-specific adoption contracts.

## Systems covered
- awqaf_system
- waqf_assets
- cases
- billing_system
- mustakshif/GIS
- nusuk/manasikuna
- tasks
- assistant

## Required before any future migration
1. system contract,
2. route/RBAC evidence,
3. role-based browser UAT,
4. workflow contract,
5. rollback path,
6. no direct sovereign mutation,
7. analyzer clean,
8. browser console clean.

## Forbidden in N2.67
- UI migration,
- workflow mutation,
- SQL execution,
- Database Wave B,
- production approval,
- `waqf_assets` mutation.
