# Database Ownership Phase B — Media Center Controlled Ownership Closure

## Purpose
Close Media Center ownership before Service Center or remaining public-table work.
This pack is intentionally scoped to `media_center` and legacy public media surfaces.
It does not continue Database Ownership Wave A access-helper work.

## Run order
Run only the read-only evidence scripts first:

1. `01_phase_b_media_inventory_read_only.sql`
2. `02_phase_b_media_owner_contract_read_only.sql`
3. `03_phase_b_media_public_compat_surface_read_only.sql`
4. `04_phase_b_media_counts_visibility_read_only.sql`
5. `06_phase_b_media_browser_uat_matrix_read_only.sql`
6. `07_phase_b_media_next_gate_read_only.sql`

Do **not** run `05_phase_b_media_guarded_sync_candidate_DRAFT_NOT_RUN.sql` unless a later package explicitly approves it after inventory, backup, and browser evidence.

## Hard boundaries
- No SQL29.
- No SQL37/38/39/40.
- No SQL02/03/04.
- No Auth/RBAC rewrite.
- No DROP/DELETE/ARCHIVE/TRUNCATE.
- No exact public table replacement.
- No `auth.users` migration.
- No Flutter elevated secret.
- No `waqf`, `waqf_assets`, `awqaf_system`, or GIS mutation.

## Phase B principle
`media_center` is the owner schema. `public` remains a compatibility/API surface until dependency-zero and browser UAT are proven. Legacy public media tables are preserved.
