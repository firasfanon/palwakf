# PalWakf Instructions Update — N2.23

- Do not use public cache tables as source-of-truth.
- Do not change existing public view column types through `CREATE OR REPLACE VIEW`.
- Prefer versioned views/RPCs when a typed contract is needed.
- Apply source patches before analyzer/UAT.
- Record table ownership decisions in `platform.schema_inventory_decisions` before moving/deleting tables.
