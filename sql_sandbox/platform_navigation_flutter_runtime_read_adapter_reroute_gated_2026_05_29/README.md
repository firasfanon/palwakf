# Platform Navigation Flutter Runtime Read-Adapter Reroute — Gated

This folder contains read-only validation for the Flutter gated adapter.

## Runtime posture

- Default runtime remains unchanged.
- Owner-read adapter is compiled in but disabled unless explicitly enabled with:
  `--dart-define=PWF_ENABLE_PLATFORM_NAVIGATION_OWNER_READS=true`.
- No archive/delete.
- No mutation of `public.services` or `public.home_services`.
- No production approval.
- No mutation of `waqf`, `awqaf_system`, or GIS schemas.
