# Governing Contract Appendix — N2.32

N2.32 establishes the following rule for database-domain migration batches:

1. If a SQL UAT script produces multiple result sets, it must not be used as the sole execution gate unless all result sets are captured.
2. For Supabase SQL Editor compatibility, execution-gate UAT scripts should prefer a single final result table.
3. Sovereign-boundary evidence is necessary but not sufficient for quarantine or migration execution.
4. Cache quarantine requires dependency evidence across views, materialized views, functions/RPCs, foreign keys, policies, triggers, and public compatibility wrappers.
5. No cache candidate may be renamed, dropped, moved, or archived until its strict gate is explicitly passed.
6. `public.org_units` must remain a compatibility view backed by `core.org_units`, not cache tables.
7. `waqf_assets`, schema `waqf`, and internal `awqaf_system` remain out of scope.
