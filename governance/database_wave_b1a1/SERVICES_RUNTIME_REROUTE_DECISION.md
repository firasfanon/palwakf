# Services Runtime Reroute Decision — Database Wave B-1A.1

## Decision
Authorize a limited Flutter read-source reroute for the public services catalog from direct `public.services` access to `public.v_services_catalog_compat_v1`.

## Reason
B-1A.0 SQL UAT confirmed read-only compatibility facades are active and visible:
- services catalog compatibility facade has 9 rows.
- home services compatibility facade has 3 rows.
- service types compatibility facade has 4 rows.

## Guardrails
- This is compatibility activation, not extraction.
- The legacy tables remain untouched.
- Runtime keeps the same section/card behavior.
- The provider remains fail-open and returns an empty list if the facade is absent or incompatible.
- No servicepoints/serviceproviders reroute until ownership is decided.
- No media/locations/waqf changes.

## Production gate
Production remains not approved until local analyzer and browser UAT evidence are provided.
