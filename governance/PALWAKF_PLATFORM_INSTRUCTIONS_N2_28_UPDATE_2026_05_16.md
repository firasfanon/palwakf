# PalWakf Platform Instructions Update — N2.28

- Any database ownership work must be implemented as a migration program, not ad hoc patches.
- Before writing to `platform.schema_inventory_decisions`, inspect the actual table columns.
- Do not assume column names such as `schema_name`; use the actual contract or create an explicit migration to add required columns.
- Do not move/delete operational tables without dependency/RLS/RPC/Flutter evidence.
- Do not alter existing public view column order or data types.
- Keep `public` as wrapper/compatibility layer wherever possible.
- Update the governing contract, instructions, governance, internal assistant scope, and public chat scope after every major decision.
