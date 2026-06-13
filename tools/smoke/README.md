
# PalWakf Smoke Suite

## Run

```bash
dart run tools/smoke/palwakf_smoke_suite.dart
```

## Required environment

The script reads `.env` or process environment.

Accepted variable names:

```text
SUPABASE_URL
VITE_SUPABASE_URL
SUPABASE_ANON_KEY
VITE_SUPABASE_ANON_KEY
SUPABASE_PUBLIC_ANON_KEY
```

## Optional authenticated token for protected RPCs

Technical Services RPC is protected and may return:

```text
PLATFORM_TECHNICAL_AUTH_REQUIRED
```

when called with anon key only.

To validate protected RPCs as HTTP 200, provide a normal authenticated admin/super-admin user access token:

```text
SUPABASE_ACCESS_TOKEN
PALWAKF_SMOKE_ACCESS_TOKEN
PALWAKF_ADMIN_ACCESS_TOKEN
```

Do **not** use `service_role` in Flutter or in this smoke suite.

## Current checks

- `SMK-05` public news compatibility view
- `SMK-06` public announcements compatibility view
- `SMK-07` public activities compatibility view
- `SMK-08` protected Technical Services dashboard RPC

## Expected behavior

Without admin access token:

```text
passed=3 skipped=1 failed=0
```

With valid admin access token:

```text
passed=4 skipped=0 failed=0
```
