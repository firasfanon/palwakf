# PalWakf Instructions Update — N2.27

1. Treat `site_content`, `media_center`, and `platform_services` as bounded domains.
2. Do not add new operational tables to `public`.
3. Use `public` only for views/RPC wrappers/compatibility surfaces.
4. Do not move tables with RLS/FK/view dependencies without migration plan.
5. Continue updating contract, instructions, governance, internal assistant scope, and public chat scope after important decisions.
6. Keep `waqf_assets` untouched in this wave.
7. Keep `awqaf_system` internal logic untouched in this wave.
