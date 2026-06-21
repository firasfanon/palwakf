# PalWakf Platform Comprehensive Guide — Update Note


## Platform 15N1 — Verifier Tooling Hotfix
The Platform 15N administrative control-plane verifier is ASCII-only and PowerShell 5.1 parser-safe. This does not alter route authorization, roles, RLS, SQL, or public runtime behavior.

---

## Platform 15O.1 — Responsive Admin Surface Overflow Closure (2026-06-22)

- Scope: Flutter-only responsive remediation after local Browser UAT observed a RenderFlex overflow in the unit surface selector.
- Unit/system selectors now use expanded, ellipsis-safe menu content.
- Shared admin-surface headers stack scope badges below the title block in constrained widths.
- No SQL, database, RLS, grant, route authorization, content, or production change.
- Candidate status only; Browser UAT retest at 1440/1024/768/390 remains mandatory.

## Platform 15O.2 — Global Responsive Chrome and Admin Action-Bar Overflow Closure
- Flutter-only responsive UI candidate following Browser UAT overflow evidence.
- Keeps public Chrome usable under DevTools-docked and narrow viewports through adaptive container gutters, wrapped top-bar controls, and a stronger header stack threshold.
- Keeps unit/system surface management operations reachable at narrow width through a shared AppBar overflow menu.
- Browser closure evidence remains pending; it does not affect database authorization or production approval.
