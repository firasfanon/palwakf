# PalWakf Governance Update — N2.28

## Governance table contract failure
The error `column "schema_name" of relation "schema_inventory_decisions" does not exist` is a contract drift in the governance inventory table.

## Governance decision
No future inventory-decision DML may be written before running shape discovery:

```sql
select column_name, data_type, ordinal_position
from information_schema.columns
where table_schema='platform'
  and table_name='schema_inventory_decisions'
order by ordinal_position;
```

## Migration governance
Each domain migration wave must include:

- source table,
- target owner schema,
- compatibility view/RPC,
- RLS policy migration,
- RPC migration,
- Flutter repository migration,
- rollback path,
- UAT evidence,
- production gate decision.
