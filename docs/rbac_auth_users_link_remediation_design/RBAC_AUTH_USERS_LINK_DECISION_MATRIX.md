
# RBAC Auth Users Link Remediation Decision Matrix

## Required Evidence

Before choosing a path, run the read-only diagnostics in:

```text
sql_diagnostics/rbac_auth_users_link_remediation_design/
```

## Decision Rules

### Path A — Physical FK

Choose only if:

```text
platform_access_admin_rows > 0
orphans_by_id = 0
id_type = uuid
auth_users_table_visible = true
```

Recommended FK pattern:

```text
ALTER TABLE platform_access.admin_users
ADD CONSTRAINT ... FOREIGN KEY (id) REFERENCES auth.users(id) NOT VALID;
VALIDATE CONSTRAINT ...;
```

This must be executed only in a separate authorized apply batch.

### Path B — Logical Contract

Choose if:

```text
orphans_by_id > 0
or historical admin rows must remain
or direct FK may break legacy flows
```

Contract:

```text
auth.uid() resolves to platform_access.admin_users.id when present
otherwise access denied
```

### Path C — Compatibility View

Choose if:

```text
core.admin_users and public.admin_users remain active dependencies
```

View contract:

```text
platform_access.v_admin_identity_authority_v1
```

### Path D — Bridge Table

Choose if:

```text
platform_access.admin_users.id cannot safely equal auth.users.id
```

Bridge table concept:

```text
platform_access.admin_user_auth_links(admin_user_id, auth_user_id)
```

## Recommended Default

Given current evidence:

```text
RBAC_PLATFORM_ACCESS_STRUCTURAL_AUTHORITY_ACCEPTED_AUTH_USERS_PHYSICAL_FK_ABSENT
```

Default next step should be:

```text
Run orphan/data consistency diagnostics before any DDL.
```

Do not add FK blindly.
