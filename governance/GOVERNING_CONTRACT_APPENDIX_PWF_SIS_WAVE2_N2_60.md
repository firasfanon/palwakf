# Governing Contract Appendix — PWF-SIS Wave 2 / N2.60

## Pilot separation gate
A design-system visual pilot must not replace or disable a runtime operational page.

## Closure rule
The gate may close only when evidence proves:
1. runtime route remains operational,
2. pilot route is separate and read-only,
3. restricted role fails closed,
4. console is clean,
5. no overflow exists.

## Forbidden
- replacing runtime pages with pilot pages,
- disabling production features for design testing,
- SQL mutation,
- Database Wave B,
- workflow mutation,
- public visibility mutation,
- `waq_assets` mutation.
