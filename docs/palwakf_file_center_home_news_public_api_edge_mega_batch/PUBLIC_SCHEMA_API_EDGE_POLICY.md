
# PUBLIC_SCHEMA_IS_COMPATIBILITY_AND_API_EDGE_ONLY_NOT_SYSTEM_SOURCE_OF_TRUTH

## Governing Decision

```text
PUBLIC_SCHEMA_IS_COMPATIBILITY_AND_API_EDGE_ONLY_NOT_SYSTEM_SOURCE_OF_TRUTH
```

## Meaning

`public` is not a sovereign owner schema and must not become the source of truth for PalWakf systems.

## Allowed in public

```text
views
RPC facades
compatibility wrappers
API edge functions
temporary read surfaces
```

## Not allowed in public

```text
new public base tables
business source-of-truth tables
owner data migration into public
direct Flutter dependency on public base tables as default runtime source
service_role usage
```

## Runtime Pattern

```text
Flutter -> public API edge view/RPC -> owner schema
```

Not:

```text
Flutter -> public base table
```
