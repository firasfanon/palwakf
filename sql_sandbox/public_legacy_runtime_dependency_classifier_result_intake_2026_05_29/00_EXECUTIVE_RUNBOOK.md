# Executive Runbook — Public Legacy Runtime Dependency Classifier Result Intake

## Run Status

This folder contains read-only markers and follow-up diagnostic templates only.

## Do Not Run

No destructive SQL exists in this pack.

Do not perform:

- `DROP`
- `DELETE`
- `TRUNCATE`
- `ALTER TABLE ... RENAME`
- exact public table replacement
- Media/Service SQL02 rerun
- Auth/RBAC helper rewrite

## Recommended Next Diagnostics

1. Run Flutter/static reference scan for direct `.from('news_articles')`, `.from('activities')`, `.from('announcements')`, `.from('services')`, etc.
2. Inspect SQL view definitions for `cms.v_public_unit_activities`, `cms.v_public_unit_services`, and public compatibility views.
3. Design a dedicated owner for public navigation/service-entry catalog before touching `public.services`.

