# PALWAKF_PLATFORM_COMPREHENSIVE_GUIDE — N2.32 Update

## Database Domain Migration Program — Wave B

N2.32 confirms that Wave B cache quarantine cannot proceed from a sovereignty-only SQL result. Evidence collection and execution are split.

### Current cache candidates

- `public.org_units_cache`
- `public.pwf_org_units_cache`

### Active rule

Run `sql_sandbox/n2_32/46_wave_b_cache_candidates_single_result_READ_ONLY_N2_32.sql` and review all rows before any execution batch.

### Production status

Production remains not approved. Database ownership cleanup is still active.
