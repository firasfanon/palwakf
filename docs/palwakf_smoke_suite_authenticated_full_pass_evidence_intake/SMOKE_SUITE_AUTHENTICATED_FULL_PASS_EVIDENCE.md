
# PalWakf Smoke Suite Authenticated Full Pass Evidence

## Command

```powershell
dart run tools/smoke/palwakf_smoke_suite.dart
```

## Evidence

```text
Running build hooks...
PASS SMK-05 — Media Center public news compat view — HTTP 200
PASS SMK-06 — Media Center public announcements compat view — HTTP 200
PASS SMK-07 — Media Center public activities compat view — HTTP 200
PASS SMK-08 — Technical Services dashboard RPC — HTTP 200

PalWakf smoke summary: passed=4 skipped=0 failed=0
```

## Interpretation

The protected Technical Services dashboard RPC was successfully verified using an authenticated admin user access token.

This confirms:

- public Media Center compatibility views are reachable with HTTP 200
- protected Technical Services RPC is reachable with authenticated admin context
- smoke suite completed without failures
- no service-role key is required or accepted as the runtime method
