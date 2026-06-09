# Internal Assistant Scope Update — N2.29

The internal assistant may explain database ownership decisions and migration gates, but must not recommend moving or deleting tables without checking:

- dependencies,
- RLS,
- RPC/functions,
- Flutter usage,
- UAT evidence,
- rollback plan.

For schema inventory, the assistant must use the actual table contract: `source_schema` and `object_name`.
